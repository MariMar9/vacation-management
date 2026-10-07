---
theme: "@ava-innersource/slidev-theme-base"
title: Bolt Framework
titleTemplate: "%s — Avanade"
exportFilename: bolt-framework-client
info: |
  Bolt Framework — client edition.

  This deck is ASSEMBLED FROM slides.md, it does not duplicate it. Every content
  slide is imported by range, so a fix in the internal deck lands here too. Only
  the closing slide is defined locally, because its call to action differs.

  Excluded on purpose: the business-developer one-pager and the delivery-lead
  one-pager. Both are internal — pursuit guidance and framework gaps.

  Speaker notes travel with imported slides. Strip them before sharing the PPTX:
  see scripts/strip-pptx-notes.py and REFRESH.md §5.
layout: cover
author: AI-Driven Development Lifecycle · Avanade
---

<!--
Client edition. Two things to remember before this leaves the building:

1. The PPTX carries speaker notes unless they are stripped. Those notes contain
   internal guidance — what not to claim, which objections to pre-empt. Run the
   stripper, or send the PDF.

2. The efficiency slide is in this deck by decision. It is an expectation with
   Gartner cited on the slide, never a commitment, and never contractual. If
   someone tries to write the band into a contract off a leave-behind, stop them.
-->

---
src: ./slides.md#2-8,10,12
---

---
layout: breaker
title: An operating model, not a tool
subtitle: It transfers with the work — the specifications, decision records and tests stay in **your** repository, readable without us. **Next step:** a short assessment to map your delivery baseline and agree where the first Bolts land.
---

<!--
Same closing message as the internal deck, different next step. The internal
version points at the repository access process; that is meaningless to a client
and names our own onboarding.

What transfers is the operating model, so the client's own team can keep running
it after we leave. That is what separates this from a tool licence — and the
first appendix reference is the proof: there, the functional knowledge that had
lived only in people's heads ended up written down and owned by the client.
-->

---
src: ./slides.md#14-16
---
