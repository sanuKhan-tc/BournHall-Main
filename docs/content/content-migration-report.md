# Content Migration Report

## Audit result

The repository already has a compatible content path: WordPress structured page
data and entity records are consumed server-side by Next.js REST/GraphQL
loaders. A second page renderer or a browser-side CMS client is not required.

The supplied documents were extracted and reviewed. English contains 645
non-empty extracted lines; Arabic contains 968. The Arabic source has explicit
developer-note, DHA-review, client-decision and summary-only sections. Those
classes are recorded in `unresolved-content-items.md` and are excluded from
publishable seed data.

## Current implementation findings

- Native pages use `_brounhall_page_data`; legacy YAML remains in
  `post_content` for compatibility.
- Treatments use the canonical `service` post type with legacy
  `bh_treatment` compatibility and `_brounhall_entity_data`.
- Doctors and clinics have server-side REST loaders and Arabic locale support.
- Navigation has controlled GraphQL contracts and URL validation.
- SEO is represented in the backend and rendered through Next metadata.
- Existing Arabic seed tooling performs direct JSON migration but does not yet
  provide stable-key ownership, content hashes, status/verify commands or
  managed-field protection.

## Safe implementation boundary

The next implementation step is a versioned manifest runner built on the
existing page/entity meta contracts. It must update only records carrying its
stable key and must refuse unresolved or non-publishable source records. The
runner must be dry-run by default and must not be executed against remote
WordPress until the unresolved content decisions are closed.

## No content cutover performed

No WordPress records were changed in this audit. The local WordPress runtime
was unavailable, and the source contains unresolved content and media decisions.

