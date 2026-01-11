#!/usr/bin/env python
"""Validate http(s) links in a Markdown file and emit results as JSON.

Designed for automation: the JSON output includes per-URL status, final URL after redirects,
HTTP method used, errors, and line-level occurrences.

No third-party dependencies.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable
from urllib.error import HTTPError, URLError
from urllib.parse import urlparse
from urllib.request import Request, urlopen


URL_PATTERN = re.compile(r"(?P<url>https?://[^\s\)\]>\"\\}]+)")


@dataclass(frozen=True)
class Occurrence:
    line: int
    snippet: str


@dataclass(frozen=True)
class LinkResult:
    url: str
    status: int | None
    ok: bool
    classification: str  # ok | broken | warn | error
    method: str | None
    final_url: str | None
    error: str | None
    occurrences: list[Occurrence]


def _read_lines(file_path: Path) -> list[str]:
    return file_path.read_text(encoding="utf-8").splitlines()


def extract_urls_with_occurrences(lines: list[str]) -> dict[str, list[Occurrence]]:
    urls: dict[str, list[Occurrence]] = {}

    for idx, line in enumerate(lines, start=1):
        for match in URL_PATTERN.finditer(line):
            url = match.group("url").rstrip(".,")
            # Keep a small snippet for debugging/automation (avoid huge JSON lines)
            snippet = line.strip()
            if len(snippet) > 220:
                snippet = snippet[:217] + "..."
            urls.setdefault(url, []).append(Occurrence(line=idx, snippet=snippet))

    return urls


def _is_http_url(url: str) -> bool:
    try:
        parsed = urlparse(url)
    except Exception:
        return False
    return parsed.scheme in {"http", "https"} and bool(parsed.netloc)


def _request_url(url: str, method: str, timeout_sec: float, user_agent: str) -> tuple[int, str | None]:
    req = Request(url, method=method)
    req.add_header("User-Agent", user_agent)
    req.add_header("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")

    with urlopen(req, timeout=timeout_sec) as resp:
        status = int(getattr(resp, "status", 200))
        final_url = getattr(resp, "geturl", lambda: None)()
        return status, final_url


def check_url(url: str, timeout_sec: float, user_agent: str) -> tuple[int | None, str | None, str | None, str | None]:
    """Return (status, final_url, method, error). status None means network/unknown error."""

    # Prefer HEAD, fall back to GET for servers that don't support HEAD.
    for method in ("HEAD", "GET"):
        try:
            status, final_url = _request_url(url, method=method, timeout_sec=timeout_sec, user_agent=user_agent)
            if method == "HEAD" and status == 405:
                continue
            return status, final_url, method, None
        except HTTPError as e:
            # HTTPError still contains a status code; treat as a response.
            final_url = getattr(e, "url", None)
            if method == "HEAD" and int(e.code) == 405:
                continue
            return int(e.code), final_url, method, None
        except URLError as e:
            # Retry with GET if HEAD fails.
            last_error = str(getattr(e, "reason", e))
            if method == "HEAD":
                continue
            return None, None, method, last_error
        except Exception as e:
            # Retry with GET if HEAD fails.
            if method == "HEAD":
                continue
            return None, None, method, str(e)

    return None, None, None, "Unknown error"


def classify_status(status: int | None) -> tuple[bool, str]:
    if status is None:
        return False, "error"

    # Treat 2xx/3xx as OK.
    if 200 <= status < 400:
        return True, "ok"

    # Definite broken.
    if status in {404, 410}:
        return False, "broken"

    # Everything else is a warning (403, 429, 500, etc.).
    return False, "warn"


def build_results(
    url_occurrences: dict[str, list[Occurrence]],
    timeout_sec: float,
    user_agent: str,
    max_workers: int,
) -> list[LinkResult]:
    urls = [u for u in url_occurrences.keys() if _is_http_url(u)]

    results: dict[str, LinkResult] = {}

    with ThreadPoolExecutor(max_workers=max_workers) as pool:
        future_map = {
            pool.submit(check_url, url, timeout_sec, user_agent): url
            for url in urls
        }

        for fut in as_completed(future_map):
            url = future_map[fut]
            try:
                status, final_url, method, error = fut.result()
            except Exception as e:
                status, final_url, method, error = None, None, None, str(e)

            ok, classification = classify_status(status)
            results[url] = LinkResult(
                url=url,
                status=status,
                ok=ok,
                classification=classification,
                method=method,
                final_url=final_url,
                error=error,
                occurrences=url_occurrences.get(url, []),
            )

    # Stable output ordering for diffs/automation.
    return sorted(results.values(), key=lambda r: r.url)


def to_json_payload(file_path: Path, lines: list[str], link_results: list[LinkResult]) -> dict[str, Any]:
    total_occ = sum(len(r.occurrences) for r in link_results)
    unique = len(link_results)
    ok_count = sum(1 for r in link_results if r.classification == "ok")
    broken_count = sum(1 for r in link_results if r.classification == "broken")
    warn_count = sum(1 for r in link_results if r.classification == "warn")
    error_count = sum(1 for r in link_results if r.classification == "error")

    def occ_to_dict(o: Occurrence) -> dict[str, Any]:
        return {"line": o.line, "snippet": o.snippet}

    def res_to_dict(r: LinkResult) -> dict[str, Any]:
        return {
            "url": r.url,
            "status": r.status,
            "ok": r.ok,
            "classification": r.classification,
            "method": r.method,
            "final_url": r.final_url,
            "error": r.error,
            "occurrences": [occ_to_dict(o) for o in r.occurrences],
        }

    return {
        "file": str(file_path.as_posix()),
        "checked_at": datetime.now(timezone.utc).isoformat(),
        "summary": {
            "lines": len(lines),
            "total_occurrences": total_occ,
            "unique_urls": unique,
            "ok": ok_count,
            "broken": broken_count,
            "warn": warn_count,
            "error": error_count,
        },
        "links": [res_to_dict(r) for r in link_results],
    }


def parse_args(argv: list[str]) -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Validate all http(s) links in a Markdown file and output JSON.")
    p.add_argument("markdown_file", type=Path, help="Path to the Markdown file to validate")
    p.add_argument("--timeout", type=float, default=20.0, help="Request timeout in seconds (default: 20)")
    p.add_argument("--workers", type=int, default=12, help="Max concurrent link checks (default: 12)")
    p.add_argument(
        "--user-agent",
        default="Azure-BootUP-2025 LinkChecker/1.0 (+https://learn.microsoft.com/)",
        help="User-Agent header to send",
    )
    p.add_argument("--output", type=Path, default=None, help="Write JSON output to this path (default: stdout)")
    return p.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)

    file_path: Path = args.markdown_file
    if not file_path.exists():
        print(json.dumps({"error": "file_not_found", "file": str(file_path)}))
        return 2

    start = time.time()
    lines = _read_lines(file_path)
    url_occ = extract_urls_with_occurrences(lines)

    link_results = build_results(
        url_occurrences=url_occ,
        timeout_sec=float(args.timeout),
        user_agent=str(args.user_agent),
        max_workers=max(1, int(args.workers)),
    )

    payload = to_json_payload(file_path=file_path, lines=lines, link_results=link_results)
    payload["elapsed_seconds"] = round(time.time() - start, 3)

    out = json.dumps(payload, indent=2, ensure_ascii=False)

    if args.output is not None:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(out + "\n", encoding="utf-8")
    else:
        sys.stdout.write(out + "\n")

    # Non-zero exit if any broken links found.
    if payload["summary"]["broken"] > 0:
        return 3

    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
