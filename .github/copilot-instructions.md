# AI Agent Instructions for Azure BootUP 2025

## Repository Purpose
This repository hosts curriculum materials for an **AZ-104 Azure Administrator certification course** running from October 2025 through January 2026. The course targets students preparing for Azure Administrator certification through weekend-based live instruction combined with hands-on labs.

## Content Structure & Conventions

### Directory Organization
- **`ClassAgenda/`**: Session plans named `YYYY-MM-DD-DayOfWeek.md` (e.g., `2025-10-25-Saturday.md`)
- **`ClassNotes/`**: Post-session lecture summaries using `YYYY-MM-DD.md` format
- **`CodingExamples/`**: Organized by topic subdirectories (`compute/`, `storage/`, `app-gateway/`, etc.)
  - PowerShell scripts (`.ps1`) for Windows-centric Azure operations
  - Bash scripts (`.sh`) for cross-platform Azure CLI workflows
  - Bicep templates (`.bicep`) for Infrastructure as Code examples
- **`TopicResearch/`**: Deep-dive markdown documents on specific Azure services and tools

### File Naming Patterns
- **Agendas**: Always follow `YYYY-MM-DD-DayOfWeek.md` format in `ClassAgenda/`
- **Notes**: Use `YYYY-MM-DD.md` in `ClassNotes/`
- **Code examples**: Use descriptive names with topic prefix (e.g., `create-vm-examples.ps1`, `deploy-dotnet-aci-cloudshell.sh`)

## Content Guidelines

### Agenda Creation (Source of Truth: `CourseSchedule.md`)
When creating or updating session agendas:

1. **Check `CourseSchedule.md` first** - This is the authoritative source for course topics and schedule
2. **Required sections**:
   - Introductions/Housekeeping (brief)
   - Today's Topics (bulleted list matching CourseSchedule.md)
   - Microsoft Learn Resources with verified URLs
   - Labs section using [MSFTHUB Cert Wiki - AZ-104](https://certs.msfthub.wiki/labs/azure/az-104/) as primary source
   - Applied Skills challenges from [Microsoft Applied Skills](https://learn.microsoft.com/en-us/credentials/applied-skills/)
   - Study Strategies (include AI-assisted study tips and video resources)
3. **Session timing**: Saturday 2PM-6PM EST with 15-minute break; Sunday 10AM-2PM EST

### Code Examples Philosophy
- **Clarity over cleverness**: Code is educational first, production-ready second
- **Comment the "why"**: Explain *why* commands are used, not just *what* they do
- **Grounded examples**: Use specific SKUs, image names, regions - avoid generic placeholders like `<resource-name>`
- **Multiple approaches**: Show both PowerShell and Azure CLI where applicable
- **Cloud Shell friendly**: Examples in `.sh` files should work in Azure Cloud Shell without local tooling

Example from `deploy-dotnet-aci-cloudshell.sh`:
- Uses `az acr build` instead of local Docker to build in Azure
- Includes detailed comments explaining each step's purpose
- Uses randomized naming to avoid conflicts (`RND=$RANDOM`)

### Bicep Templates
- Reference actual Azure resource API versions (see `monstrosity.bicep` for Application Gateway example)
- Include parameter documentation
- Show realistic multi-service scenarios (e.g., App Gateway with multiple backend pools)

### Topic Research Documents
Follow the pattern in `azd-basic-to-advanced.md`:
- Start with "Intent" section framing the topic for AZ-104 context
- Include verified Microsoft Learn URLs (check validity)
- Provide command cheat sheets for demos
- Structure lecture plans with timing estimates (45/60/75 min options)
- Include troubleshooting sections with common student issues
- Add "Notes for instructor delivery" with practical tips

## Quality Standards

### Link Verification
- **NEVER hallucinate Microsoft Learn URLs**
- Verify all documentation links point to valid `learn.microsoft.com` pages
- Use [MSFTHUB Cert Wiki](https://certs.msfthub.wiki/labs/azure/az-104/) for lab references
- Check for deprecated content (Azure services evolve rapidly)

### Writing Style
- **Tone**: Professional, encouraging, precise, and terse (per `AGENT_INSTRUCTIONS.md`)
- **Active voice**: Preferred over passive constructions
- **Grammar**: Fix typos immediately; maintain high editorial standards
- **Avoid fluff**: No generic motivational content without substance

### Course Context Awareness
- Course runs **October 2025 - January 2026** (10 weeks, weekend-only)
- Students are preparing for **AZ-104 certification exam**
- Focus on: Identity & Governance, Storage, Compute, Networking, Monitoring & Backup
- Course fee is $397; students manage their own Azure subscriptions (~$200 budget)
- Students expected to register for AZ-104 exam within 1 month of course completion

## Key Topics (AZ-104 Focus Areas)
1. **Identity & Governance**: Microsoft Entra ID, RBAC (two types: Entra vs Azure RBAC), Azure Policy, Management Groups
2. **Storage**: Blob Storage, Azure Files, security features, redundancy options
3. **Compute**: Virtual Machines, VM Scale Sets, Azure App Service, Containers (ACI/AKS)
4. **Networking**: Virtual Networks, DNS, NSGs, custom routing, load balancing, Application Gateway
5. **Monitoring & Backup**: Azure Monitor, Log Analytics, Azure Backup, Site Recovery

## When Updating Content

### Before Editing:
- Read `CourseSchedule.md` to understand course flow and current week's topics
- Check `CourseIntentionsAndPolicies.md` for course philosophy and student expectations
- Review existing `AGENT_INSTRUCTIONS.md` for role-specific guidance

### During Editing:
- Match the existing file's tone and structure
- Verify all Microsoft Learn links are current and accurate
- Ensure code examples include explanatory comments
- Cross-reference with AZ-104 exam objectives

### For New Content:
- Check if similar content exists in `TopicResearch/` or `CodingExamples/`
- Follow established naming conventions
- Include instructor delivery notes for complex topics
- Add troubleshooting sections for predictable student issues

## Commands & Tools Referenced
- **Azure CLI**: Primary tool for bash scripts and cross-platform examples
- **PowerShell**: Azure PowerShell modules for Windows-centric examples
- **Azure Developer CLI (`azd`)**: For end-to-end deployment workflows (see `azd-basic-to-advanced.md`)
- **Bicep**: Infrastructure as Code (preferred over ARM JSON)
- **Azure Cloud Shell**: Assume availability for script execution

## Additional Resources
- **MSFTHUB Wiki**: https://certs.msfthub.wiki/labs/azure/az-104/ (primary lab source)
- **Train Cert Poster**: https://aka.ms/traincertposter
- **CMD.MS**: https://cmd.ms/ (Azure command reference)
- **Session Feedback Form**: https://forms.office.com/r/3i2UtA2DXu
