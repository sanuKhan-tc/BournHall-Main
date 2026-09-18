# Common Change Playbooks

## Add a New CMS Page Section

### Backend

1. confirm the section cannot be represented by an existing section/variant;
2. define structured fields with no arbitrary executable markup;
3. expose only required GraphQL fields;
4. add representative CMS fixture/content;
5. add backend/contract tests.

### Frontend

1. update GraphQL fragment/document;
2. regenerate/update types;
3. add mapper/view model;
4. map the known discriminator to an existing/new controlled component;
5. define safe behavior for missing/invalid optional fields;
6. test rendering/responsiveness/accessibility.

### Parent

Pin tested backend + frontend SHAs and update relevant content-model documentation.

---

## Change a GraphQL Field

Prefer additive evolution.

```text
BE add new field -> validate -> FE consume -> deploy/verify -> remove old field later
```

Do not rename/remove a field currently consumed by deployed FE without a compatibility migration.

---

## Change Mega Menu Configuration

Backend owns typed configuration and hierarchy. Frontend owns behavior/layout/accessibility.

Validate:

- enum/layout compatibility;
- safe links;
- desktop behavior;
- mobile behavior;
- keyboard/focus interaction;
- targeted `navigation` cache invalidation.

---

## Change SEO Contract

Validate both content and rendered output.

Backend:

- field availability/defaults;
- routable-content coverage.

Frontend:

- metadata fallback rules;
- canonical host;
- robots policy;
- Open Graph/Twitter;
- sitemap implications;
- JSON-LD accuracy.

---

## Change Revalidation

Treat as a security-sensitive cross-repo contract.

Backend:

- event payload;
- event type/content type;
- signing/timestamp behavior.

Frontend:

- signature/timestamp/replay validation;
- schema validation;
- server-derived tag/path mapping;
- negative tests.

Never accept arbitrary purge instructions from the caller.

---

## Change Preview

Backend and frontend must agree on authorized draft access.

Test:

- authorized draft visible in preview;
- anonymous visitor cannot retrieve it;
- preview response is uncached;
- credential is absent from browser/client bundle;
- exit-preview clears preview behavior.

---

## Change Local/Submodule Setup

Validate with a fresh or clean checkout where practical:

```bash
git submodule update --init --recursive
```

Do not commit developer-specific XAMPP paths. Update `docs/headless/00-local-development-submodule-setup.md` when the workflow changes.
