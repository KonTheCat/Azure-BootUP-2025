# azd (Azure Developer CLI) — Basic to Advanced (Instructor Notes)

## Intent (AZ-104 framing)
- `azd` is a dev-focused workflow tool, but it produces/operates on core AZ-104 objects: resource groups, RBAC, policy constraints, networking, App Insights/Azure Monitor, and repeatable deployments.
- Goal for students: understand what `azd` does, how to read a template (`azure.yaml` + `infra/`), and how to troubleshoot/operate the deployed resources.

## Prereqs (for a live demo)
- Azure subscription with permissions to create resource groups and common resources.
- `azd` installed: https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd
- Know your target region (and have a backup region if capacity errors happen).
- Template-specific tooling (only if required by your chosen template): Node/.NET/Python runtime, Docker.

## Core docs (verified)
- Overview: https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/overview
- Get started (end-to-end): https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/get-started
- Templates overview: https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/azd-templates
- Make an app “azd compatible”: https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/make-azd-compatible
- Start with app code: https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/start-with-app-code
- Start with an existing template: https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/start-with-existing-template
- Monitor: https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/monitor-your-app
- CI/CD pipeline config: https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/configure-devops-pipeline
- Troubleshoot: https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/troubleshoot

## Community + reference repos (verified)
- `azd` source: https://github.com/Azure/azure-dev
- Template discovery index: https://github.com/Azure/awesome-azd
- Template gallery UI: https://azure.github.io/awesome-azd/
- Small, reliable demo template: https://github.com/Azure-Samples/hello-azd
- “Todo app” template (pick one stack): https://github.com/Azure-Samples/todo-nodejs-mongo

## Key concepts (what to teach explicitly)
- **Template**: a repo with `azure.yaml` + `infra/` (Bicep or Terraform) + app code.
- **Environment**: named configuration/state stored under `.azure/<env-name>/`.
- **Lifecycle commands**:
  - `azd init` (choose template or start with code)
  - `azd provision` (IaC only)
  - `azd deploy` (app build + deploy)
  - `azd up` (provision + deploy)
  - `azd monitor` (jump to logs/insights)
  - `azd down` (delete resources)

## Command cheat sheet (demo-friendly)
- `azd version`
- `azd init -t <template>`
- `azd auth login`
- `azd env list`
- `azd up`
- `azd provision`
- `azd deploy`
- `azd monitor --overview`
- `azd down`

## Lecture + demo plan (45–75 minutes)

### Option A: 45 minutes (minimum viable)
1. (5m) What `azd` is / isn’t (vs `az`, vs ARM/Bicep)
2. (20m) Demo: template-first `azd init` + `azd up`
3. (10m) Template anatomy: `azure.yaml`, `infra/`, `.azure/<env>`
4. (7m) Monitoring + troubleshooting (`azd monitor`, `--debug`)
5. (3m) Cleanup (`azd down`) + takeaways

### Option B: 60 minutes (recommended)
1. (5m) What `azd` is / isn’t
2. (25m) Demo 1: template-first `azd up` (full loop)
3. (10m) Demo 2: small code change + `azd deploy`
4. (10m) Ops: `azd monitor` + Portal tour (RG, App Insights, logs)
5. (10m) Troubleshooting patterns + environment management

### Option C: 75 minutes (with pipelines)
Add:
- (10–15m) CI/CD: explain or run `azd pipeline config` (time-permitting)

## Demo script (template-first, low-risk)

### Demo 0: preflight (30–60 seconds)
- Confirm `azd version`.
- Confirm you can authenticate (`azd auth login`).
- Confirm expected subscription is selected (watch for “wrong tenant/sub”).

### Demo 1: deploy a known template (hello-azd or todo-*)
Pick one:
- `hello-azd` (fastest): https://github.com/Azure-Samples/hello-azd
- `todo-nodejs-mongo` (more “real app”): https://github.com/Azure-Samples/todo-nodejs-mongo

Suggested flow:
1. `azd init -t hello-azd`
2. `azd up`
	- Point out: `azd up` = `provision` + `deploy`.
	- Show: it creates a resource group and multiple resources.
3. Validate the app endpoint (from terminal output).
4. Portal tour (2–3 minutes):
	- Resource group → tags/locations
	- App service / container app / function (template dependent)
	- App Insights + logs

Teach while showing files:
- `azure.yaml`: what “services” exist and how they map to deploy steps.
- `infra/`: what gets provisioned (Bicep/Terraform).
- `.azure/<env>/`: where env-specific values live.

### Demo 2: iterative change (fast feedback)
Goal: show the “inner loop”.
- Make a small change in the app (a banner string, landing page text, health endpoint).
- Run `azd deploy`.
- Re-check endpoint.

Optional: infra-only tweak:
- Make a minimal IaC change (tag, SKU, simple app setting) then run `azd provision`.

### Demo 3 (optional): monitor + troubleshoot
- `azd monitor --overview`
- If something fails: rerun with `azd up --debug` and show how to locate the failing step.

### Demo 4 (optional): pipeline config
Docs: https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/configure-devops-pipeline
- Explain: pipeline config creates CI/CD scaffolding + identity/secrets wiring.
- If you run it live, keep it short and narrate what it creates and where.

### Cleanup (always)
- `azd down`
- Quick note: delete the entire resource group if the template leaves anything behind.

## Troubleshooting (teach the top 6)
Docs: https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/troubleshoot
- **Auth/subscription confusion**: students have multiple tenants/subscriptions.
- **Region capacity**: switch region if a resource SKU is unavailable.
- **Permissions/RBAC**: no rights to create RGs/resources.
- **Policy blocks**: org policy denies certain SKUs/resource types.
- **Local tooling missing**: runtime/Docker not installed for the chosen template.
- **Environment mismatch**: running from the wrong folder / wrong `.azure/<env>`.

## “Basic → Advanced” expansion menu
- Multiple environments (`dev`/`test`/`prod`): compare `.azure/dev` vs `.azure/prod` values.
- Split responsibilities: IaC team owns `infra/`, app team owns service code.
- Infra changes vs app changes: when to use `azd provision` vs `azd deploy`.
- Governance hooks: naming, tagging, policy compliance (AZ-104 tie-in).
- Observability: App Insights queries and log-based troubleshooting.

## Azure Functions (AzF) intermediate/advanced follow-up (verified)
Use as “next lecture” or homework resources.

- Build + deploy a Functions app with `azd`: https://learn.microsoft.com/en-us/azure/azure-functions/create-first-function-azure-developer-cli
- Durable Functions overview: https://learn.microsoft.com/en-us/azure/azure-functions/durable/durable-functions-overview
- Scale guidance: https://learn.microsoft.com/en-us/azure/azure-functions/functions-scale
- Networking options: https://learn.microsoft.com/en-us/azure/azure-functions/functions-networking-options
- Deployment slots: https://learn.microsoft.com/en-us/azure/azure-functions/functions-deployment-slots
- Monitoring: https://learn.microsoft.com/en-us/azure/azure-functions/functions-monitoring
- .NET isolated worker guide: https://learn.microsoft.com/en-us/azure/azure-functions/dotnet-isolated-process-guide

Official deep-dive repos (for advanced students):
- Durable extension source: https://github.com/Azure/azure-functions-durable-extension
- .NET isolated worker source: https://github.com/Azure/azure-functions-dotnet-worker
- Functions runtime host source: https://github.com/Azure/azure-functions-host

## Notes for instructor delivery
- Keep the first demo template extremely reliable (hello-azd).
- Do not live-debug infra for more than ~3 minutes; switch to a “known-good” environment.
- Emphasize: `azd` is not magic; it’s orchestrating identity + IaC + deployment + links to monitoring.

