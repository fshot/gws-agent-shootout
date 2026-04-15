# What's next?

Quick check of project status and recommendation for the next action.

## Instructions

This is the lightweight version of `/project:status`. Use it when you just want to know what to do next.

1. **Check seed data**: Are `fixtures/seed-ids-gmail.json` and `fixtures/seed-ids-workspace.json` populated?

2. **Check completed runs**: Scan `results/*/session-log.md` files. Which config/account combos are done?

3. **Determine current phase** from the execution plan in CLAUDE.md:
   - Phase 0 (seed) → Phase 1 (B) → Phase 2 (C) → Phase 3 (D, D2) → Phase 4 (E, A, F) → Phase 5 (synthesis) → Phase 6 (cleanup)

4. **Print one line**: what phase we're in and the exact command to run next.

Examples:
```
Phase 0 incomplete. Next: /project:seed gmail
Phase 1 in progress. Next: /project:run-test B workspace
Phase 3 complete. Next: /project:run-test E gmail
All runs complete. Next: /project:synthesize
```

Keep it to 5 lines or fewer.
