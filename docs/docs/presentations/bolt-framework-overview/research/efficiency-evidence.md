# Evidence base for a lifecycle-efficiency claim

> Compiled 2026-09-10 for the Bolt Framework overview deck. Every figure below carries its source
> and date. Nothing here is a Bolt Framework measurement — **no such measurement exists**
> (`REFRESH.md` §7 rule 3). This file exists so that any number that ever reaches a slide can be
> traced to somebody who actually measured something.

## Executive summary

The business wants to state **"from 30% efficiency across the lifecycle, more depending on the
development model"**. The evidence does not support that shape of claim, for one specific reason:
**30% is the optimistic ceiling of this market, not its floor.**

- The leading analyst anchor for a whole-SDLC figure is Gartner's **25–30% by 2028**, contrasted
  with ~10% for code-focused use. It is a forward-dated projection, not a present-day floor.
- The only large-scale *measured* blended figure from a peer firm is Capgemini's **7–18%**.
- The only figure any firm states for what a client **actually receives** is TCS's **10–15%**
  pass-through — and TCS's own analyst framing puts the pre-AI productivity norm at 3–5% annually.
- The strongest contrary evidence is METR's RCT: experienced developers on mature repositories were
  **19% slower** with AI tools.

So the credible band for a blended lifecycle claim today is roughly **7–18%**, with 25–30% available
as a *target* if — and only if — it is attributed to Gartner and framed as what applying AI across
the whole lifecycle can reach, rather than as what Bolt delivers on day one.

**Four independent methods converge on low double digits**, which is the single strongest signal in
this whole file: Thoughtworks' Amdahl-style decomposition (10–15% estimated, **~8% measured** in
their worked case), Stanford's ~100k-developer commit study (median 10–15%), Capgemini's survey
(7–18%), and TCS's contracted pass-through (10–15%). Different instruments, same neighbourhood.

**Neither Accenture nor Avanade publishes an engineering-efficiency percentage** (§3.5). That
removes the risk of contradicting our own house — and hands us a stronger line than any borrowed
number.

The recommendation is therefore: **anchor on Gartner, segment the band, publish the preconditions as
a capability list, and name the measurement method.** Detail in §5.

---

## 1. What the direct antecedents publish: nothing

This is the most important structural finding, because these are the offerings Bolt most resembles.

| Offering | Quantified lifecycle claim | Source |
|---|---|---|
| **AWS AI-DLC** — founding blog | **None.** Qualitative only: "complete tasks in hours or days that previously took weeks" | `aws.amazon.com/blogs/devops/ai-driven-development-life-cycle/`, 31 Jul 2025 |
| **AWS AI-DLC** — open-sourcing post | **None** | 29 Nov 2025 |
| **AWS AI-DLC** — `awslabs/aidlc-workflows` | **None.** Only an AI-fallibility disclaimer | repo, main |
| **GitHub Spec Kit** | **None** — self-labelled "Experimental Goals" and "hypotheses" to be "validated" | `github.com/github/spec-kit` |
| **AWS Kiro** | **None** from the vendor; customer testimonials only | `kiro.dev` |
| **Tessl** | **None** at lifecycle level; see §4 | `tessl.io` |

The AI-DLC multiples that circulate ("10–15x productivity gains", Wipro "three months of planned
work into about 20 hours") exist **only in a re:Invent talk (DVT214, Dec 2025)** and secondary
write-ups. AWS never put them in writing. The secondary source that reports them appends its own
rebuttal: *"directionally interesting, unverified in your context, produced by teams with every
incentive to pick amenable projects… Nobody has published the failure cases yet."*

**Implication for Bolt:** repeating a number that the antecedent we credit declined to publish is a
specific and easily-caught vulnerability.

---

## 2. Independent and analyst measurement

Ordered by defensibility: RCT and telemetry first, self-report last.

| Source | Figure | Scope | Method | Date |
|---|---|---|---|---|
| **METR** | **−19%** — developers took *longer* with AI. Devs forecast +24% and still believed +20% afterwards | Experienced OSS devs, mature repos | **RCT**, 16 devs, 246 real issues, CI +2% to +39% | 10 Jul 2025 |
| **METR — currency correction** | METR has **walked the 19% forward**: −18% (CI −38% to +9%) for returning developers and −4% (CI −15% to +9%) for new ones, while calling its own new data "an unreliable signal" and stating it believes developers "are more sped up from AI tools now — in early 2026". **Do not cite "19% slower" as the current state of the evidence** | Same design, 57 devs, 143 repos, 800+ tasks | RCT follow-up | **24 Feb 2026** |
| **METR — survey bias, quantified** | People "overestimated AI's effect on their time spent on tasks by **40 percentage points on average**"; "public estimates of productivity impacts from surveys have tended to be greater than those from field experiments" | Self-report bias | Survey, ~2% response rate | 11 May 2026 |
| **Thoughtworks** | *"The claim that coding assistants can increase delivery speed by 50% is a wild overestimation. **Our tests suggest the gains are more likely 10–15%**"* — 5–15% across teams, and **~8% measured cycle-time improvement** in their worked case | **Whole delivery cycle time**, not coding-only | **Yes** — Amdahl-style decomposition: coding share of cycle time (55%) × share of tickets assisted × per-task speedup | 18 Feb 2025 |
| **Accenture × GitHub** | +8.69% PRs; +15% merge rate; +84% successful builds; ~30% suggestion acceptance | Coding only | **RCT** with control group, DevOps telemetry | 13 May 2024 |
| **GitHub** | **55% faster** | **One synthetic task** (an HTTP server in JS) | RCT, 95 developers | 7 Sep 2022, upd. 21 May 2024 |
| **Stanford** (Denisov-Blanch) | Median **10–15%**. Greenfield/low ≈30–40%; greenfield/high ≈10–15%; brownfield/low ≈15–20%; **brownfield/high ≈0–10%** | Coding, segmented | ~100k developers, expert-panel commit scoring | ongoing; per-cell figures reported from talks — **verify before quoting a cell** |
| **McKinsey** | Documentation **45–50%**; code generation **35–45%**; refactoring **20–30%**; **"less than 10%" on high-complexity tasks** | **Per task type** | Lab of 40+ developers over several weeks | Jun 2023 |
| **Gartner** | **"By 2028, teams that apply AI across the SDLC will achieve 25 to 30 percent productivity gains, compared to the 10 percent typically seen with code focused use."** Also: nearly half of developers currently see ≤10% | **Whole SDLC** | Analyst projection | *How to Capture AI-Driven Productivity Gains Across the SDLC*, doc 1-2LHXLGYN, 11 Apr 2025 |
| **DORA / Google Cloud** | No benefit %. AI is an **amplifier**: it magnifies both strengths and dysfunctions. Adoption raises throughput **and** instability | Whole lifecycle | Research programme | 2025 State of AI-assisted Software Development |
| **DORA ROI report** | Modelled 500-person org: ≈**39% ROI**, ~8-month payback. Names a **"J-curve"** dip during adoption | Whole org | Modelled scenario with stated prerequisites | 2026.01, May 2026 |
| **DX** | **4–6 hours/week** saved; >50% of code AI-generated; DXI fell 67→65; change confidence −6.1%; gains "highly uneven" | Per developer | 500+ teams, DX Core 4 | Q2 2026, 22 Jul 2026 |

### The counter-evidence, and the honest answer to each

| Objection | Honest answer |
|---|---|
| "METR measured a 19% *slowdown*." | Correct, and it is the best-designed study in the field. It measured **ungoverned** AI use by experts on mature code — precisely the mode Bolt exists to replace. Cite it, do not hide it. |
| "The 55% Copilot figure is one toy task from 2022." | Agreed. It is 95 developers writing one HTTP server in JavaScript. It is not lifecycle evidence and should not appear on a slide. |
| "Gains vanish on complex work." | True and published: McKinsey <10% on high-complexity; Stanford 0–10% on brownfield/high. This is why the claim must be segmented. |
| "Time saved ≠ money saved." | Capgemini says so explicitly: *"saving time using generative AI tools is significantly different from saving cost. Assessing cost savings was not a part of the scope of this research."* |
| "Adoption isn't impact." | Capgemini's 2026 POV: *"Surveys often count any interaction with AI tools as 'adoption', even if usage is superficial… Productivity claims should be viewed through a critical lens."* |

---

## 3. What peer firms publish

### 3.1 The headline comparison

| Firm | Blended / lifecycle figure | What it actually is |
|---|---|---|
| **Capgemini Research Institute** | **7–18%** | Measured survey, n=412 software leaders scaling gen AI |
| **TCS** | **10–15%** | **Productivity passed to the client**, stated on an earnings call |
| **Infosys** | 80–90% | **Database code generation only** — not a lifecycle figure |
| **IBM** | "up to 50%", "averaging 45%" | Internal IBM developers / IBM consultants |
| **EPAM** | "Deliver solutions 30% faster" | Flat point estimate, **no hedge, undated page** |
| **Globant** | "**At least 30%** more productive than the typical engineer-plus-AI approach" | Delivery model vs a stated comparator, not lifecycle |

### 3.2 Scope substitution — the dominant move, and the trap to avoid

**The largest percentages are always attached to the narrowest, most mechanical scope**, and the
number shrinks by roughly an order of magnitude as scope widens to the full lifecycle.

Infosys demonstrates this against itself, in two of its own documents:

| Infosys document | Figure | Scope |
|---|---|---|
| *Agentic AI in software development* perspective | **80–90%** improvement | Database **code generation** |
| " | 60–70% | API and microservice generation |
| " | up to 60% | UI code generation |
| *The impact of AI in the SDLC* (Infosys BPM, © 2025) | Developer **20–30%** effort reduction | **Per role, across the SDLC** |
| " | Business analyst **5–10%**, Solution architect **5–10%**, Tester **5–10%**, Project manager **10–15%** | " |

Same firm, same year: 80–90% for one artefact type, 5–30% once you look at the whole lifecycle.

### 3.3 Per-phase breakdowns — only three firms publish one, and two agree

| Phase / role | Capgemini (max / avg) | Infosys (effort reduction) |
|---|---|---|
| Documentation | 35% / 10% | — |
| Coding | 34% / 9% | Developer 20–30% |
| Debugging + testing | 20% / 5% | Tester 5–10% |
| Project management | 20% / 1% | PM 10–15% |
| Business analysis | — | 5–10% |
| Architecture | — | 5–10% |

Both put **coding at roughly 2–4× every other phase**, and both put **testing at the low end** —
which contradicts the common vendor pitch that testing is where AI pays off fastest.

Capgemini's construction matters: the 7–18% band is **not an average**. It is a 20th–80th
interpercentile band, so 40% of respondents fall outside it by construction. Its "maximum" column is
the 95th percentile; the "average" column is the statistical mean. Note also that Capgemini's later
restatement (16 Apr 2025) silently dropped both *"as per early estimates"* and *"across the SDLC"*.

### 3.4 What actually gets committed contractually

| Firm | Position |
|---|---|
| **TCS** | The only firm with a number on what the client receives: *"the productivity gain passed on is around 10% to 15% range"*, plus *"we are able to offer a **front loaded commitment** to our customers which we are able to balance it out, to smoothen it out over the term"* — TCS carries the timing risk. Q1 FY27 call, 9 Jul 2026 |
| **Infosys** | Explicitly refuses to quantify: *"we do not quantify that compression part externally… internally, we track it"*. Guard rail: *"we are not going to underwrite uneconomic productivity assumptions."* Q1 FY27, 23 Jul 2026 |
| **Globant** | Changes the pricing **unit** (pay for validated outputs, not hours) but attaches no guarantee |
| **IBM, Capgemini, EPAM** | No contractual productivity commitment published |
| **Market context** | Outsourcers "often promise 40%-70% productivity gains" in marketing (InformationWeek, 28 Apr 2026), while buyers push gain-share clauses. Mayer Brown (17 Feb 2026): *"Providers will generally not accept warranties of perfection in delivery of services."* |

Analyst context from the same TCS call: the **pre-AI norm was 3–5% productivity annually**. So
10–15% is roughly 2–4× the historic ratchet — not an order of magnitude.

### 3.5 Accenture and Avanade — the answer to "does our own house already have a number?"

**No, and that is a finding, not an absence of evidence.**

**Avanade publishes no efficiency percentage for AI-assisted software engineering.** The flagship
AI-SDLC service page ("Build and modernize applications") markets *"GitHub Copilot, AI-Enabled SDLC
and modern architecture practices"* with purely adjectival benefits — "streamline development, boost
productivity" — and no number. More usefully, Avanade published an article arguing **against**
measuring copilots this way:

> *"It's tempting to measure its worth merely in terms of time saved, but this perspective is
> limited… the real value of generative AI isn't in efficiency… it isn't productivity you're buying
> — it's dramatically different outcomes for your business."*
> — Diana Wolfe, *How not to measure the success of an AI copilot*, avanade.com, 19 Oct 2023.
> The same piece volunteers a negative: "cognitive fatigue is also increasing".

The Trendlines AI Value Report 2025 measures **client expectations** (69% of decision-makers use
productivity gains as their primary value driver), not Avanade's delivery.

> ⚠️ **Search hazard:** engines conflate **Avanade** with **Avenga**, an unrelated firm. The
> "10–20% per person / 50% faster software delivery across the SDLC" figure that surfaces under an
> Avanade query is **Avenga's**. Do not reuse it.

**Accenture quantifies the client, never itself.** Across three consecutive earnings calls it cites
precise client outcomes (lead accuracy 13%→97%, campaigns 55% faster, content teams 40% more
productive) and never once quantifies its own software-engineering delivery efficiency. Asked
point-blank by a Citi analyst how productivity savings are passed on, Julie Sweet confirmed the
contractual mechanism exists and declined to size it:

> *"we're signing contracts that depend on our use of more technology over time to provide
> productivity. And so, that's still the commercial model of the industry right now."*
> — Q1 FY2026 call, 18 Dec 2025. Angie Park adds the structural answer: ~60% of FY25 work was
> fixed-price, up ~10 points in three years.

And the quotable framing from Q4 FY2025 (25 Sep 2025):

> *"we don't see AI as deflationary… Yes, AI absolutely boosts efficiency in areas like coding or
> operations, but those savings don't disappear. They're being reinvested into new priorities."*

Technology Vision 2025 follows the same rule: thirteen percentages, all executive **opinion**, none
measured engineering output.

**Consequence for Bolt:** there is no in-house number to contradict — and the stronger line is
available to us precisely because of that. *"Accenture's own joint venture publishes no engineering
efficiency percentage, and published an article explaining why it shouldn't"* is more defensible in
front of a client-side architect than any figure we could borrow.

### 3.6 The Accenture Copilot trial — read the paper, not the blog post

The "Accenture RCT" everyone cites is GitHub's blog write-up (+8.69% PRs, +15% merge rate, +84%
successful builds). The academic version — Cui, Demirer, Jaffe, Musolff, Peng & Salz, *The Effects
of Generative AI on High-Skilled Work*, MIT, Feb 2025, pre-registered AEARCTR-0014530 — reports the
**Accenture-specific** panel very differently:

| Measure | Accenture result |
|---|---|
| Pull requests | **+17.94% (SE 18.72)** — statistically indistinguishable from zero |
| Commits | **−4.48% (SE 21.88)** |
| Builds | +92.40% (SE 26.78) |
| **Build success rate** | **−17.40% (SE 7.12)** — a significant *decline* |

The authors' own reading: *"developers may engage in more trial-and-error coding… Such a change in
coding style could lead to lower-quality code in the long run."* Sample was **n=320 developers in
Southeast Asia over four months** — not the "12,000 developers" that circulates in secondary
write-ups, which is a deployment-scale figure. A second Accenture experiment produced −39.18%
(SE 36.78) on completed pull requests.

Pooled across all three firms the paper reports **+26.08% (SE 10.3)** completed tasks — that pooled
number is the defensible one, and it is coding output, not lifecycle efficiency.

### 3.7 Where the technical depth is greatest, the numbers disappear

Publishing **no** software-engineering productivity figure: Infosys Topaz overview, its *SDLC Agent
Framework* and *AI-Native SDLC* papers, its AI First Value Framework release and its Cognition/Devin
partnership release; **TCS's entire marketing corpus** (WisdomNext launch, results releases, the
Anthropic partnership, engineering blogs); Capgemini's commercial service pages; IBM's current
Consulting Advantage page; Cognizant Flowsource.

---

## 4. Tessl — the most disciplined model available

Tessl publishes **no whole-lifecycle or developer-level productivity number anywhere**. Its
marketing benefit blocks are governance, sprawl and visibility — three *problems*, not three gains.
What it does publish is per-artefact, eval-derived multipliers with the method attached:
`1.14×`–`2.62×` "agent success vs baseline" per skill, from baseline-vs-treatment task evals in
isolated containers, judge-scored against a generated rubric. The registry slogan is
**"Proof, not claims."**

Two habits worth copying:

1. **It attacks adoption statistics explicitly** — *"You have adoption numbers but no data on whether
   skills are actually activating"* — and publishes the three-layer distinction between published,
   installed and actually activated.
2. **It publishes its inconvenient numbers**: 41% unforced skill activation, 30% of generated eval
   tasks leaking criteria, 59% reviewer–grader agreement, one model failing 6 of 10 runs. Numbers
   that survive that treatment read as measured rather than marketed.

There is **no Tessl "State of AI Native Development" report** — it was solicited in Mar 2025 and
never published. Do not cite Tessl survey percentages; there are none.

---

## 5. What a defensible claim looks like

### 5.1 Why "from 30%" fails

"From" makes 30% a **floor**. Gartner's 25–30% is a **2028 ceiling**; Capgemini measured 7–18%;
Stanford's median is 10–15% and brownfield/high-complexity is 0–10%; TCS contracts 10–15%. The
phrasing converts the market's optimistic ceiling into our guaranteed minimum, and it has no
graceful degradation: "up to" survives an under-performing engagement, "from" becomes a broken
promise. Globant does use "at least 30%", but against a stated comparator (the engineer-plus-AI
approach), not across a lifecycle.

### 5.2 Recommended shape

**Anchor.** Cite Gartner and claim only that Bolt is built to reach it:

> **25–30% across the lifecycle — the analyst benchmark for applying AI beyond coding. Bolt is
> built to reach it.**
> *Gartner, "How to Capture AI-Driven Productivity Gains Across the SDLC", 11 Apr 2025: 25–30% by
> 2028 for teams applying AI across the SDLC, vs ~10% for code-focused use.*

Or, for a Bolt-specific and measurable version:

> **Target: 25–30% lifecycle efficiency, measured against your own baseline, established in the
> assessment.**

**Segment it.** Blended figures are where credibility dies. Saying the third row out loud is what
buys the first:

| Where the gain concentrates | Realistic band | Basis |
|---|---|---|
| Greenfield, well-specified features | Upper end | Stanford: greenfield/low 30–40% |
| Rework and verification overhead | Material | This is Bolt's actual mechanism — gates, contracts, traceability |
| Brownfield, high-complexity legacy | 0–15% | Stanford 0–10%; McKinsey <10% on high complexity |

**Publish the preconditions as a capability list, not a footnote** — the market convention, set by
DORA's AI Capabilities Model:

> The band assumes a working CI/CD harness; automated tests with a usable coverage baseline; version
> control discipline and small batches; AI-accessible internal documentation; and an agreed
> pre-Bolt baseline. Where these are absent, the first Bolts build them — and the gain lands later
> and lower. Expect a J-curve before the curve.

**Name the measurement method.** DORA's four keys, DX Core 4, or first-pass acceptance rate
(Thoughtworks Radar Vol. 34, 15 Apr 2026, recommends the latter for AI-assisted work and places
"coding throughput as a measure of productivity" in **Caution**).

### 5.3 Two internal collisions to fix first

1. **Slide 2 already carries `~30%` in scarlet** — "of developers report little or no trust in the
   code AI produces". A second, positive 30% puts the same numeral in one deck with opposite
   valence. Change one.
2. **`REFRESH.md` §7 rules 2–4** require every external claim to carry its source visibly and forbid
   presenting thresholds as results. A bare percentage would be the first unsourced metric in a deck
   that cites a repository path for every other factual claim.

### 5.4 Framings to avoid

1. **"From 30%"** — asserts as a minimum what Gartner projects as a 2028 maximum.
2. **A single blended lifecycle percentage with no segmentation** — swings by 4× between
   greenfield/simple and brownfield/complex.
3. **Multiples (10x, 15x, 5x)** — AWS never published them in writing.
4. **The 55% Copilot figure as lifecycle evidence** — one synthetic task, 2022.
5. **Throughput-derived claims** (features/Sprint, PRs, LOC) — Thoughtworks Radar **Caution**.
6. **Quality gates presented as achieved results** — `REFRESH.md` §7 rule 4.
7. **Ignoring the J-curve** — the client's own first month will contradict it.

---

## 6. Open gaps — close before this reaches a client

- ~~Avanade's and Accenture's own published position~~ — **CLOSED, see §3.5.** Neither publishes an
  engineering-efficiency percentage; Avanade published an article arguing against the measure.
- **Wipro, HCLTech** — sites block automated fetching; unverified either way. HCLTech's "AI
  deflation" figure (secondary reporting puts it at 3–5% of revenue) is the most valuable remaining
  lead, because it would complete the picture of how the three largest India-headquartered SIs each
  disclose the same commercial pressure differently.
- **Cognizant's randomised controlled trial of GitHub Copilot** — the one rigorous SI-run study in
  this space, not reached. Highest-value remaining lead.
- **Stanford per-cell figures** (30–40% / 10–15% / 15–20% / 0–10%) are reported from talks, not from
  a fetched primary table. Verify before putting a specific cell on a slide.
- **Thoughtworks Radar volume number** for the spec-driven-development blip (Vol. 33 vs 34, both
  Nov 2025). The ring — **Assess** — is solid; pin the volume before citing.
- **Do not cite without verification:** Infosys "300+ agentic AI solutions delivering 5–15%"
  (third-party blog only); IBM watsonx Code Assistant for Z "20–45% in technical preview" (partner
  blog only); HCLTech "3–5% AI deflation" and Wipro "25% less" (press summaries only).

---

## 7. Bolt's own position

There is no Bolt measurement, and the framework does not currently produce one. Two specific gaps:

- **The assessment measures the estate, not delivery.** `bolt-legacy-analyst` phase 1 produces
  `.boltf/analysis/<system>/ASSESSMENT.md` — LOC, languages, dependencies, top-10 technical debt
  with `file:line`, dead-code candidates, order-of-magnitude effort. `rfp-analysis-template.md` §4
  adds a *Code Quality Assessment* table with `Metric | Current Value | Industry Standard | Gap`.
  Both measure the **asset**. Neither captures lead time, cycle time, rework or deployment
  frequency — the delivery metrics a lifecycle-efficiency baseline needs.
- **Greenfield has no assessment at all**, so there is no prior state to measure against.

If the claim is to be "measured against your own baseline", the assessment needs a small set of
delivery metrics added to it. That is a contained change and it fits the table that already exists
in the RFP template.

---

## 8. State of play — resume here

**Deck review status.** 16 slides: 13 in the main flow, plus a three-slide **client-reference
appendix** after the close (see [`client-references.md`](client-references.md)). All reviewed and
closed. One appendix figure — four people, four months, zero starting definition — is a delivery
fact about a single engagement, **not** a measurement, and does not change the position below.

All 13 main-flow slides reviewed and closed. Slides 1–10 with the deck owner
(commits `a84a774`, `cdc20c3`); **slide 12 — the efficiency slide — now exists**, and slide 13
(the close) was rewritten to drop the "acceleration without a system" recap that duplicated the
line promoted onto slide 2.

**Decisions taken.**

| Question | Decision |
|---|---|
| Is the figure a commitment? | **No — indicative.** Expectation language, never a promise, never contractual |
| Baseline? | **From a prior assessment** of the client, not an assumed comparison |
| Language | English, and "Sprint" is always capitalised |
| Where the commitment lands | Its own slide immediately before the close (deck is now 12 slides) |
| Headline shape (was open #1) | **Gartner anchor** — "25–30% across the lifecycle … Bolt Framework is built to reach it", with the Gartner citation visible on the slide. The "measured against your own baseline" variant in §5.2 was **not** taken: it depends on the assessment carrying delivery metrics, which is still open |
| Which `30%` changes (was open #2) | **Slide 2's.** Its scarlet headline is now METR's **40 percentage points** — the gap between what developers report and what an RCT measured — and the ~30% distrust figure survives as a bullet. Nothing was lost, and the self-report/measured pairing across the two panels is now the point of the slide |

**Decisions still open.**

1. **Whether to extend the assessment** with delivery metrics so a client-specific baseline exists
   at all (§7). Until then the slide stays on the Gartner anchor; if the assessment does start
   capturing them, the §5.2 "measured against your own baseline" variant becomes available and is
   the stronger claim.

**Verifications a human must do** — all in §6. The previously blocking one (Avanade's and
Accenture's own published position) is **closed**: neither publishes an engineering-efficiency
figure. What remains is lower-stakes and none of it is on a slide today: Wipro/HCLTech, the
Stanford per-cell figures, and the Thoughtworks Radar volume number. **Verify the Stanford cells
before quoting one** — the slide currently cites Stanford only for the shape of the segmentation,
not for a specific cell value.

**Provenance of this file.** Compiled from four research sweeps that completed: market
claim-framing, the systems-integrator cohort, the AI-native tooling vendors (Kiro / Spec Kit /
GitHub / AWS AI-DLC), and the Accenture / Avanade / Thoughtworks thread — plus a Tessl deep-dive.
A fifth sweep on independent academic evidence exhausted its web-search budget and returned nothing
usable; the DORA / METR / McKinsey / Gartner rows in §2 come from the sweeps that did complete.
Wipro and HCLTech were never reached.

**One correction already caught by this process:** an earlier draft of this file cited METR's "19%
slower" as current. METR itself superseded that on 24 Feb 2026. The row in §2 now carries the
update. Treat every figure here as dated, and re-check anything older than a quarter before it
reaches a slide — this market revises its own numbers.
