# my-agent-config

Durable Antigravity configuration with reinstall-safe skills.

## Design Goal

Keep custom skills/workflows/rules after Antigravity reinstall.

## Directory Strategy

Use this 3-layer model:

1. Source layer (Git repo)
- Example: `C:\Users\ICe\Repos\my-agent-config`
- Stores your managed config and bootstrap script.

2. Persistent runtime layer
- `C:\Users\ICe\.agents`
- This is the long-lived home for `skills`, `workflows`, `rules`.

3. Antigravity compatibility layer
- `C:\Users\ICe\.gemini\antigravity\skills` (junction)
- Points to `C:\Users\ICe\.agents\skills`.

Do not use `scratch` as the primary storage for long-lived skills.

## Reinstall SOP (Recommended)

After reinstalling Antigravity:

```powershell
# 1) Go to this repo
cd C:\Users\ICe\Repos\my-agent-config

# 2) Preview changes
.\setup.ps1 -DryRun

# 3) Apply changes
.\setup.ps1
```

The script is idempotent and safe to run multiple times.

## What setup.ps1 does

- Ensures persistent dirs exist under `C:\Users\ICe\.agents`
- Syncs repo-managed `workflows/skills/rules` (if present)
- Syncs custom bundles (`AcademicForge`, `awesome-ai-research-writing`, `skill`, `ui-ux-pro-max-skill`)
- Ensures `C:\Users\ICe\.gemini\antigravity\skills` is a junction to `C:\Users\ICe\.agents\skills`
- If an old physical `antigravity\skills` directory exists, it migrates content and creates a timestamped backup before linking

## Verification Commands

```powershell
Get-Item C:\Users\ICe\.gemini\antigravity\skills | Select-Object FullName,LinkType,Target
Get-ChildItem C:\Users\ICe\.agents\skills -Recurse -Filter SKILL.md | Measure-Object
```

## Notes

- Keep this repo in a stable path (for example `C:\Users\ICe\Repos\my-agent-config`).
- You can run `setup.ps1` after any OS migration, machine change, or Antigravity reinstall.
