# Repository Guidelines

## Project Structure & Module Organization

- `Dockerfile` builds Redmine 7.0.1, installs plugins, applies patches, and builds Opale 1.7.1.
- `patches/` contains Redmine and plugin compatibility patches applied during the image build.
- `plugins/` contains checked-in plugin archives; `Dockerfile` also clones Git-based plugins.
- `theme/sass/` contains EdW’s Opale SCSS overrides; `theme/favicon/` contains assets.
- `view_customize/` contains JavaScript customizations and README setup instructions for the View Customize plugin.
- `scripts/`, `entrypoint.sh`, and `crontab` provide runtime, mail, repository, reminder, and periodic-task support.
- `compose.dev.yml` is the tracked local example; `compose.override.yml` is the ignored local override.

## Handover Notes

- The Redmine 6.1.0 → 7.0.1 upgrade is complete on `master`. The image uses Opale 1.7.1 and Redmine View Customize 3.6.0.
- The build downloads several plugins at build time. In particular, `redmine_issues_tree` is based on branch `6.1.x` plus PR 149, and `periodictask` receives no local parent-task patch; its current migration already adds `periodictasks.parent_id`.
- Compatibility patches in `Dockerfile` are intentionally ordered. The Rails 8 route patch for `redmine_issues_tree`, the Redmine 7 Stopwatch patch, the issue hierarchy patch, and the RedmineUp Tags sidebar patch should be reviewed before changing plugin versions.
- `pandoc` is installed in the image for document previews. Rebuild with `--no-cache` after changing Dockerfile, downloaded plugins, patches, or theme SCSS.
- Theme colors are overridden through `$tracker-custom-colors-map` and `$status-custom-colors-map` in `theme/sass/_custom-variables.scss`; status ID 5 uses Opale’s special `closed` key. The wiki table-generator grid fix is an explicit cell border in `theme/sass/_custom.scss`.
- The numbered `view_customize/` directories are instructions/code pasted into the View Customize plugin; they are not automatically loaded by the image. Keep their README path patterns and insertion positions synchronized with their JavaScript.
- Stopwatch state is stored in `user_preferences.others[:current_timer]` as JSON containing `started_at` (Unix time) and `time_entry_id`; accumulated time is in `time_entries.hours`. A timer can therefore change the browser title while running.

## Local Compose Pitfalls

- Redmine connects to the development service named `smtp` on port 25. Mailpit must bind internally to `0.0.0.0:25`; host port 8025 exposes its UI.
- `compose.yml` contains production postfix variables, so use `${MTP_*:-}` defaults to avoid warnings when the development override replaces postfix with Mailpit.
- `redmine-repositories` is a named volume, not a bind mount; do not append `:Z`. Use `:Z` only on actual host-directory bind mounts on SELinux systems.
- If local authentication points at unreachable LDAP, set the affected user’s `auth_source_id` to `NULL` in the local database. Never copy local database credentials into tracked files.

## Build, Test, and Development Commands

```bash
docker compose -f compose.yml -f compose.override.yml config
docker compose build --no-cache redmine
docker compose up -d --force-recreate
docker compose logs -f redmine
```

Use the first command to validate merged Compose configuration and rebuild after Dockerfile, plugin, patch, or theme changes. Redmine is available at `http://localhost:8090`; Mailpit is available at `http://localhost:8025`.

## Coding Style & Naming Conventions

Use two-space indentation in YAML and SCSS. Follow existing Ruby, JavaScript, and shell style. Name patches descriptively, number View Customize directories by execution order, and include a README for each. Use imperative commit subjects such as `Fix ...`, `Add ...`, or `Update ...`.

## Testing Guidelines

There is no automated test suite. Run Compose validation and `git diff --check`, then manually test affected Redmine workflows. For UI changes, verify desktop and responsive layouts and include screenshots when useful.

## Maintenance Matrix

| Change | Also review |
|---|---|
| Dockerfile/plugin/patch | `README.md`, image build, startup migrations |
| Theme SCSS | image rebuild and affected Redmine pages |
| View Customize code | its README and affected browser workflow |
| Compose services | `compose.dev.yml`, local `compose.override.yml`, README commands |

## Done means

- `docker compose ... config` succeeds.
- `git diff --check` succeeds.
- Affected workflows are manually verified in the local stack.

## Never merges without a human

A person has to have **read this diff** before it lands. Telling an agent "merge it when you're done" is approving a goal, not this change — so it does not count for anything on this list. Everywhere else it counts fine, which is the point of having a list.

- Changes to `Dockerfile`, `patches/`, database migrations, or authentication configuration.
- Changes that send email, alter permissions, or modify production Compose configuration.
