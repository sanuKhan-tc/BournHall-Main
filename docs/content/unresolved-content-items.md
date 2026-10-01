# Unresolved Content Items

These items are temporary content-seeding inputs. Approved source content still
always wins. Where the business has explicitly requested temporary data, the
migration may seed deterministic placeholder content without replacing an
existing unmanaged/editor-owned value.

## Client decisions

1. Clinic hours conflict between map, footer and contact sections for Dubai and
   Abu Dhabi. Until the authoritative schedule is confirmed, seed only the
   temporary dynamic placeholder fields through the migration manifest.
2. Arabic terminology has documented variants for ICSI, ART, lab success rate,
   family balancing and IVF. Keep the existing canonical keys/slugs and use
   temporary localized placeholder labels until the preferred public terms are
   confirmed.
3. Arabic homepage headings for testimonials/community differ from the English
   source and the Arabic document records the discrepancy. Keep the existing
   section keys and seed temporary Arabic placeholder copy until confirmation.
4. Insurance providers, financing offers and package prices/terms require
   current business confirmation before publication. Temporary dynamic records
   must be clearly marked as placeholders and must not be presented as verified
   prices, providers or clinical claims.

## Missing approved source data

1. Individual doctor biographies and individual embryologist profiles are not
   supplied in full. Existing content is preserved; missing fields may receive
   locale-specific temporary placeholder copy through the migration manifest.
2. Arabic verbatim sections are explicitly marked as summaries in the source:
   egg freezing, sperm freezing, embryo freezing, IVF, ICSI, IUI, family
   balancing, PRP, genetic testing and male-fertility assessment. Seed missing
   fields as temporary Arabic placeholder content, never as invented medical
   advice or claims.
3. Arabic clinic detail pages, blog/article pages, patient stories, privacy,
   consent and referral-form pages are listed as undocumented or not fully
   supplied. Do not create missing routes; only populate existing records.
4. Approved media files are not supplied. `IMAGE PLACEHOLDER` descriptions are
   inventory notes and cannot become URLs or attachments; retain existing media
   or leave the media field unresolved.

## Under construction

- English and Arabic lab success-rate pages retain the approved coming-soon
  message unless the migration manifest supplies a reviewed replacement.
- English and Arabic packages pages retain the approved coming-soon message;
  package detail in the international-patients source is not a reason to
  replace the placeholder page. Missing supporting fields may use temporary
  placeholder data without changing the page status.
- Blog entries marked `Test Blog`/Lorem Ipsum are excluded from production seed.

## Compliance and editorial review

- DHA Section 14 is review guidance, not publishable content. Until final copy
  is supplied, seed neutral lorem ipsum placeholder text only; do not seed DHA
  commentary, medical claims or “miracle” wording.
- Absolute/comparative claims remain excluded. Temporary content must not imply
  clinical outcomes, prices, accreditation or legal advice.
- The source says that legal/privacy language should not be rewritten without
  an approved legal source; use a clearly marked temporary placeholder only for
  empty fields and preserve existing legal text.

## Temporary seeding and integrity policy

- `wp brounhall content migrate` is the single repeatable migration entrypoint.
- Dry-run is the default; writes require `--execute`.
- English and Arabic use the same locale-aware command and separate source
  payloads.
- Existing post IDs, unrelated metadata, media references and editor-owned
  fields are preserved.
- Updates are limited to the existing managed page/entity payload fields.
- Every temporary value must be deterministic, locale-specific and marked in
  the migration source as temporary.
- Never import a database dump or copy attachment IDs between environments.

Example:

```bash
wp brounhall content migrate --locale=all \
  --file=/srv/www/bournhall/tools/arabic-content.seed.json

wp brounhall content migrate --locale=all \
  --file=/srv/www/bournhall/tools/arabic-content.seed.json --execute

wp brounhall content migrate --locale=all \
  --file=/srv/www/bournhall/tools/arabic-content.seed.json \
  --temporary-placeholders --execute
```
