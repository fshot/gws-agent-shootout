# Publication Spec: GWS Agent Shootout v2

This document defines the audience, voice, structure, and quality bar for all publishable outputs of this project. The synthesis session should read this before writing anything.

## Audience

**Primary**: Technical decision-makers (CTOs, engineering leads, IT directors) evaluating whether and how to connect AI agents to Google Workspace. They want to know: which combination actually works, how hard is setup, and what are the limitations?

**Secondary**: Hands-on developers and automation builders who will follow the setup guides step by step. They want exact commands, exact scopes, exact screenshots — not summaries.

Both audiences are comfortable with CLIs, APIs, and OAuth flows. Do not explain what an API key is. Do explain which specific API to enable and what happens if you skip it.

## Voice

**Practitioner-to-practitioner.** We ran the tests, here's what happened, here's what we'd recommend. Direct, specific, evidence-backed.

- No marketing language. No "powerful", "seamless", "cutting-edge", "leverage."
- No hedging where we have data. "Config B passed 14/15 tests" not "Config B performed reasonably well."
- Honest about failures. If a tool broke, say what broke, show the error, note whether it's a fixable config issue or a fundamental gap.
- Credit where due. If a tool worked great, say so plainly.

**Crux Capacity** is the byline and publisher, not the subject. The consultancy's credibility comes from the rigor of the work, not from self-promotion. Do not include calls to action, "contact us" sections, or service pitches in the technical content.

## Structure: The Guide (README + synthesis/comparison.md)

The README is the entry point. It should be scannable in 60 seconds and link to deeper content.

### README structure

1. **What this is** (2-3 sentences)
2. **Results matrix** — pass/fail table across all configs and operations, linking to session logs
3. **Recommendations** — 3-4 sentences: "If you need X, use Y"
4. **How to reproduce** — link to setup guides and this protocol
5. **Methodology** — link to CLAUDE.md protocol, link to v1 for comparison

### synthesis/comparison.md structure

1. **Executive summary** — key findings in 5 bullet points
2. **Setup complexity comparison** — table: config, time-to-first-operation, number of setup steps, GCP requirements
3. **Component test results** — full matrix with pass/fail/blocked, timing per operation
4. **Integration test results** — same format
5. **Per-config deep dives** — for each config: what worked, what didn't, notable observations (cite session log + operation #)
6. **Account-type comparison** — did @gmail.com and @workspace behave differently?
7. **Recommendations by use case**:
   - "I need full CRUD across all services"
   - "I only need read access"
   - "I need to run this on a schedule (headless)"
   - "I need this for a Workspace org (not personal Gmail)"
8. **Limitations and caveats** — what we didn't test, known gaps, things that might change

## Structure: The Blog Post (synthesis/blog-draft.md)

The blog post is shorter, narrative-driven, and published at cruxcapacity.com. It links to the full guide (this repo) for details.

### Blog post structure

1. **Hook**: "Last month we tried to get AI agents to manage Google Workspace. It was a mess. This time we used a protocol." (Reference v1.)
2. **What we tested**: Brief summary of the 7 configs, 2 accounts, 15 operations.
3. **What surprised us**: 2-3 findings that were unexpected. Lead with these — they're the reason someone reads past the intro.
4. **The results**: Abbreviated matrix, link to full guide.
5. **The v1/v2 comparison**: What changed when we added structure? Was it worth the overhead?
6. **Recommendations**: Concise, opinionated. "Use X unless you need Y, in which case Z."
7. **Closing**: Link to full guide. No CTA.

**Length**: 1200-1800 words. Err on the side of shorter.

## Quality bar

These are hard requirements, not aspirations:

1. **Every recommendation cites a test result.** "Use Config B for full CRUD" must link to the session log showing 15/15 pass.
2. **Every setup instruction was executed during testing.** No steps reconstructed from documentation after the fact. The setup docs are transcripts of what we actually did.
3. **No "should work."** Only "we verified this works" or "this failed" or "we did not test this."
4. **Error messages are verbatim.** Do not paraphrase error output.
5. **Timing data is wall-clock, not estimated.** Recorded during the test, not recalled later.
6. **Screenshots exist for every auth flow and consent screen.** A reader following the guide should see the same screens.
7. **The guide is reproducible.** A technically competent reader with a GCP account and the relevant agent tools installed should be able to follow the setup docs and get the same results. If something requires a non-obvious prerequisite, it must be documented.

## What not to include

- Pricing comparisons (prices change too fast, and some tools are free)
- Speculation about future features or roadmaps
- Comparisons to tools not in the test matrix
- Opinions about which company/model is "best" in general terms
- Anything we didn't test ourselves
