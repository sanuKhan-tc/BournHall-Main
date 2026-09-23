# Deployment

## Backend development environment

The `dev` branch deploys only:

```text
backend/wp-content/plugins/brounhall-headless/
```

WordPress core, `wp-config.php`, uploads, and the database are not deployed by
GitHub Actions.

Configure a GitHub Environment named `dev` with:

- Secret: `WPE_SSHG_KEY_PRIVATE`
- Variable: `WPE_DEV_ENV` — the WP Engine environment name

The workflow starts on a push or merge into `dev`, or manually from the
Actions tab.

## WP Engine backend setup

1. In WP Engine User Portal, open the target environment's SSH Gateway key settings.
2. Generate an ED25519 deploy key and add its public key to WP Engine.
3. Add the private key to the GitHub `dev` Environment as `WPE_SSHG_KEY_PRIVATE`.
4. Copy the WP Engine environment/install name into the `WPE_DEV_ENV` variable.
5. Push a plugin-only change to `dev` and verify the workflow and the WordPress API.

Do not use the same key as a personal key. Do not commit the private key.

## Frontend setup

Connect the `frontend` GitHub repository directly to a WP Engine Headless
Platform application. Configure a development environment from the frontend
development branch and set:

```text
Install: npm ci
Build:   npm run build
Start:   npm run start
```

Configure the frontend's server-side WordPress URL and other secrets in the
WP Engine environment settings. Set the WordPress Headless Plugin's frontend
URL to the corresponding WP Engine frontend development URL.

The frontend is intentionally not deployed by the parent repository's backend
workflow.
