# Installation / Merge Guide

Copy these files into the corresponding repositories:

```text
brounhall-agent-context/AGENTS.md
  -> parent repository /AGENTS.md

brounhall-agent-context/frontend/AGENTS.md
  -> frontend submodule /AGENTS.md

brounhall-agent-context/backend/AGENTS.md
  -> backend submodule /AGENTS.md

brounhall-agent-context/docs/agent/*
  -> parent repository /docs/agent/*
```

Recommended Git sequence:

```text
1. add/commit frontend/AGENTS.md inside frontend submodule
2. add/commit backend/AGENTS.md inside backend submodule
3. push both child commits
4. update parent submodule pointers
5. add parent AGENTS.md + docs/agent/*
6. review against docs/headless/*
7. commit parent integration update
```

Do not simply copy the child `AGENTS.md` files into a submodule and commit only the parent pointer; child files must be committed within their own repositories.
