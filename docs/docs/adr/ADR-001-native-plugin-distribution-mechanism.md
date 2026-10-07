# ADR-001: Adopt the Native Copilot CLI / Claude Code Plugin Mechanism for Bolt Framework Distribution

## Status

Accepted

## Context and Problem Statement

Bolt Framework needs a way to distribute its skills, agents, prompts and instructions to
consuming repositories in a modular, opt-in way (e.g. a team that only does backend work
should not have to pull in frontend or CRM-specific content). An earlier design proposed a
**custom resolver/registry**: a bespoke manifest format, a custom CLI resolver, and a private
distribution mechanism layered on top of `Init.ps1` / `init.sh`.

That approach was discarded because:

- Both target clients — **GitHub Copilot CLI** and **Claude Code CLI** — already ship a
  native, first-class plugin mechanism (`.claude-plugin/plugin.json` +
  `.claude-plugin/marketplace.json`) that both CLIs can read.
- Building and maintaining a custom resolver duplicates functionality the CLIs already provide
  (install, list, update, uninstall, enable/disable, marketplace management), with none of the
  long-term maintenance cost shifted onto the CLI vendors.
- A custom mechanism would require consuming teams to trust and run Bolt-specific tooling
  instead of the standard `copilot plugin` / `claude plugin` commands they already know.

The open question left unresolved before implementation was **empirical, not
architectural**: does the native mechanism actually behave consistently — for a monorepo
using a relative-path local `source` — across both CLIs, and how does each CLI cache/update
installed content? This ADR captures the decision and the Fase 0 spike results that confirm
(with two documented divergences) that the native mechanism is viable.

## Decision Drivers

- Avoid building/maintaining a custom resolver when both target CLIs solve the same problem
  natively.
- Preserve compatibility with both GitHub Copilot CLI and Claude Code CLI (dual-client
  requirement of the Bolt Framework).
- Minimize the learning curve for consuming teams — they should use the CLI commands they
  already know (`copilot plugin install`, `claude plugin install`).
- Keep the plugin split granular (9 plugins: `bolt-core`, `bolt-frontend`, `bolt-backend`,
  `bolt-cloud-platform`, `bolt-data`, `bolt-ai`, `bolt-crm`, `bolt-work-management`,
  `bolt-integration`) without requiring a bespoke aggregation/bundling engine.

## Considered Options

- **Option 1 — Custom resolver/registry**: bespoke manifest + custom CLI wrapper that
  downloads and materializes Bolt content into consuming repos.
- **Option 2 — Native plugin mechanism**: adopt `.claude-plugin/plugin.json` +
  `.claude-plugin/marketplace.json`, distributing 9 plugins (one of them, `bolt-core`, modeled
  as a normal always-installed plugin) through a `bolt plugin` convenience wrapper around the
  native CLIs.

## Decision Outcome

Chosen option: **"Native plugin mechanism" (Option 2)**, because both GitHub Copilot CLI and
Claude Code CLI already implement a compatible, maintained-by-the-vendor plugin/marketplace
system that a local relative-path monorepo source can use directly, removing the need for any
custom resolver.

### Consequences

- Good: No custom distribution tooling to build or maintain — install/list/update/uninstall
  are provided by the CLIs themselves.
- Good: Cross-compatible manifest format confirmed empirically (see Fase 0 spike below) — one
  `.claude-plugin/` tree serves both clients.
- Good: Granular, independent plugin toggling (9 plugins, no preset bundles) matches the
  existing largely-disjoint `.boltf/scopes/` boundaries.
- Bad: Bolt Framework's release process becomes coupled to CLI vendor behavior and evolution
  (e.g. future breaking changes to the manifest schema are outside Bolt's control).
- Bad (constraint discovered in the spike): `plugin.json`'s `skills` field **must** use
  `./`-prefixed relative paths (e.g. `"./skills"`) for Claude Code CLI to accept it — a bare
  directory name (`"skills"`) is rejected. All 9 plugin manifests must follow this convention.
- Bad (constraint discovered in the spike): Claude Code CLI's `plugin update` is a **no-op**
  when the `version` field is unchanged, even if file content changed, and the installed cache
  is version-keyed and survives `uninstall`. **Every Bolt plugin release must bump semver**,
  or Claude Code users will never receive the update via `plugin update`. Copilot CLI does not
  have this limitation (it always re-copies content on `update`).
- Bad: Claude Code requires a client restart to apply an updated plugin; Copilot CLI applies
  immediately. This must be documented in the `bolt plugin` wrapper's UX.

## More Information

### Fase 0 spike — empirical validation (Windows)

Executed against an isolated sandbox (`.claude-plugin/marketplace.json` + one plugin,
`bolt-spike`, with a relative-path `source`), using `copilot` CLI v1.0.63 and `claude` CLI
v2.1.179. Sandbox was fully cleaned up after the spike (no artifacts left on disk).

| Behavior                                                      | Copilot CLI                                                                                | Claude Code CLI                                                                            |
| ------------------------------------------------------------- | ------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------ |
| Local (non-git) directory as marketplace `source`             | ✔ Works                                                                                    | ✔ Works                                                                                    |
| `plugin.json` `skills: ["skills"]` (bare name)                | ✔ Accepted                                                                                 | ✘ Rejected (`Invalid input`)                                                               |
| `plugin.json` `skills: ["./skills"]` (relative path)          | ✔ Accepted                                                                                 | ✔ Accepted                                                                                 |
| Install cache location                                        | `~/.copilot/installed-plugins/<marketplace>/<plugin>/` (unversioned, overwritten in place) | `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/` (versioned, content-addressed) |
| `update` picks up content change with **unchanged** version   | ✔ Yes (full re-copy)                                                                       | ✘ No (`already at latest version`)                                                         |
| `update` picks up content change after **version bump**       | ✔ Yes                                                                                      | ✔ Yes (requires client restart to apply)                                                   |
| `uninstall` clears the version-keyed cache                    | N/A (unversioned)                                                                          | ✘ No — cache persists; reinstall does not force a refresh either                           |
| Unqualified `plugin update <name>` (no `@marketplace`)        | ✔ Works                                                                                    | ✘ `Plugin not found` — requires fully-qualified `name@marketplace`                         |
| Marketplace auto-removed after its only plugin is uninstalled | ✔ Yes                                                                                      | ✔ Yes (consistent)                                                                         |

**Conclusion**: the native mechanism is viable for both CLIs with a relative-path local
`source` inside the monorepo. Two authoring/process constraints must be adopted going
forward:

1. Always write `skills` (and equivalent `agents`/`hooks`/`mcp` arrays) in `plugin.json` with
   `./`-prefixed relative paths.
2. Bump `version` in `plugin.json` on every content-affecting change as part of the Bolt
   release process (see `bolt-release`), since Claude Code CLI will not otherwise deliver the
   update.

Linux/WSL validation was **not** performed in this spike (no Linux/WSL environment available
in this session) — tracked as a follow-up gap for a future spike iteration before declaring
full cross-platform parity.

### References

- [docs/bolt-plugin-distribution-proposal.md](../bolt-plugin-distribution-proposal.md) — full
  proposal, plugin assignment matrix, and implementation plan (this ADR documents the decision
  taken in that proposal's "Por qué no un resolver propio" section and closes the Fase 0 spike
  item from "Decisiones y preguntas abiertas").
