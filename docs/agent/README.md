# Coding Agent Context

This folder contains compact operational guidance derived from the full headless WordPress + Next.js project plans.

Read order:

1. `00-source-of-truth.md`
2. `01-architecture-and-boundaries.md`
3. `02-execution-workflow.md`
4. `03-security-guardrails.md`
5. `04-testing-and-definition-of-done.md`
6. `05-change-playbooks.md`

These documents complement, rather than replace, the detailed plans under `docs/headless/`.

## Intended Placement

```text
parent-repository/
├── AGENTS.md
├── frontend/
│   └── AGENTS.md
├── backend/
│   └── AGENTS.md
└── docs/
    ├── agent/
    │   ├── README.md
    │   ├── 00-source-of-truth.md
    │   ├── 01-architecture-and-boundaries.md
    │   ├── 02-execution-workflow.md
    │   ├── 03-security-guardrails.md
    │   ├── 04-testing-and-definition-of-done.md
    │   └── 05-change-playbooks.md
    └── headless/
        └── existing implementation plans
```

If the team standard requires `Agent.md` rather than `AGENTS.md`, rename consistently, but keep one authoritative file per repository boundary to avoid conflicting instructions.
