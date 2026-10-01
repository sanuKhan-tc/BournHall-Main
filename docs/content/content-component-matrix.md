# Bourn Hall Content Component Matrix

This matrix records the existing server-side data path before any content
cutover. The presentation component remains authoritative; CMS data is mapped
into its existing props.

| Source content | WordPress field/model | API representation | Frontend mapper/parser | Existing component props | Mismatch / action |
| --- | --- | --- | --- | --- | --- |
| Homepage hero | Page `_brounhall_page_data`, `hero` section | REST page `content.rendered` YAML envelope | `getHomePageContent()` and page helpers | `Hero` title, description, image, actions | Verify exact source copy and media; no visual change |
| Homepage treatment carousel | `service`/legacy `bh_treatment` | REST `/treatments` and item endpoint | `getTreatments()` + treatment card mapper | `TreatmentCard` title, summary, image, href | Source has six items; confirm all canonical slugs before seed |
| Homepage doctors | `doctor` | REST `/doctors` | `getDoctors()` + doctor view model | `Specialists` / `DoctorCard` | Remove Mufeed from managed published selectors without destructive delete |
| Homepage clinics | `location` | REST `/clinics` | `getClinics()` + clinic view model | `LocationsSection` / `LocationCard` | Hours conflict in source; block until client decision |
| Global statistics | `brounhall_global_settings` | GraphQL `brounhallGlobalSettings` | `getGlobalStatistics()` | `StatsRow` | Source does not give one unambiguous final statistic set |
| Primary navigation | native menu + controlled menu item fields | GraphQL `primary-navigation.graphql` | navigation query/mapping | `DesktopNav`, `MobileNav`, `TreatmentsMegaMenu` | Seed hierarchy only after canonical routes validated |
| Footer menus | `footer-navigation`, `footer-services` | GraphQL footer query | footer mapper | `Footer` | Preserve external links and validate all internal locale paths |
| Page hero | Page `hero` section | parsed YAML object | page-specific loader (`pages/*.ts`) | `PageHero` | Add only missing approved fields; do not pass raw CMS data |
| Page rich text | Page `rich_text`/legacy structured section | parsed paragraphs/items | page-specific loader | `Reveal`, text blocks, `DetailSection` | Arabic summarized sections remain unresolved |
| Page media | attachment ID in section media | server-side media resolution | `get*Image` helpers / media validator | `SiteImage`, hero/media props | Placeholder descriptions are not media assets |
| Treatment entity | `service`, `_brounhall_entity_data` | REST normalized treatment payload | `getTreatmentBySlug()` and `treatment-view-model.ts` | `TreatmentPageBody`, `TreatmentToc` | Add manifest data only for approved exact text |
| Doctor entity | `doctor`, entity data, `locales.ar` | REST normalized doctor payload | `getDoctorBySlug()` / `getDoctors()` | `DoctorProfile`, `DoctorsDirectory` | Individual bios absent from source; do not invent |
| Clinic entity | `location`/legacy `bh_clinic` | REST normalized clinic payload | `getClinics()` | clinic cards/detail | Address and hour conflicts require confirmation |
| FAQ | `faq`, page FAQ relation | REST `/faqs/faq` | `getFaqs()` | `FaqSection`, `FaqPageClient` | Source crawl says dynamic/test content; exclude test entries |
| SEO | ACF `seo` | GraphQL SEO fragment / route metadata | `buildMetadata()` and page metadata | Next.js `<head>` | Do not derive unsupported claims from marketing notes |
| Consultation form | server form route plus settings | Next.js POST -> signed WP REST | `AppointmentForm` | existing form props | Source is a multi-step flow; current contract needs a field-by-field reconciliation |
| Complaint form | signed WP REST route | Next.js POST -> server-only WP REST | `ComplaintForm` | existing form | Not described in the English page hierarchy; keep existing behavior |

