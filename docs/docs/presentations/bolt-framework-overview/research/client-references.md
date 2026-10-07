# Client references — intake and provenance record

The deck carries three anonymised client references as an **appendix, slides 14–16** — one slide per engagement, two columns, with Avanade brand photography on the right. They sit after the close so the main flow stays at 13 slides. This file is where their facts
live, who vouches for each one, and what was checked before they went on a slide.

**Why this file exists.** `REFRESH.md` §7 rule 3 says there is no customer case study anywhere in
the framework repository, and forbids publishing a metric that is not traceable to a repo path or
an external source. Client references are neither. They are therefore only as good as the record
behind them — this record.

---

## On-slide structure

Four fields per reference, agreed 2026-09-11. Deliberately **no client size, no region, no named
stack**: the descriptor is the sector alone, which keeps re-identification risk near zero and in
most cases removes the need for client sign-off.

| Field | Rule |
|---|---|
| **Sector** | Sector only. No size, no country, no revenue band. If the sector is narrow enough that one company is obvious, widen it. |
| **SDLC phase** | Use the exact phase names from slide 4 — `INCEPTION`, `DISCOVERY`, `CONSTRUCTION`, `TRANSITION`, `PRODUCTION`, `RETIREMENT` — so the references reinforce the lifecycle rather than introduce new vocabulary. More than one phase is fine. |
| **Problem** | One sentence. What was actually wrong or needed, in the client's terms, not ours. |
| **Solution** | What Bolt supplied, named as **mechanisms**: constitution, feature specs with acceptance criteria, quality gates, drift detection, equivalence gate, Azure DevOps sync. Avoid adjectives — "governed", "accelerated" and "robust" say nothing a sceptic will accept. |

**Optional fifth line, only where it is verifiable.** Something that was produced or that held —
"9 Bolts over 11 weeks", "coverage stayed ≥80% on every merge", "14 ADRs". Not a percentage
improvement, unless §"Numbers" below is satisfied in full.

**Selection rule.** The three should cover **different SDLC phases** between them. Three
references to the same phase spend a slide repeating one argument.

---

## Governance fields — recorded here, never on the slide

For each reference, all seven must be answered before it ships:

1. **Real client and engagement code** —
2. **Who vouches for it** (name, role) — the person a reviewer can ask
3. **Engagement dates** —
4. **Re-identification check** — could an informed audience name this client from the sector alone? Who checked?
5. **Client approval** — needed? obtained? by whom, on what date? (Sector-only descriptors usually do not need it; record the judgement either way.)
6. **Limitation** — one thing that did not go well, or a caveat. Three flawless cases read as marketing; the deck's voice names gaps on slides 7, 8 and 10, and these should match it.
7. **Source of any number quoted** — baseline, method, who measured. No baseline, no number.

---

## Timeline constraint — read before writing anything

Bolt Framework's initial release is **2026-05-31** (`.boltf/CHANGELOG.md`), and `v1.0.0` is dated
**2026-09-02** (`CHANGELOG.md`). That is roughly three and a half months. Anyone who opens the
changelog can do that arithmetic, so:

- Frame these as **early adoptions or pilots**, not completed transformations, **or**
- If the engagement predates the release, say so and lean on the `0.1.0` entry
  *"Framework rebranding to Bolt Framework"* — the methodology existed earlier under another name.
  Record the predecessor name in the notes below.

Claiming a mature, measured, multi-year outcome inside this window is the fastest way to lose the
room.

---

## Reference 1 — legacy migration, enrolment system

Supplied 2026-09-11.

| Field | Value |
|---|---|
| Sector | **Higher education** |
| SDLC phase | `DISCOVERY` → `CONSTRUCTION` → `PRODUCTION` |
| Problem | A VB6 enrolment system had to be replaced, and the functional knowledge that defined it lived with its users rather than in any documentation. |
| Solution | Bolt's legacy agents read the source, the documentation and the database to recover the schema and the business rules — expressed as Given/When/Then, which become the executable tests the rebuild is checked against. The rebuild then ran as governed Bolts: .NET 8 microservices over Oracle, Clean Architecture with domain events, and an Angular 16 front end built on **Atomic Design**, with GitHub Copilot as the client-side tool. The same process now runs corrective and evolutive maintenance. |
| Verifiable outcome *(optional)* | **The functional knowledge exists in writing again** — recovered from the code and the users into business rules and specifications, so the system no longer depends on who is still in the building. Secondary: runs on Azure, scaling up for enrolment peaks and back down in the off-season. |

> **This is the headline of the column, confirmed by the deck owner 2026-09-11.** The migration is
> the visible part; recovering the functional knowledge is the durable one. It answers the problem
> as stated, it removes key-person risk for the client, and it is the mechanism the framework
> actually documents — `bolt-legacy-analyst` extracts business rules as `RULE-NNN` in
> Given/When/Then, which then live on in feature specs and acceptance criteria.
>
> It also makes this reference the working proof of the closing slide: *"an operating model, not a
> tool — the specifications, decision records and tests stay in your repository."* Here that is not
> a promise, it already happened. Consider referencing it when presenting the close.

**Governance**

| | |
|---|---|
| Real client / engagement code | *Spanish private university — real name not recorded here; engagement code pending* |
| Who vouches | **No single named owner** — team-owned (deck owner, 2026-09-11). See the traceability note at the end of this file. |
| Dates | **Not published**, by decision. The origin framing below makes them unnecessary. |
| Re-identification check | Descriptor reduced to *Higher education*; see risk note |
| Client approval | Not needed with a sector-only descriptor |
| Limitation | **Building part of the framework at the same time as delivering the project.** Honest and specific — and it follows directly from this being the origin engagement. |
| Source of any number | No numbers claimed. Good. |

### This is the origin engagement

**Confirmed by the deck owner 2026-09-11: the framework began to be built because of this
project.** That is the most important fact in this file, and it changes how the reference should
be presented.

- **The timeline objection dissolves.** The obvious challenge — a full VB6 → .NET 8 rebuild
  cannot fit inside a framework released on 2026-05-31 — has a clean answer: the engagement came
  first and the framework was extracted from it. This also explains the `0.1.0` changelog entry
  *"Framework rebranding to Bolt Framework"*: the practice existed before the name did. **Present
  this actively rather than waiting to be asked.**
- **It is a stronger claim than "we used our framework here".** Bolt is not a methodology invented
  in a workshop and then looked for somewhere to apply; it was extracted from a real, hard
  brownfield migration with the functional knowledge missing. That is the answer to "is this
  theoretical?", and it is worth more than any percentage.
- **The honest caveat, which the presenter should own before anyone else raises it:** a framework
  validated on the engagement that produced it is not independent evidence. References 2 and 3
  carry that burden — they are what show it transfers beyond its birthplace. Choose them with
  that job in mind, and consider ordering the slide origin-first, then transfer.

### Open questions on this reference

1. **Equivalence gate — resolved, with a deliberate limit on the wording.** The deck owner asked
   for it to be implied. The slide therefore states what is demonstrable — the recovered rules are
   written as Given/When/Then and become the tests the rebuild is checked against — and lets the
   reader draw the conclusion. It does **not** assert the formal equivalence gate or its
   thresholds (≥95% parity pass rate, 100% of P0 behaviour characterised), because no evidence
   for those numbers was supplied. If a client asks "did you reach 95% parity?", the presenter
   must be able to answer; claiming the gate on the slide would remove that option.
3. **"ACID" — resolved.** It was a typo for **Atomic Design**, the component methodology used on
   the Angular front end. Now recorded in the solution field.
4. **Constitution and scopes.** Was a constitution ratified, and which scopes were active
   (`backend`, `frontend`, `cloud-platform`)? Naming the mechanism is stronger than naming the
   stack.

### Risk note — re-identification

The brief says *Spanish private university*. Spain has a small enough set of private universities
that sector + country + "enrolment tool migration" is plausibly identifiable in a Spanish room —
which is exactly the audience for this deck. The agreed rule is **sector only**, so the slide
says *Higher education* and drops both the country and "private". Keep it that way unless the
client has approved being named.

---

## Reference 2 — support agent, dealership network

Supplied 2026-09-11.

| Field | Value |
|---|---|
| Sector | **Automotive** |
| SDLC phase | `INCEPTION` → `PRODUCTION` — the full lifecycle, from ratifying the constitution to running in production |
| Problem | A large, highly heterogeneous dealership network generated a support volume the team could not absorb, and lead times stretched badly. Reopened and reassigned tickets were a large part of the cost. |
| Solution | A new end-user agent that guides people as they raise ServiceNow requests, so tickets arrive correctly formed and stop bouncing between support teams. Built greenfield under Bolt from the constitution onwards — heterogeneous microservices in Python and Node.js with a React front end, on Azure, run through Azure DevOps and Pipelines. **Integrated with ServiceNow** for ticket creation and routing, and built on **Azure AI Foundry** as the model and agent platform. |
| Verifiable outcome *(optional)* | **From zero definition to production in four months with a team of four.** No measured effect on reopenings, reassignments or lead time has been supplied; do not claim one without a baseline. |

**Governance**

| | |
|---|---|
| Real client / engagement code | *Automotive multinational — real name not recorded here; engagement code pending* |
| Who vouches | **No single named owner** — team-owned |
| Dates | **Not published**, by decision |
| Re-identification check | Low risk at sector-only. ServiceNow is ubiquitous and safe to name. |
| Client approval | Not needed with a sector-only descriptor |
| Limitation | **Response-time commitments force the team to balance project work against support load.** |
| Source of any number | **4 people / 4 months / zero starting definition** — a delivery fact, owner to be named. Everything else needs a baseline: if a reopening- or lead-time figure is later supplied, it needs a pre-agent measurement, a method and a named owner before it goes on a slide. |

### The outcome, and the line not to cross

Two halves of the brief behave very differently, and only one of them belongs on the slide.

**On the slide — the fact.** *From zero definition to production in four months with a team of
four*, for a polyglot microservice estate with an AI agent and a ServiceNow integration. It is
concrete, checkable, and carries no methodological risk. It is also more persuasive than any
comparison: anyone in the room who has run a delivery will do their own arithmetic, and a
conclusion the audience reaches itself is worth more than one asserted at them.

**In the speaker notes, attributed — the counterfactual.** *"Without the process and the AI
support Bolt provided, this would have taken more people and more months."* That is the delivery
team's professional judgement, and it is a perfectly reasonable thing to say out loud when
someone asks "compared with what?". It is **not** a measurement: there is no control project, no
baseline and no counterfactual anyone observed. So:

- Say it as a judgement, owned by the team. Never as a finding.
- **Never quantify it.** The moment it becomes "half the people" or "twice as fast", it is an
  invented metric in a deck whose entire credibility rests on not having any — and it would
  directly contradict slide 12, which states that Bolt publishes no efficiency measurement of
  its own.

**Why this does not change slide 12.** One engagement, no baseline, no control, is not an
efficiency measurement; it is an anecdote with good numbers attached. The Gartner anchor stays.
What this *is*, though, is the first real data point toward the open decision in §8 of
[`efficiency-evidence.md`](efficiency-evidence.md) — whether the assessment should start
capturing delivery metrics. Capture four or five engagements like this with a pre-agreed baseline
and the "measured against your own baseline" claim becomes available for the first time. Worth
recording that this is where such an evidence base would start.

**Note the pairing with reference 1.** Both cases are "we did not know what to build" problems —
one because the knowledge sat with users, the other because there was no definition at all — and
both were solved by the same specification machinery. That is a stronger through-line for the
slide than three unrelated success stories, and it is the deck's actual thesis.

### This is the transfer case

Reference 1 is the engagement Bolt was extracted from, so it cannot prove the framework travels.
This one can, and it differs on every axis that matters: different sector, greenfield rather than
migration, a different stack (Python / Node.js / React against .NET / Angular), and Azure DevOps
rather than GitHub. Present it second, immediately after the origin case.

It is also the only reference that covers the **whole lifecycle** — constitution through
production — which is the claim slide 4 makes and that nothing in the deck currently corroborates.

### What it corroborates that the deck currently only asserts

- **Azure DevOps integration — CONFIRMED in use.** The `azdo-sync` skill itself was used, not
  merely ADO as the client's tooling. Slide 11's bidirectional spec-to-work-item claim now has a
  real engagement behind it.
- **The bug-management agent family.** The team is now adapting triage, prioritisation,
  root-cause analysis, impact analysis and bug fixing. That maps almost one-to-one onto the
  framework's four bug agents (`bolt-bug-tracker`, `bolt-bug-troubleshooter`,
  `bolt-regression-test`, `bolt-bug-fixer`) — **confirmed in use on this engagement**. They
  appear **nowhere in the deck today**, which is now a gap worth closing: a live capability with a
  real reference behind it and no mention on any slide.
- **Scenario adaptation.** A polyglot microservice estate exercises the per-scope provisioning
  claimed on slide 7.
- **The `ai` and `integration` scopes, in real use.** Azure AI Foundry as the agent platform and
  ServiceNow as the integration target are exactly what those two scopes exist for. Note the
  nuance before anyone calls it a contradiction: slide 7 says Data, AI and CRM have **scope
  definitions but little packaged plugin content**, and that remains true — `plugins/bolt-ai/`
  holds only a manifest. The scope definition, its constitution slice and its MCP tooling are
  what got used here; the vendored plugin content is what does not exist yet. Both statements
  hold at once, and the reference is evidence the scope model works even where the plugin is
  still empty.

### ⚠ Cadence conflict — resolve before this reaches a slide

The brief describes **three-week iterative cycles** covering analysis, design, construction,
testing and deployment to UAT. The deck states on slides 3, 4 and 11 that a Bolt is a **2–3 day**
micro-iteration, 4–6 per feature. Putting "three-week cycles" on a reference slide two pages
later reads as a contradiction to anyone paying attention.

Two readings, and they need different wording:

1. **Bolts run inside the three-week cycle**, and the three weeks is the client-facing increment —
   the UAT drop and their release rhythm. If so, say exactly that: it *demonstrates* the caveat
   the deck already carries ("where the client's pipeline cannot take the cadence, the Bolts stay
   and the cycle around them absorbs it") instead of contradicting it. This is the strongest
   version and probably the true one.
2. **The 2–3 day Bolt cadence was not used**, and delivery ran on three-week iterations. That is
   still a legitimate engagement, but the slide must not imply Bolt cadence, and it becomes
   evidence for the CI/CD-harness caveat rather than for the cadence claim.

**Resolved (deck owner, 2026-09-11): reading 1 — the Bolts ran inside the cycle.**

With one correction that matters. The three-week rhythm comes from **internal coordination**, not
from a client pipeline unable to take the cadence. So this reference must **not** be presented as
evidence for the CI/CD-harness caveat on slides 3, 4 and 11 — that caveat has a different cause.
The accurate wording is simply: Bolts inside the cycle, the cycle set by coordination.

---

## Reference 3 — an AI-supported SDLC the client owns

Supplied 2026-09-11. **In flight — not a delivered outcome.**

| Field | Value |
|---|---|
| Sector | **Spanish bank** — country kept, ranking dropped (deck owner, 2026-09-11) |
| SDLC phase | `INCEPTION`, at enterprise scale — the bank ratifies the governing process itself, rather than one project's constitution |
| Problem | Development is spread across internal teams and a supplier ecosystem with no common process. The bank wants one AI-supported SDLC that applies to both, and — the part that matters — **that the bank itself owns**. |
| Solution | Bolt Framework as the base for that process, adapted to the bank's tools and requirements, on GitHub end to end. Delivered jointly with Accenture, starting from the client's VDI setup and continuing into the definition of the AI-supported SDLC flow. |
| Verifiable outcome *(optional)* | **None yet, and the slide must say so.** The bank's own objective is efficiency in time-to-market and cost, assessed at one and two years. That is the client's target, not a Bolt result. |

**Governance**

| | |
|---|---|
| Real client / engagement code | *Spanish bank — real name not recorded here; engagement code pending* |
| Who vouches | **No single named owner** — team-owned |
| Dates | **Not published**, by decision |
| Re-identification check | Ranking dropped; see note below |
| Client approval | **Cleared for anonymous reference** (deck owner, 2026-09-11) |
| Limitation | **Every step is audited and reviewed with security.** The flow is agreed and clear, but progress moves at the pace that review allows. |
| Source of any number | No Bolt numbers. The 1- and 2-year efficiency goals are the **bank's objectives** and must be attributed to the bank, never presented as what Bolt delivers. |

### Why this is the most valuable of the three — and the most fragile

**Valuable.** It is the closing slide made literal. The deck ends on *"an operating model, not a
tool — it transfers with the work"*. Here the client does not merely receive the artifacts: the
bank **owns the process** and extends it to its own suppliers. That is transfer taken to its
logical end, and no amount of argument on slide 3 makes that point as well as one bank doing it.

It also completes the tooling spread across the three references — GitHub Copilot, Azure DevOps,
and now GitHub end to end — which is the dual-client claim on slide 3 demonstrated rather than
asserted.

**Fragile.** Nothing has been delivered. The verbs in the brief are future tense. Presented
alongside two finished projects it will be read as a third success unless the slide marks it
clearly as underway. **Recommend a status marker on all three columns** — *delivered · in
production · underway* — so the audience calibrates without the presenter having to disclaim it.

### Re-identification — resolved to "Spanish bank"

The brief originally said *Spanish bank, top 5*. **The ranking is dropped** (deck owner,
2026-09-11): sector + country + rank is a set of five in front of a largely Spanish audience,
describing a **live** engagement that also involves Accenture — a riddle with five answers and a
strong hint. Without the ranking the candidate set is large enough to be defensible.

Still worth confirming with the account team before this appears anywhere, because the
engagement is in flight rather than finished.

**Consistency flag for the slide.** This now makes the three descriptors uneven — *Higher
education*, *Automotive*, *Spanish bank*. Only one carries a country, and a Spanish audience will
notice that the bank is the localised one. Two ways to even it up, both fine:

- **Localise all three** — *Spanish university*, *automotive multinational*, *Spanish bank*.
  More relatable for a domestic audience, and it costs nothing in re-identification terms:
  dropping "private" from the university widens that set considerably, and the automotive client
  is already described as multinational.
- **Keep sector only for all three** — *Higher education*, *Automotive*, *Banking*.

Currently the record holds the mixed version, as instructed. Flagging it rather than silently
aligning the other two.

### The efficiency connection — worth tracking

The bank will measure time-to-market and cost at one and two years. That is exactly the
pre-agreed baseline that
[`efficiency-evidence.md`](efficiency-evidence.md) §8 lists as the one still-open decision —
whether the assessment should capture delivery metrics so a client-specific claim becomes
possible.

If this programme measures on the bank's own baseline, it is the first engagement capable of
producing a defensible Bolt efficiency figure. Two cautions: the figures will belong to the bank
and need their permission to cite, and one- and two-year horizons mean **nothing usable before
2027**. Until then slide 12 stays on the Gartner anchor.

---

## Status

**Shipped 2026-09-11 as slides 14–16**, an appendix after the close. All four on-slide fields are
answered for all three references, and the governance fields are answered except where recorded
as a deliberate decision: **no named individual vouches** for any of the three (team-owned) and
**no dates are published**. Both were the deck owner's call.

The residual risk that carries: if a claim is challenged in the room, there is no named owner to
route the question to. Acceptable for an internal deck; worth revisiting before any of this is
used with a client who might ask for a reference call.

Nothing here is invented, and nothing should be: no client reference exists anywhere in the
framework repository, so this file remains the only source for what the deck claims about
engagements.
