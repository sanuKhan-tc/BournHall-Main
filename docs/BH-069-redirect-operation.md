# BH-069 — Redirect Operation Decision

## 1. Task

**BH-069 Redirect Operation — N/A**

The task is formally closed as N/A. CMS-managed redirects are not in scope for the current headless release.

## 2. Preflight

- Parent: `9e98301104f3c1da9d7b1ff70e9c862622bd25b7`
- Frontend: `508cffca9c7a9292e0e675dea3345d418a259868`
- Backend: `111186cd088291262606b8ea851b81bdd5dbf130`
- Frontend worktree has pre-existing untracked `src/lib/wordpress/queries/sitemap.graphql` and `yarn.lock`; preserved unchanged.
- Backend worktree is clean.
- No reachable BH-010 commit, branch, or repository decision record was found. The current decision is based on the inspected implementation and documented ownership boundaries.

## 3. Existing Redirect Inventory

| Source | Owner | Current purpose | CMS-managed? | Recommendation |
| --- | --- | --- | --- | --- |
| `frontend/next.config.ts` → `redirects()` | Next.js | Permanent `/resources` and `/resources/:path*` aliases to `/blogs` | No | Keep in frontend configuration |
| `frontend/src/app/costs/page.tsx` → `redirect("/costs/finance")` | Next.js | Route compatibility/default landing behavior | No | Keep in frontend routing |
| Middleware/proxy | None found | None | No | No change |
| Route handlers / `permanentRedirect()` | None found | None | No | No change |
| Static redirect maps / legacy alias maps | None found | None | No | No change |
| WordPress project plugin/config | Backend project | No redirect model or redirect hooks | No | Do not add speculatively |
| SEO redirect plugin/config | None found | No Yoast/Rank Math/redirection integration | No | Do not install or enable for BH-069 |
| WordPress core redirects | WordPress core | Admin/auth/system behavior only | No | Outside public frontend redirect ownership |

## 4. CMS Redirect Capability

No approved CMS redirect source is exposed by the backend:

- no Redirect CPT;
- no ACF redirect options/group;
- no redirect plugin GraphQL exposure;
- no custom redirect REST/GraphQL field;
- no persisted redirect configuration.

The project plugin README explicitly lists redirects as not included in the current release. Existing backend GraphQL fields cover global settings only; no redirect type or field is registered.

## 5. Scope Decision

**PATH B — CMS redirects are not in scope.**

Redirect ownership remains with Next.js configuration/routing for the current release. A future platform/deployment redirect layer may own infrastructure-level redirects if that is separately approved. No CMS model or GraphQL operation is created.

## 6. Operation Added

N/A. No GraphQL schema expansion, operation, codegen, frontend consumer, or backend change is required.

## 7. Security / URL Policy

Keeping redirects out of CMS avoids introducing an editor-controlled open-redirect surface or a new URL trust boundary. Existing frontend redirects are static and code-owned. If CMS redirects are later approved, the contract must require server-only read-only consumption, safe relative or approved absolute destinations, rejection of unsafe schemes, and an explicit no-open-redirect policy.

## 8. BH-111 Handoff

BH-111 remains **N/A for CMS-managed redirects**. It may cover existing frontend/platform redirects only if BH-111 is explicitly re-scoped to that inventory; it must not assume a CMS redirect operation exists.

## 9. Codegen Boundary

No codegen and no new dependency. No backend schema expansion was made.

## 10. Quality Checks

- Repository/source inventory completed against the pinned SHAs.
- `git diff --check` is required after this documentation change.
- No operation exists, so live GraphQL or unsafe-destination tests are not applicable.
- Known full-lint baseline remains 13 findings: 9 errors and 4 warnings; no lint was changed by this task.

## 11. Files Changed

- `docs/BH-069-redirect-operation.md`

## 12. Commits / Branches

- Parent branch: `integration`
- Child branches/commits: none; no child repository changes were required.
- Parent commit: pending.

## 13. Next Task

BH-070 and BH-071 once BH-068/BH-069 are both resolved.
