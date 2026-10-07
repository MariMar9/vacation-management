# Refreshing this deck

This deck makes factual claims about the Bolt Framework. Those facts live in this
repository and they move. This file exists so that bringing the deck up to date is a
**targeted, verifiable** job rather than a rewrite from memory.

Read this before editing `slides.md`.

---

## 1. Provenance stamp

| What | Value |
|---|---|
| Framework commit the deck was derived from | **`d7ed2f2`** — *feat: add change classification stage to CI pipeline AB#37547 (#79)*, 2026-09-03 |
| Framework version cited on slides | **`v1.0.0`** (git tag + root `CHANGELOG.md`, 2026-09-02) |
| Slidev theme | `@ava-innersource/slidev-theme-base` **v0.0.8**, theme commit **`7ff5725`** (2026-07-09) |
| Deck authored | 2026-09-08 |

**Update this table whenever you refresh.** It is the anchor for everything in §2.

---

## 2. Staleness check — run this first

One command tells you whether any source behind the deck has changed since the stamp.
Replace `d7ed2f2` with the commit in §1 if you have refreshed since.

```bash
git log --oneline d7ed2f2..HEAD -- .github/copilot-instructions.md CLAUDE.md AGENTS.md CHANGELOG.md REQUEST-ACCESS.md .boltf/README.md .boltf/bolt-manifest.yaml .boltf/CHANGELOG.md .boltf/memory/ .boltf/scopes/ .boltf/docs/templates/ .claude-plugin/marketplace.json .claude/commands/modernize-legacy.md plugins/ tests/README.md .github/workflows/
```

- **No output** → the deck's sources are unchanged. Nothing to do.
- **Output** → work through §3 for the slides bound to the changed paths, then §5.

To see whether the *theme* moved (new layouts, palette changes, breaking props):

```bash
gh api repos/ava-innersource/slidev-theme-avanade-base/commits/main --jq '.sha[0:7] + "  " + .commit.author.date'
```

---

## 3. Slide → source map

Slide numbers match the order in `slides.md`. Only factual claims are listed; narrative
framing is not sourced.

| # | Slide | Sources |
|---|---|---|
| 1 | Cover | — no factual claims |
| 2 | The problem Bolt solves | **External only:** DORA / Google Cloud 2025, *State of AI-assisted Software Development* — <https://dora.dev/insights/balancing-ai-tensions/>. Figures: ~90% adoption, >80% report productivity gain, ~30% little/no trust (now a bullet, not the headline), stability down, verification overhead. **The cost panel's headline figure is METR, not DORA** — "overestimated AI's effect on their time by 40 percentage points on average" (11 May 2026), measured against METR's own RCT. Changed from the scarlet `~30%` on 2026-09-10 to resolve the numeral collision with the efficiency band on slide 12 (evidence file §5.3); the pairing self-report vs measured is now deliberate. The closing line also paraphrases DORA's conclusion — outcome depends less on the tool than on the system it runs inside — and ties it to the CI/CD-harness point on slides 3 and 11 (§7.7). |
| 3 | What Bolt Framework is | Definition quote (**elided** — see §7.7): `.boltf/README.md:14`. Bolt duration: `.boltf/README.md:44,509`, `plugins/bolt-core/skills/bolt-tasks/SKILL.md:3`. Bolts per feature / task size: `plugins/bolt-core/skills/bolt-framework/SKILL.md:121,140,148`. 19 articles: `.boltf/memory/constitution.original.md`. Agent obligations: `.boltf/memory/constitution.md:241-249`. Agent + skill counts: **re-derive, see §4**. The four cross-phase agents (security, dependencies, docs, templates): `plugins/bolt-core/skills/bolt-framework/HANDOFF-MATRIX.md:262-296` — same source as the slide 6 cross-phase row. Dual-client: `CLAUDE.md:31-57`. AWS AI-DLC / DDD / Clean Architecture credit: `.boltf/README.md:716-721`. |
| 4 | The lifecycle | 6 phases + entry/exit criteria: `plugins/bolt-core/skills/bolt-framework/SKILL.md:31-41`. Artifact per phase: `plugins/bolt-core/skills/bolt-framework/references/project-structure.md:53-62`, `.boltf/README.md:395-433`. Handoff matrix refusals: `plugins/bolt-core/skills/bolt-framework/HANDOFF-MATRIX.md:71,126`. 8 cognitive stages: **removed from the slide on purpose — see §7.8**; they survive only in the speaker notes. Bolt inner loop: `.boltf/README.md:511-526`. |
| 5 | Specs before code | "Specs Before Code" + "Constitution is law": `.github/copilot-instructions.md:204,206`, `plugins/bolt-core/skills/bolt-framework/SKILL.md:454-461`. Acceptance criteria classified `@smoke`: `plugins/bolt-core/skills/bolt-feature/SKILL.md:3`. Mandatory scaffolding: `plugins/bolt-core/skills/bolt-feature/SKILL.md:33-108`. Mandatory ticket per feature + the three trackers (GitHub Issues default, Jira, Azure Boards) and the id recorded in the spec Metadata: `plugins/bolt-core/skills/bolt-feature/SKILL.md:62-102,145`. Drift analysis + orphan code: `plugins/bolt-core/skills/bolt-analyze/SKILL.md:21-52,72-76`. Weekly CI drift score 0–10: `.github/workflows/spec-drift.yml`. Artifact tree: `.boltf/README.md:481-495`. **Two things the drift scan does NOT do — do not put them on the slide until they ship:** it compares specs against *source code only*, never reading Issues/Work Items to check that a spec's artifacts exist in the tracker or that both sides agree on status (it only *writes* a labelled issue at the end); and it exists **only as a GitHub Actions workflow** — the repo's Azure Pipelines templates (`plugins/bolt-work-management/skills/skill-azdo-pipeline-templates/templates/`) cover app CI, blue-green App Service and Bicep infra, not drift. Both gaps are tracked as **[#83](https://github.com/ava-group-iberiademos/bolt-framework/issues/83)** (proposal IMP-20260909-001); if it ships, this slide can claim them. **`ADR trail` was deliberately removed from the spine diagram** — it hung off `Code + tests` as the terminal node, which contradicts ADRs being decision-triggered rather than phase-bound (§7.8 logic, and the slide 6 cross-phase row). ADRs still appear on slides 6, 9 and 10. |
| 6 | Advantages across the SDLC | Per-phase contributions: `.boltf/docs/templates/` (22 `*-template.md`, each tagged with its lifecycle stage on line 3) and `.boltf/README.md:395-433`. Gate thresholds: `plugins/bolt-core/skills/skill-bolt-quality-gates/SKILL.md:16-22,136-141`. Equivalence gate: `plugins/bolt-core/skills/skill-bolt-quality-gates/SKILL.md:24-45`, `.claude/commands/modernize-legacy.md:74-75`. **Cross-phase row**: `plugins/bolt-core/skills/bolt-framework/HANDOFF-MATRIX.md:262-296` (the four cross-phase agents: Security, Dependencies, Docs, Templates), `status-report-template.md:3` + `alignment-report-template.md:3` (the only 2 of 22 templates tagged `CROSS-PHASE`), `bolt-alignment/SKILL.md:11` and `AGENTS.md:183`. **ADRs are tagged cross-phase nowhere** — `adr-template.md` carries no stage tag at all and "Bolt ADR" appears in the matrix only as a handoff *target*. The row says "whenever a decision is taken" because `skill-bolt-adr` is decision-triggered, not phase-bound (`SKILL.md:3,8-12`); do not restate it as a cross-phase artifact. |
| 7 | Where it applies | 5 entry scenarios: `.boltf/README.md:163-391`. 4 practices → scopes: `.boltf/scopes/README.md:13-18`. 9 scopes: `.boltf/bolt-manifest.yaml:19-28` — **but the chip row deliberately shows 8**: `crm` is omitted by decision (2026-09-09) and `work-management` is highlighted as active. Because the chips are no longer a complete enumeration, the copy carries no count at all. Do not re-add a numeral without re-adding the chip. **Reworded 2026-09-15 to be client-safe (§5b):** the card is "From a requirement" not "Pre-sales", the discovery gate reads "a named expert signs it off" rather than `SME sign-off`, and the configuration strip says "its own slice of the governing document, skills and tooling" instead of naming plugins and MCP tools. Keep it that way — the client edition imports this slide. Chips use the `bf-chips--tight` variant so the row fits on one line at 980px. Scenario values + per-scenario adaptation: `CLAUDE.md:14-15`, `plugins/bolt-core/skills/bolt-plan/SKILL.md:100-117,207-213`. Backend stack templates: `.boltf/docs/templates/stacks/README.md:5-11`. Empty-plugin caveat: `plugins/bolt-ai/`, `plugins/bolt-crm/`, `plugins/bolt-data/` (manifest only). |
| 8 | Custom development | **Mixed provenance — the slide carries its own disclaimer.** The two commercial models (turnkey / agile) are **Avanade delivery practice; the framework documents neither** — a repo-wide grep for `fixed-price`, `turnkey` or `time and materials` returns nothing outside `demo/from_rfp/`. Bolt's half *is* repo-sourced: acceptance criteria classified as executable tests (`plugins/bolt-core/skills/bolt-feature/SKILL.md:3,173`), effort and cost estimation with a go/no-go scorecard (`.boltf/docs/templates/rfp-analysis-template.md:127,140,182-184`), and weekly spec-to-code drift scoring (`.github/workflows/spec-drift.yml`). The "two to three days" figure: `plugins/bolt-core/skills/bolt-framework/SKILL.md:121,140,148`. The CI/CD-harness caveat is the same one carried on slides 3, 4, 10 and 11 — §7.7. **The fixed-price argument is ours, not the repository's**: spec-driven delivery makes fixed scope more governable because the acceptance criteria are written as tests before commitment and drift is scored continuously. It is an argument from mechanism, not a measured claim — do not let it drift into a guarantee. |
| 9 | One-pager — Business developers | RFP path: `.boltf/README.md:256-293`. RFP report structure incl. estimation + go/no-go scorecard: `.boltf/docs/templates/rfp-analysis-template.md`. **Estimation wording is load-bearing**: slide 9 says the estimate "runs on **your** model — Bolt structures the inputs, not the maths", which is what reconciles it with the "Gap — estimation" line on slide 11. Do not simplify either one without the other. Business-discovery triage, 4 paths — and note the bifurcation the slide leans on: the two No-Code paths **close the case**, only the two Bolt paths scaffold a repo (`business-triage.agent.md:3-9`): `plugins/bolt-core/agents/business-researcher.agent.md:3-8`, `business-triage.agent.md:3-9`, `plugins/bolt-core/skills/business-agent-poc-flow/SKILL.md`. Access process: `REQUEST-ACCESS.md`. |
| 10 | One-pager — Customers | Agent obligations (read / validate / fail / log for audit): `.boltf/memory/constitution.md:241-249`. Security + compliance checklist: `.boltf/memory/constitution.md:198-226`, `.boltf/docs/templates/bolt-security-complete-guide.md:22-29`. Production manual approval: `.boltf/memory/constitution.md:138-145`. 5 HITL checkpoints: `.claude/commands/modernize-legacy.md:29-78`. ADRs: `plugins/bolt-core/skills/skill-bolt-adr/`, `.boltf/docs/templates/adr-template.md`. Traceability chain: `.boltf/scopes/work-management/memory/constitution.md:285-301`. |
| 11 | One-pager — Delivery leads | Bolt sizing: `plugins/bolt-core/skills/bolt-framework/SKILL.md:121,140,148`. CI/CD-harness caveat and the short-Sprint recommendation: **not repo-sourced — see §7.7**. Velocity re-calibration rule: `plugins/bolt-core/skills/bolt-implement/SKILL.md:63-78`. Branch discipline: `plugins/bolt-core/skills/skill-bolt-branch-management/SKILL.md`. 6 metrics + cadence and the spec-vs-tool conflict rule: `.boltf/scopes/work-management/memory/constitution.md:260-264,310-319`. Azure DevOps sync + `AB#`: `plugins/bolt-work-management/skills/azdo-sync/README.md:13-26`. Reporting: `.boltf/docs/templates/status-report-template.md`, `alignment-report-template.md`. Two-step init: `.boltf/scopes/README.md:5-53`. Test counts: `tests/README.md:71,101`. CI jobs: `.github/workflows/ci.yml`. Version: `.boltf/bolt-manifest.yaml:7`, `CHANGELOG.md:9`. |
| 12 | What efficiency to expect | **External only, and the most sensitive slide in the deck.** Headline: **Gartner**, *How to Capture AI-Driven Productivity Gains Across the SDLC*, doc 1-2LHXLGYN (11 Apr 2025) — 25–30% by 2028 across the SDLC vs ~10% code-focused. Segmentation: **Stanford** (Denisov-Blanch) and **McKinsey** — see evidence file §2. J-curve: **DORA** ROI report 2026.01. Measurement method: **Thoughtworks Technology Radar** Vol. 34 (15 Apr 2026), which places coding throughput in *Caution*. Wording is **"built to reach it"** — an indicative expectation, never a commitment and never contractual (evidence file §8 decision table). **Do not rephrase as "from 30%"**: Gartner's band is a 2028 ceiling, not a floor (§5.1). Full rationale and counter-evidence: [`research/efficiency-evidence.md`](research/efficiency-evidence.md). |
| 13 | Close — *An operating model, not a tool* | — no factual claims; the only sourced item is the access route, `REQUEST-ACCESS.md`. **Layout is `breaker`, not `close`** — changed 2026-09-10 because `close.vue` renders the Avanade closing visual only and has no slots, so a call to action was invisible to the room. `breaker` carries `title` + `subtitle` in white over the inverted gradient. Also dropped the "acceleration without a system" recap, which duplicated the line promoted onto slide 2. **The CTA on the slide is the internal one**; for a client audience the speaker notes say to substitute the engagement next step and not read the access route aloud. |
| — | **Appendix** | Slides 14–16 sit **after the close**, by decision (2026-09-11), so the main flow stays at 13. Each is one engagement, two columns, with a brand photograph on the right. |
| 14 | Higher education — VB6 migration | **Client reference.** All facts, governance and open items: [`research/client-references.md`](research/client-references.md) — read it before editing. Nothing is sourced from the framework repository, because no client reference exists there; that record is the only provenance. **This is the engagement the framework was extracted from**, which is why it predates the framework's own release — say it rather than letting someone find it. The behaviour-preservation wording deliberately stops at "the recovered rules became the tests the rebuild was checked against": it does **not** claim the formal equivalence-gate thresholds, because no parity figure exists. |
| 15 | Automotive — support agent | **Client reference.** The transfer case, and the load-bearing one: different sector, greenfield, different stack and toolchain from slide 14. Confirms two capabilities claimed nowhere else in the deck — the `azdo-sync` skill and the four bug agents. **The "four months, four people" figure is a delivery fact about one engagement, not an efficiency benchmark**; it does not change slide 12, and must never be converted into a percentage or a multiple. The three-week cycle came from internal coordination, **not** from a weak client pipeline — do not present it as proof of the CI/CD caveat on slides 3 and 11. |
| 16 | Banking — a client-owned SDLC | **Client reference, in flight — nothing delivered.** The status chip says so and must stay. Its value is that the bank will *own* the process and extend it to its suppliers, which is slide 13 made literal. The one- and two-year efficiency targets are **the bank's objectives**, never presented as Bolt results; nothing usable before 2027. |

---

## 4. Re-derive the volatile numbers — never trust the prose

Counts stated in the repository's own README files are **wrong** (see §6). Always recompute.
Run from the repository root:

```bash
echo "agents:        $(find plugins -path '*/agents/*.agent.md' | wc -l)"
echo "skills:        $(( $(find plugins -name SKILL.md | wc -l) + $(find .boltf/scopes -name SKILL.md | wc -l) ))"
echo "  in plugins:  $(find plugins -name SKILL.md | wc -l)"
echo "  scope-level: $(find .boltf/scopes -name SKILL.md | wc -l)"
echo "plugins:       $(ls -d plugins/*/ | wc -l)"
echo "scopes:        $(ls -d .boltf/scopes/*/ | wc -l)"
echo "templates:     $(ls .boltf/docs/templates/*-template.md | wc -l)"
echo "stacks:        $(ls .boltf/docs/templates/stacks/*-template.md | grep -vc stack-template-template)"  # excludes the meta-template
echo "prompts:       $(ls .github/prompts/*.prompt.md | wc -l)"
echo "workflows:     $(ls .github/workflows/*.yml | wc -l)"
echo "scripts:       $(( $(ls .boltf/scripts/bash/* | wc -l) + $(ls .boltf/scripts/powershell/* | wc -l) ))"
echo "empty plugins: $(for d in plugins/*/; do [ "$(find "$d" -type f | wc -l)" -le 1 ] && basename "$d"; done | tr '\n' ' ')"
```

Test counts come from `tests/README.md` (currently 148 Pester + 12 bats = 160). Re-read that
file rather than re-running the suites, unless you want live numbers:

```bash
pwsh -File ./tests/Run-Tests.ps1 -CI     # Windows only
bash ./tests/run-tests.sh
```

Values as of the stamp in §1: **51** agents · **114** skills (99 + 15) · **9** plugins ·
**9** scopes · **22** templates · **4** backend stack templates · **24** prompts ·
**17** workflows · **62** scripts · **160** tests · empty plugins: `bolt-ai bolt-crm bolt-data`.

---

## 5. Rebuild and re-verify

```bash
PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 npm install --no-audit --no-fund
npm run dev
```

> **The flag is not optional on the Avanade network.** A plain `npm install` hangs fetching
> Playwright's Chromium and then rolls back the entire `node_modules`, so it looks like it did
> nothing. Full explanation in *gotcha 2* below. Drop the flag only if the Playwright CDN is
> reachable from your network.

Then, **every time**:

1. Step through **all 11 slides** at the 980×552 canvas. The theme's authoring rules forbid
   overflow: tighten wording first, then split the slide, then listify, then wrap the block in
   `<div style="zoom: 0.85">`, and only shrink type as a last resort.
2. Confirm each `<AvanadeIcon>` renders — a missing prefix yields a broken-image glyph, not an
   error. Valid prefixes are the filenames under `assets/icons/` in the theme repo.
3. Confirm both Mermaid diagrams render (slide 4 right column, slide 5 left column).
4. Re-export and update the stamp in §1:

```bash
npm run export && npm run export:pptx
```

PPTX renders each slide as a flat image — it is a hand-off format, not an editable deck.

### The fastest way to check every slide for overflow

Don't click through the dev server — the Slidev SPA resists scripted navigation. Export PNGs
and look at them instead. One image per slide, rendered exactly as it will print:

```bash
npm run export:png
```

Scratch folders matching `png-*/` are gitignored and disposable.

**`slide-images/` is committed** — one PNG per slide, named for its content
(`15-ref-automotive.png`), so a single slide can be dropped into another deck without rebuilding
anything. Regenerate it after any visual change; a stale image here is worse than a missing one.

**`public/refs/` holds the three appendix photographs.** They are Avanade brand photography taken
from the theme package (`assets/backgrounds/013`, `006`, `008`), centre-cropped to 4:5 and
recompressed to ~100 KB each. Do not copy the originals in: `008.jpg` alone is 25 MB.

**The PNG export intermittently produces nothing while still printing `✓ exported`.** The cause is
Mermaid on slides 4 and 5 (`Could not find a suitable point for the given distance`); the export
finishes empty rather than failing. **Count the files, never trust the tick** — and re-run, which
usually succeeds:

```bash
npm run export:png && ls slide-images | wc -l   # expect 16
```

### Two environment gotchas, both already worked around

**1. PDF export must use `--per-slide`.** Without it, Slidev's single print-route render
produces a **3 KB PDF with no fonts and no images** — it looks like a success (`✓ exported`)
but the file is empty. `--per-slide` is baked into the `export` script for this reason. Sanity-
check any PDF you produce:

```bash
python -c "import re;d=open('bolt-framework-overview.pdf','rb').read();print(len(d),'bytes')"
```

A healthy export is ~1 MB. If it is a few KB, `--per-slide` was lost.

**2. Playwright's bundled Chromium cannot be downloaded on the Avanade network.** The
post-install download of *Chrome for Testing* times out against the Playwright CDN, and npm then
**rolls back the entire `node_modules`** — so a plain `npm install` appears to do nothing. That is
why the install command at the top of this section carries `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1`.
The dev server never needs Chromium; only the exports do, so point the exporter at a browser
already on the machine:

```bash
npx slidev export slides.md --format pdf --per-slide --output bolt-framework-overview.pdf --executable-path "$LOCALAPPDATA/ms-playwright/chromium-1217/chrome-win64/chrome.exe"
```

Any Chromium works — a cached Playwright build (list them with
`ls "$LOCALAPPDATA/ms-playwright"`) or system Chrome at
`C:/Program Files/Google/Chrome/Application/chrome.exe`. `--executable-path` bypasses
Playwright's browser-revision matching, so the cached build does not need to be the version
Playwright wants. If the CDN is reachable from your network, drop the flag entirely.

> `.claude/launch.json` at the repository root registers this deck as the `bolt-deck` dev server
> so the Claude Code browser pane can drive it. It is a convenience only — nothing depends on it.

---

---

## 5b. The client edition — `slides-client.md`

A shareable cut of the same deck, **14 slides**. It is **assembled from `slides.md` by range
import**, not duplicated:

```md
---
src: ./slides.md#2-8,10,12
---
```

A fix in the internal deck therefore lands in the client edition automatically. Only the closing
slide is defined locally, because its call to action differs. **Do not copy slides into it** — that
is how the two editions silently diverge.

```bash
npm run dev:client          # port 3031, so it can run beside the internal deck
npm run export:client       # bolt-framework-client.pdf
npm run export:client:pptx  # bolt-framework-client.pptx, notes stripped
```

### What is excluded, and why

| Slide | Why it is not in the client edition |
|---|---|
| 9 — One-pager, business developers | Pursuit guidance. Contains "Say this, not that" and the instruction never to claim a percentage. |
| 11 — One-pager, delivery leads | Names the framework's own gaps: no estimation model, uneven scope depth. |

Everything else is in, **including the efficiency slide (12)** — by decision, 2026-09-15. Be aware
of what that means: its own speaker notes call it "the most dangerous slide in the deck" and say to
stop anyone writing the band into a contract. In a leave-behind there is nobody present to say
that. If it ever needs pulling, change the import to `#2-8,10` and nothing else moves.

### ⚠ The PPTX carries speaker notes. Strip them.

Slidev writes every markdown comment into the PPTX as a `notesSlide` part. In this deck those
notes are internal presenter guidance — what not to claim, which objections to pre-empt, which
figures are not measurements. **A client who opens the file in PowerPoint can read all of it.**

`npm run export:client:pptx` runs the stripper automatically. If you export by hand, run it
yourself and check:

```bash
python scripts/strip-pptx-notes.py bolt-framework-client.pptx
```

The script is idempotent, fails loudly if any note survives, and reports how many parts it
removed. The **PDF export is unaffected** — it is rasterised per slide and carries no notes — so
when in doubt, send the PDF.

The internal `bolt-framework-overview.pptx` **keeps** its notes on purpose: they are what makes it
presentable by someone who did not write it. Never send that file to a client.

### Keeping the shared slides client-safe

Slides 7 and 8 were reworked on 2026-09-15 so they could be shared without a separate copy:

- **Slide 7** — "Pre-sales" became "From a requirement", `SME sign-off` became "a named expert
  signs it off", and the configuration strip dropped `plugin` / `MCP tools` for plain language.
  The literal scenario values and scope vocabulary live in §3 and in the slide's notes.
- **Slide 8** — the provenance aside "*Both models are Avanade practice; Bolt documents neither*"
  moved from the slide body into its speaker notes.

**Keep new content on slides 1–8, 10 and 12 client-safe**, or the import stops being usable and
someone will fork the slide instead.

## 6. Known contradictions — do not "fix" the deck back into these

The repository contradicts itself in several places. The deck deliberately uses the verified
value. If a future refresh "corrects" a slide to match a README, it will be making it wrong.

| Topic | What the repo says | What the deck uses |
|---|---|---|
| Agent count | 29 / 30 / 31 / 32 / 36 / "33 Claude + 44 Copilot" across six files | **51** — verified by `find` |
| Skill count | "~58 skills" in the plugin proposal | **114** — verified by `find` |
| Version | `0.2.0` (manifest) · `1.0.0` (tag + CHANGELOG) · `v2.0.0` (root README, initializer banner) · `v2.2.0` (script footers) · `0.1.0` (all plugin manifests) | **`v1.0.0`**, dated 2026-09-02 |
| Bolt duration | "2–3 days" (4 places) vs "1–3 days" (2 places) | **2–3 days** — the dominant figure |
| Licence | `[TBD]` in `.boltf/LICENSE` · `UNLICENSED` in the manifest · `license-CUSTOM` badge · "MIT" in `.boltf/README.md:712` | **Nothing.** The deck makes no licensing claim. |
| Roadmap | `.boltf/PENDIENTES.md` lists testing, Azure DevOps integration, plugins and stack templates as missing — all have since shipped | **Not used.** It is stale (dated 2025-12-16) and is not an official roadmap by its own admission. |
| Avanade org | `ava-group-iberiademos` (manifest, CODEOWNERS, GOVERNANCE) vs `Avanade-Region-Spain` (workflows, issue templates) | Access is referenced **by document** (`REQUEST-ACCESS.md`), never by org handle. |
| Maturity | `.boltf/PENDIENTES.md:124` self-describes as "framework maduro" | **"v1.0.0, actively developed."** |

---

## 6b. Efficiency figures — read the evidence file first

**The claim now exists: slide 12.** It is Gartner-anchored, segmented into three bands, and carries
its preconditions on the slide. Before touching it — or writing any other number anywhere in this
deck — read [`research/efficiency-evidence.md`](research/efficiency-evidence.md): market evidence,
what peer firms actually publish and contract, the counter-evidence with an honest answer to each,
and why the recommended shape is the one on the slide.

The short version: **30% is this market's optimistic ceiling, not its floor.** Gartner projects
25–30% by 2028 for AI applied across the whole SDLC against ~10% for code-focused use; Capgemini
measured 7–18%; Stanford's median is 10–15% and brownfield/high-complexity 0–10%; TCS contracts
10–15% as pass-through. Hence "built to reach it", never "from 30%".

Three standing rules for this slide:

1. **It is an expectation, not a commitment**, and never contractual.
2. **Never cite METR's "19% slower" as current.** METR superseded it on 24 Feb 2026 with −18% and
   −4% estimates, wide confidence intervals, a self-declared unreliable signal, and a statement
   that developers are probably more sped up in 2026. Citing the old headline would be the
   sceptic's version of exactly the error this file warns against.
3. **Neither Avanade nor Accenture publishes an engineering-efficiency percentage** — verified,
   and Avanade has argued in print against the measure. There is no in-house number to contradict,
   and that absence is a stronger line than a borrowed figure. Rule 3 in §7 still holds: there is
   no Bolt measurement, so every figure must be externally attributed on the slide.

## 7. Provenance rules for new content

Non-negotiable, because the deck's credibility is its only real asset:

1. **Every Bolt-specific claim must cite a path in this repository.** If you cannot cite it,
   it does not go on a slide.
2. **Every external claim must carry its source visibly on the slide**, as slide 2 does.
3. **Never publish a metric that is not in one of those two places.** In particular:

   > There is **no** quantified Bolt Framework benefit anywhere in this repository — no ROI, no
   > time saving, no productivity percentage, no customer case study, no adoption count.

   Every percentage in the repo is either third-party technology (Redis, Dapper, Azure
   reservations) or an **illustrative sample output** inside agent documentation — the
   "$8,500/month → $0" in the `@Bolt Retire` docs and the "50% faster response times" in the
   `@Bolt Ops` docs are fictional worked examples describing a hypothetical customer system.
   Reusing either as a Bolt result would be fabrication.

4. **Thresholds are not results.** "Coverage must be ≥ 80% to merge" is a true, checkable
   statement about the framework. "We achieve 80% coverage" is a claim about an engagement and
   needs that engagement's data.
5. **Cite gaps as gaps.** Slides 7 and 10 name the empty Data/AI/CRM plugins and the missing
   estimation model on purpose. Removing those lines makes the deck less persuasive to the
   technical evaluators who will check.
6. **Two comparison caveats.** The repository never mentions GitHub Spec Kit, AWS Kiro or
   "vibe coding" — any competitive contrast is *our* positioning, not a repo-backed claim.
   And `.boltf/analysis/modernization-comparison.md` (2026-06-01) marks legacy discovery and
   equivalence testing as Bolt weaknesses; **both shipped afterwards**
   (`bolt-legacy-analyst`, `skill-characterization-testing`), so footnote that matrix if you
   ever cite it.
7. **The Sprint framing on slides 3, 4, 10 and 11 is ours, not the repository's.** (Slide 10 carries
   the same caveat in customer language — "how fast depends on your pipeline" — and deliberately
   avoids the words Bolt, Sprint and CI/CD, because that page is written for the client.) The repo mentions
   Sprints exactly once — `.boltf/README.md:14`, "replaces traditional sprints" — and says
   nothing about CI/CD maturity as a precondition for the Bolt cadence. The deck deliberately:
   (a) **elides that clause** from the quoted definition on slide 3, because a Bolt is a delivery
   cadence, not a replacement for the client's Sprint container; and (b) states that validating an
   increment every 2–3 days needs a solid CI/CD harness, and that where the client lacks one the
   Bolts should be wrapped in **very short Sprints**. That is Avanade delivery positioning, held
   deliberately. Do not "restore" the README wording on a future refresh.

   House style: **"Sprint" is always capitalised** in this deck — it names the Scrum container,
   not a generic period of work.
8. **The eight cognitive stages are off the slides on purpose. Do not put them back.** An earlier
   draft of slide 4 claimed they "tag what each agent is actually doing". That is false: the
   stages appear only as an ASCII box in `.boltf/README.md:25-40`, the string `cognitive` appears
   in **no agent file at all**, and exactly **4 of the 24 prompts** declare a stage
   (`bolt-business-analysis` → PERCEIVE, `bolt-domain-modeling` → ANALYZE, `bolt-code-generation`
   → EXECUTE, `bolt-test-generation` → VALIDATE). Verify with
   `grep -ril cognitive plugins .claude/agents`. The concept is also unexplainable in one bullet —
   the audience cannot tell where the stages come from or what they buy — so it lives in the
   speaker notes for slide 4 and nowhere else. If the framework ever wires the stages into the
   agents, this becomes a real claim and can come back.
9. **"Discovery only — the gate is human: SME sign-off" (slide 7) is ours.** The repository uses
   "SME" only for the access-review team (`REQUEST-ACCESS.md:26,68`) and names HITL checkpoints only
   in the modernization command (`.claude/commands/modernize-legacy.md:29,43-78`). Nothing states
   that a discovery-only engagement is gated by SME sign-off — it is how we run it, and it answers
   the otherwise unanswerable question "what assures quality when the entry point produces no code
   and therefore trips no automated gate?". Keep it, and keep it labelled as positioning.
