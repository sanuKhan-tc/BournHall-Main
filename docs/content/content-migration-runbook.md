# Content Migration Runbook

This runbook is for the versioned content manifest runner. It is intentionally
safe-by-default and does not replace a WordPress database.

## Precheck

1. Confirm a current environment backup and record the backup reference.
2. Confirm the backend plugin version and current
   `brounhall_content_schema_version`.
3. Run validation for the intended locale and content scope.
4. Run a dry-run and review `WARNING` and `FAILED` records.
5. Confirm all source items marked client decision, summary-only, under
   construction or missing media are handled according to
   `unresolved-content-items.md`.

## Commands

```text
wp brounhall content validate --locale=all
wp brounhall content status --migration=2026-10-bourn-hall-content-v1
wp brounhall content migrate --migration=2026-10-bourn-hall-content-v1 --locale=all --dry-run
wp brounhall content migrate --migration=2026-10-bourn-hall-content-v1 --locale=all
wp brounhall content verify --migration=2026-10-bourn-hall-content-v1
```

Use `--only=pages`, `--only=treatments`, `--only=doctors`, `--only=globals`,
`--only=navigation` or `--only=locations` to narrow a run. `--force-managed`
is reserved for records already marked as managed by this migration; it does
not delete unrelated production data.

## Order

Deploy compatible backend code first. Validate and dry-run. Apply managed page
and entity records. Verify counts and stable-key/hash matches. Trigger only the
existing targeted revalidation events for changed content tags. Smoke-test
English and Arabic representative routes through the Next.js frontend.

## Rollback

Do not promise automatic rollback. For a code issue, roll back the plugin to
the previously tested child SHA. For a content issue, restore the environment
backup or apply a reviewed migration-specific corrective manifest. Never restore
the entire database to undo one content field without an approved recovery plan.

