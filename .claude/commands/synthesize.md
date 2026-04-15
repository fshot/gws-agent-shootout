# Run synthesis: comparison + blog draft

Read all completed session logs and produce the synthesis outputs.

## Instructions

This command implements Phase 5 of the execution plan.

### Pre-flight

1. Run the equivalent of `/project:status` — check how many of the 14 test runs have completed session logs. If fewer than 10 are complete, warn the operator and ask whether to proceed with a partial synthesis or wait.

2. Read `templates/publication-spec.md` in full. This is your style guide and structural template.

### Read all raw data

Read every file in every `results/*/` directory:
- All `session-log.md` files
- All `setup.md` files
- Note which configs/accounts are missing

### Write synthesis/comparison.md

Follow the structure defined in `templates/publication-spec.md` under "synthesis/comparison.md structure":

1. Executive summary (5 bullet points)
2. Setup complexity comparison table
3. Component test results matrix (all configs x all operations)
4. Integration test results
5. Per-config deep dives (cite session log + operation #)
6. Account-type comparison (@gmail.com vs @workspace)
7. Recommendations by use case
8. Limitations and caveats

**Rules from CLAUDE.md synthesis section apply**:
- Evidence-first: every claim cites a specific session log and operation number
- No smoothing: if it failed, say it failed; if it was slow, say how slow

### Write synthesis/blog-draft.md

Follow the blog post structure from `templates/publication-spec.md`:

1. Hook (reference v1)
2. What we tested
3. What surprised us (2-3 unexpected findings)
4. Results (abbreviated matrix, link to full guide)
5. The v1/v2 comparison
6. Recommendations
7. Closing (link to full guide, no CTA)

Target 1200-1800 words.

### Write/update README.md

Replace the existing README with the structure from `templates/publication-spec.md`:

1. What this is (2-3 sentences)
2. Results matrix (pass/fail table linking to session logs)
3. Recommendations (3-4 sentences)
4. How to reproduce (link to setup guides and protocol)
5. Methodology (link to CLAUDE.md, link to v1)

### Important

- You are the synthesis session described in the protocol. You did NOT run the tests. Your job is to analyze raw data objectively.
- Do not add findings or claims that aren't supported by the session logs.
- Do not speculate about why something failed unless the error message makes the cause obvious.
- Use the publication spec voice: practitioner-to-practitioner, direct, no marketing language.
