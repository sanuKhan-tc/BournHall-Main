# Unresolved Content Items

These items are intentionally not invented or automatically migrated.

## Client decisions

1. Clinic hours conflict between map, footer and contact sections for Dubai and
   Abu Dhabi. Confirm the authoritative schedule before updating global,
   location and contact records.
2. Arabic terminology has documented variants for ICSI, ART, lab success rate,
   family balancing and IVF. Confirm the preferred public term before changing
   navigation labels or slugs.
3. Arabic homepage headings for testimonials/community differ from the English
   source and the Arabic document records the discrepancy. Use the approved
   final heading only after confirmation.
4. Insurance providers, financing offers and package prices/terms require
   current business confirmation before publication.

## Missing approved source data

1. Individual doctor biographies and individual embryologist profiles are not
   supplied in full. Existing content is not overwritten with generated bios.
2. Arabic verbatim sections are explicitly marked as summaries in the source:
   egg freezing, sperm freezing, embryo freezing, IVF, ICSI, IUI, family
   balancing, PRP, genetic testing and male-fertility assessment.
3. Arabic clinic detail pages, blog/article pages, patient stories, privacy,
   consent and referral-form pages are listed as undocumented or not fully
   supplied.
4. Approved media files are not supplied. `IMAGE PLACEHOLDER` descriptions are
   inventory notes and cannot become URLs or attachments.

## Under construction

- English and Arabic lab success-rate pages retain the approved coming-soon
  message.
- English and Arabic packages pages retain the approved coming-soon message;
  package detail in the international-patients source is not a reason to
  replace the placeholder page.
- Blog entries marked `Test Blog`/Lorem Ipsum are excluded from production seed.

## Compliance and editorial review

- DHA Section 14 is review guidance, not publishable content.
- Absolute/comparative claims and “miracle” wording require the approved Arabic
  replacement already identified by the source and, where applicable, medical
  director approval.
- The source says that legal/privacy language should not be rewritten without
  an approved legal source.

## Known implementation blocker

The local WordPress REST endpoints at `http://brounhall-wp.local` timed out
during this audit. Local dry-run and idempotency execution therefore remain
blocked until the local WordPress runtime is available.

