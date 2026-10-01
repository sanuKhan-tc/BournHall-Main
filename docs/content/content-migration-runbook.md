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
wp brounhall content migrate --locale=all --file=/srv/www/bournhall/tools/arabic-content.seed.json
wp brounhall content migrate --locale=all --file=/srv/www/bournhall/tools/arabic-content.seed.json --execute
wp brounhall content migrate --locale=all --file=/srv/www/bournhall/tools/arabic-content.seed.json --temporary-placeholders --execute
```

The command is dry-run by default. `--temporary-placeholders` replaces only
exact unresolved marker values with locale-specific temporary text; it does not
create routes or replace media.

PowerShell/SSH wrapper:

```powershell
powershell -File tools/content-migrate.ps1 -SeedFile tools/arabic-content.seed.json -Target local
powershell -File tools/content-migrate.ps1 -SeedFile tools/arabic-content.seed.json -Target remote -SshKey $env:USERPROFILE\.ssh\wpe_brounhall_deploy
powershell -File tools/content-migrate.ps1 -SeedFile tools/arabic-content.seed.json -Target remote -Execute -TemporaryPlaceholders -SshKey $env:USERPROFILE\.ssh\wpe_brounhall_deploy
```

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
