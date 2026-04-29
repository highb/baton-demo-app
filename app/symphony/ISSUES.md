# Known Issues

Tracked gaps from the database + admin LiveView build. Each entry has a
`Status:` line so this can become a working punch list.

---

## UI / Forms

### FK fields render as raw integer inputs
**Status:** TODO

`phx.gen.live --no-schema` types foreign-key columns (`venue_id`,
`ensemble_id`, `parent_section_id`, `applies_to_performance_id`) as
`:integer`, so the admin forms render number inputs and the operator
has to type the FK id by hand.

**Fix:** swap to `<.input type="select" options={...} />` per form;
the options come from `Symphony.Orchestra.list_venues/0` etc. One
touch-up per affected form (Section, VenueSection, SeasonSubscription,
Performance, PromoCode).

**Where it bites:** every admin form that references another resource.

---

### `Application.flags` is a comma-typed string input
**Status:** TODO

The `applications.flags` column is `{:array, :string}` with a closed
vocabulary (`hidden`, `inactive`, `saml`, `oidc`, `bookmark`). The
generator gave us a single text input. Operators have to know the
allowed values and not typo them.

**Fix:** render as a multi-select with the five known values.

---

### `PromoCode.discount_kind` / `discount_value` semantics not enforced in form
**Status:** TODO

`discount_value` is interpreted as basis points when `discount_kind=percent`
and as cents when `discount_kind=fixed_amount`. The form is two
unrelated number/text inputs — nothing in the UI explains this or
prevents an operator from entering "50" expecting "$50 off" when
`discount_kind=percent`.

**Fix:** custom form section with conditional labeling, or split into
two distinct flows. Add a `validate_change/3` in the changeset to
flag suspicious values (e.g. percent > 10000 basis points).

---

### No nav between admin pages
**Status:** DONE (73042a4)

`/admin/instruments`, `/admin/venues`, etc. exist, but there's no
sidebar or top-bar listing them. The landing page (`/`) is still the
stock `phx.new` "Welcome to Phoenix" template and doesn't link to
anything.

**Fix:** add an `/admin` index page or admin layout with a sidebar
listing all 14 resources. Add an `/admin` route or redirect.

**Resolution:** `SymphonyWeb.AdminNav` `on_mount` hook captures the
URL via `attach_hook(:set_current_path, :handle_params, …)`. Admin
routes are wrapped in `live_session :admin, on_mount:
SymphonyWeb.AdminNav` so every admin LiveView gets `@current_path`.
`Layouts.app/1` renders a grouped sidebar with active-route
highlighting when the path starts with `/admin`. Top header trimmed
to a Symphony brand link plus an Admin shortcut. Landing page (`/`)
is still phx.new boilerplate — see separate "Default Phoenix landing
page" entry below.

---

### No pagination on index pages
**Status:** TODO

Every `list_*` function is `Repo.all/1`. Fine for the seed dataset;
will scale-fail at a few thousand rows.

**Fix:** add cursor-based or offset pagination via
`Phoenix.LiveView.stream/3` + a "load more" button per index, or pull
in `flop` / `paginator` for query-string-driven paging.

---

## Auth / Security

### `/admin/*` is wide open
**Status:** TODO

Any unauthenticated request can list, create, update, or delete any
row through the admin LiveViews. Demo-only.

**Fix:** add a `:require_admin` plug (or LiveView `on_mount` hook)
that checks a session cookie / API token before granting access. Pair
with `phx.gen.auth` if we want a quick login path, or enforce IP
allowlist / basic auth for the demo.

---

### No CSRF guard on the dev mailbox / dashboard
**Status:** WONTFIX (dev-only)

`/dev/dashboard` and `/dev/mailbox` are gated behind
`Application.compile_env(:symphony, :dev_routes)` and aren't compiled
into prod. Note here for completeness — no fix needed.

---

## Tests

### Generator-produced LiveView and context tests probably fail
**Status:** TODO

`phx.gen.live` writes test files using auto-generated `valid_attrs`
maps that don't know about our `validate_required/2` rules or our
`Ecto.Enum` constraints. For example, `inventory_fixtures.ex` calls
`create_instrument/1` with attrs that don't include `:family`, which
our changeset requires.

**Fix:** rewrite each fixture file's `*_attrs/0` and
`*_fixture/1` helpers to satisfy the real changeset. Keep the
generator-emitted test bodies intact — they're standard CRUD shape.
Consider deleting the generator's `*_test.exs` files entirely if we
write our own.

**Where it bites:** `mix test` — at least the new generator tests
will likely red.

---

### No tests for the seeds script
**Status:** TODO

`priv/repo/seeds.exs` is run only by hand. A regression that breaks
seeding will only surface when someone runs `mix ecto.reset`.

**Fix:** small smoke test in `test/symphony/seeds_test.exs` that
runs the seed script in a sandboxed transaction and asserts row counts.

---

## Schema scaffolds we deliberately skipped

### Musicians admin LiveView
**Status:** TODO

Skipped from the auto-gen pass because the form would have ~17
inputs (login, primary_email, given/family/middle name, account_type,
status, status_details, employee_id, mfa/sso flags, password fields,
icon_url, last_login_at, profile JSON). A useful musician editor
needs grouping ("identity" / "credentials" / "profile") and probably
separate edit screens for password reset vs profile edit.

**Fix:** hand-build the LiveView. Reuse `change_account_*` action
patterns from the SDK design doc instead of a single mega-form.

---

### Audience members admin LiveView
**Status:** TODO

Same shape as Musicians — many fields, multiple addresses and
emails, loyalty tier and points. Skipped for the same reason.

**Fix:** hand-built CRM-style LiveView. Almost certainly wants a
search/filter index too, since the audience table will be the largest
in the system.

---

### Box office (customer-facing) ticket sales LiveView
**Status:** TODO

Tickets, orders, payments are transactional, not CRUD. The box
office wants: pick performance → seat-map picker → cart → checkout →
confirmation. Generator can't produce this.

**Fix:** custom LiveView under `/box-office` (separate from
`/admin`). Drives the Stripe integration (currently stubbed in seed
data).

---

### Seat-map editor (admin)
**Status:** TODO

`Seat` exists as a schema but a CRUD form per seat is absurd — a
venue with 1,500 seats means 1,500 form submissions. Need a bulk
"import seat map" UI or a CSV uploader.

**Fix:** add a bulk-create endpoint on `Symphony.Ticketing`:
`Ticketing.create_seats_for_section(venue_section_id, rows, seats_per_row)`.
Wire to a small LiveView under `/admin/venue_sections/:id/seats`.

---

### Read-only views of audit events and action invocations
**Status:** TODO

`audit_events` and `action_invocations` are append-only logs; no
CRUD form makes sense. Useful as **read-only** LiveViews with
filtering — these are also the connector-dashboard backbone.

**Fix:** `/admin/audit` and `/admin/actions` as filter+stream
LiveViews. Filters: event_type, target_resource_kind, time range.

---

### Junction-table management UIs
**Status:** TODO

Skipped scaffolds: `section_memberships`, `ensemble_memberships`,
`role_permissions`, `role_assignments`, `application_assignments`,
`request_assignees`, `season_subscription_performances`. Each is
better as a sub-UI on its parent (e.g. role_permissions as a checkbox
matrix on the Role show page).

**Fix:** add per-parent sub-UIs as needed when the parent admin form
is being designed.

---

## Operational

### Reservation TTL sweeper not implemented
**Status:** TODO

The design doc describes a `ticket.expire_reservations` global action
that sweeps `tickets` rows where `status='reserved'` and
`reservation_expires_at < now()`. Nothing currently does this. Holds
will accumulate forever.

**Fix:** add an Oban / GenServer cron that runs every minute and
calls a new `Symphony.Ticketing.expire_reservations/0`. Mirror the
result into `audit_events` so the sweep is observable.

---

### Seeds always wipe data
**Status:** TODO

`priv/repo/seeds.exs` deletes every row in dependency order and
reinserts. Safe for a fresh dev database; destructive for anyone
mid-feature with manually-edited data.

**Fix:** check for an env var like `SYMPHONY_SEED_DESTRUCTIVE=1` (or
`MIX_ENV=test`) before deleting, otherwise upsert by slug/login where
possible.

---

### Connector dashboard not built
**Status:** TODO

The point of this whole schema is to be a baton-sdk exemplar. There's
currently no read-only dashboard that shows what a connector would
sync (resources, entitlements, grants, recent events, pending
actions). Useful as a sanity check while building a connector against
this DB.

**Fix:** `/connector-view` LiveView that queries the model the way a
connector would — `ListResources`-shaped paginated views per
resource type, plus an event-feed tail and an action-invocation log.

---

### Default Phoenix landing page still in place
**Status:** TODO

`/` renders `lib/symphony_web/controllers/page_html/home.html.heex`
with the stock "Welcome to Phoenix" content. Confusing for anyone
landing on the demo.

**Fix:** replace with a brief "Symphony Demo" splash and links to
`/admin`, eventually `/box-office` and `/connector-view`.

---

## Tracking

When fixing an issue, change `Status: TODO` to `Status: DONE
(<commit-sha>)` and leave the rest of the entry intact so the
historical context survives.
