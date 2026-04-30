# Known Issues

Tracked gaps from the database + admin LiveView build. Each entry has a
`Status:` line so this can become a working punch list.

---

## Connector integration

### `baton-connector` service user is purely seed data
**Status:** PARTIAL — sync path live, provisioning still TODO

The seed inserts a `Symphony.Identity.Musician` with
`account_type=:service`, `login="baton-connector"`,
`employee_id="SVC-001"`, plus a `Symphony.Secrets.ApiKey` named
"baton-connector primary" with `hashed_secret =
sha256:<sha256("demo-secret")>` pointing at it. Nothing in the
running system uses either row:

- No baton-sdk-shaped API surface (no `/api/baton`, no gRPC, no
  ListResources / ListEntitlements / ListGrants / Grant / Revoke /
  CreateAccount endpoints).
- No API-key auth middleware. Bearer tokens against `/admin/*` or
  any other route are never validated against `api_keys.hashed_secret`.
- No Go connector binary. The cloned `baton-sdk` is a sibling repo
  at `/Volumes/src-apfsx/github.com/highb/baton-sdk`; no
  `baton-symphony` connector lives anywhere.
- No callers consult that musician's session, last_login_at, or
  grants.

This is the **single biggest "schema claims X but nothing implements
X"** gap in the project. The whole point of the schema is to be a
baton-sdk exemplar; right now it's just a database that *could* be a
baton-sdk exemplar.

**Why this matters:** every other capability we've documented in
docs/database-design.md (`SYNC`, `PROVISION`, `ACCOUNT_PROVISIONING`,
`EVENT_FEED_V2`, etc.) is theoretical until something at the wire
level actually exercises them.

**Fix (in dependency order):**

1. **Symphony API.** Add a new `SymphonyWeb.Api` scope that exposes
   the resource surface in baton-sdk shape. JSON-over-HTTP is
   simplest; gRPC is closer to baton's native protocol but pulls in
   a much heavier toolchain. JSON paths roughly mirror the SDK
   service methods:
   - `GET /api/v1/resource_types`
   - `GET /api/v1/resources?resource_type_id=…&page_token=…`
   - `GET /api/v1/resources/:type/:id`
   - `GET /api/v1/entitlements?resource_type_id=…`
   - `GET /api/v1/grants?resource_type=…&resource_id=…`
   - `POST /api/v1/grants` / `DELETE /api/v1/grants/:id`
   - `POST /api/v1/accounts` (CreateAccount)
   - `POST /api/v1/credentials/rotate`
   - `GET /api/v1/events?cursor=…` (event feed)
   - `POST /api/v1/actions/invoke` / `GET /api/v1/actions/:id`
   - `GET /api/v1/tickets/schemas` + ticket CRUD

2. **API-key auth plug.** Pipeline plug that:
   - Reads `Authorization: Bearer <token>` from the request.
   - Hashes the token (`:crypto.hash(:sha256, token) |>
     Base.encode16(case: :lower) |> ("sha256:" <> &1)`).
   - Looks up the row in `api_keys` where `hashed_secret` matches
     and `expires_at` is nil or > now.
   - Sets `assigns[:current_actor]` to the linked Musician.
   - Updates `last_used_at`.
   - Emits a `usage` audit_event.
   - Rejects with 401 otherwise.

3. **Authorization layer.** Once the actor is known, gate each
   endpoint by checking `Symphony.Rbac.has_permission?(actor,
   permission_slug)` against the seeded role catalog. The
   `baton-connector` service account would need a role with `*:read`
   for sync and explicit grant-management permissions for
   provisioning.

4. **`baton-symphony` connector** in a separate Go repo. Implements
   `connectorbuilder.ConnectorBuilderV2`, `ResourceProvisionerV2`,
   `AccountManagerV2`, `CredentialManager`, `EventProviderV2`,
   `TicketManager`, and `GlobalActionProvider` against the Symphony
   JSON API. Configured with the bearer token; advertises the full
   capability set documented in docs/database-design.md §4.

5. **Connector dashboard** (separate ISSUES.md entry below) becomes
   a useful read-only mirror of what the connector sees, useful for
   debugging.

Once those four exist and the Go connector successfully syncs into a
local C1 instance (or `baton` CLI for local exercise), the seed row
stops being a placeholder.

**Progress (2026-04-29):**

- ✅ **Step 1 (API surface):** done. 16 CRUD resource endpoints (`mix
  phx.gen.json`) plus hand-written `/api/v1/resource_types`,
  `/api/v1/entitlements`, `/api/v1/grants`, `/api/v1/events`,
  `/api/v1/whoami` — see commits `d5aefea`, `cd36ee4`, `c54552c`,
  `b28577f`. Grant *writes*, account creation, credential rotation,
  and action invoke/status are NOT yet implemented; sync-only path
  is complete.
- ✅ **Step 2 (auth):** done in `b28577f`.
  `SymphonyWeb.Plugs.ApiAuth` validates `Authorization: Bearer …`
  against `api_keys.hashed_secret`, sets `:current_actor`.
- ✅ **Step 3 (authz):** done in `b28577f`. `Symphony.Authz` joins
  `role_assignments → role_permissions → permissions`.
  Per-endpoint `RequirePermission` plug exists but is not yet wired
  to any endpoint — see "Per-endpoint permission gates" below.
- ✅ **Bonus — rate limiting:** done in `44211fd`. `hammer`-backed
  per-API-key buckets (6000/min read, 600/min write) emit 429 with
  `Retry-After` and a `RateLimitDescription`-shaped JSON body so
  connector retry logic exercises end-to-end.
- 🟡 **Step 4 (connector binary):** instead of a custom Go binary
  using baton-sdk, switched to **baton-http** (config-driven).
  Connector config lives at `baton-http/symphony.yaml` (relative to
  the demo-app repo root). Wires up sync of musicians,
  audience_members, sections, ensembles, roles, applications,
  instruments, equipment, sheet_music, performances, and
  season_subscriptions plus their grants. Skipped per design:
  api_key, door_badge, security_finding, role_scope_binding, venue,
  venue_section, seat, promo_code (no useful grants in current
  data model).
- 🟡 **Provisioning** (`POST/DELETE /api/v1/grants`,
  `POST /api/v1/accounts/create_account`,
  `POST /api/v1/credentials/rotate`,
  `POST /api/v1/actions/invoke` + status) is still TODO on the
  Symphony side, and baton-http's README marks provisioning as
  "Coming soon" too. So sync-only is the end state until both
  sides ship grant writes.

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
**Status:** DONE (e147ce5)

Skipped from the auto-gen pass because the form would have ~17
inputs (login, primary_email, given/family/middle name, account_type,
status, status_details, employee_id, mfa/sso flags, password fields,
icon_url, last_login_at, profile JSON). A useful musician editor
needs grouping ("identity" / "credentials" / "profile") and probably
separate edit screens for password reset vs profile edit.

**Fix:** hand-build the LiveView. Reuse `change_account_*` action
patterns from the SDK design doc instead of a single mega-form.

**Resolution:** hand-built `MusicianLive.{Index,Show,Form}`. Index
is searchable (login/email/name/employee_id) + status-filterable.
Show renders 6 grouped sections (Identity, Status, Auth, Profile,
Emails, Login aliases) with preloaded has_many associations. Form
groups 3 fieldsets (Identity, Status, Auth) with select inputs for
the account_type and status enums. Password rotation as a separate
action-driven flow is still TODO — see new "Credential rotation /
account-action UI" entry below.

---

### Audience members admin LiveView
**Status:** DONE (e147ce5)

Same shape as Musicians — many fields, multiple addresses and
emails, loyalty tier and points. Skipped for the same reason.

**Fix:** hand-built CRM-style LiveView. Almost certainly wants a
search/filter index too, since the audience table will be the largest
in the system.

**Resolution:** hand-built `AudienceMemberLive.{Index,Show,Form}`.
Index has search + status filter + loyalty-tier filter, tier badges,
marketing-opt-in indicator. Show renders Identity, Status, Loyalty
(tier / points / marketing-opt-in), Auth, Emails, and Addresses
sections. Form has 4 fieldsets (Identity, Status, Loyalty, Auth)
with the loyalty_tier select and points number input.

---

### Per-endpoint permission gates not wired to API routes
**Status:** TODO

`SymphonyWeb.Plugs.RequirePermission` exists (`b28577f`) and reads
`Symphony.Authz` for permission checks, but no API route currently
plugs it. Authenticated = anything-goes. The seeded `baton_connector`
role has all 41 permissions so the connector works regardless, but
a future read-only role couldn't be enforced.

**Fix:** add `plug SymphonyWeb.Plugs.RequirePermission, "<slug>"` to
each controller, mapping endpoints to permission slugs from the
catalog. Skeleton:
- GET `/musicians`, `/musicians/:id` → `musician:read_all`
- POST `/musicians` → `musician:create`
- DELETE `/musicians/:id` → `musician:disable` (we don't have a
  `:delete` slug; using disable is a closer match to the SDK's
  account-action semantics)
- similar pattern for the rest

Once wired, add a second seeded role (e.g. `read_only_connector`)
with just `*:read_all` permissions to demonstrate the gate.

---

### Credential rotation / account-action UI
**Status:** TODO

The Musician and AudienceMember forms expose a raw `password_hash`
text input for back-office override, but the proper provisioning
path is the SDK-modeled action set: `musician.create_account`,
`musician.disable`, `musician.enable`, `musician.update_profile`,
plus `api_key.rotate` and `door_badge.revoke`. There's no UI for
any of these yet — they'd be buttons on the show pages that record
into `action_invocations` and emit `audit_events`.

**Fix:** add per-resource action buttons that POST through a new
`Symphony.Actions` context, write `action_invocations` rows, and
emit corresponding `audit_events`. Mirror the credential-options
shape from baton-sdk (random / no / SSO / encrypted password) for
account creation.

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

### Chaos / "real-world API" toggles for connector exercising
**Status:** TODO

Real connectors stumble on a predictable shortlist of upstream
behaviors that aren't tested in textbook unit tests. Symphony already
has the schema to model them; what it needs is an admin page that
toggles each behavior on/off so a connector author can run their sync
against each toggle and watch what blows up. Goes after the API +
auth slice (these toggles need an API surface to bend).

**Tier 1 (must-have):**
- **Latency injection** — slider 0-30s per endpoint class
  (read / write / event_feed). Catches connectors that don't set
  HTTP timeouts.
- **5xx flake rate** — percent chance of returning 503 + Retry-After.
  Tests retry/backoff.
- **Pagination cursor expiry** — cursors return 410 Gone with a fresh
  resume cursor. Tests connector resume logic.
- **Token rotation mid-sync** — next N requests return 401 forcing
  re-auth. Tests credential-rotation flow.
- **Rate-limit dishonesty** — 429 says `Retry-After: 1` but actually
  keeps 429ing for 30s. Tests connectors that trust the header
  blindly.

**Tier 2 (nice-to-have):**
- **Stale read after write** — `Grant` returns success but
  `ListGrants` lags by N seconds.
- **Async action drag** — action stays `PENDING` for N seconds.
- **Inconsistent pagination** — duplicates across pages, empty pages
  with `has_more=true`, oversize pages.
- **Orphaned resources** — `parent_resource_id` points at deleted
  rows.
- **Action-says-complete-but-state-lags** — `GetActionStatus`
  returns `COMPLETE` but resource state hasn't propagated.

**Implementation sketch:**
- `/admin/chaos` LiveView.
- `Symphony.Chaos` GenServer (ETS-backed, BEAM-session scoped — toggles
  reset on `mix phx.server` restart, which is the right default).
- API plug consults the GenServer on each request before calling the
  controller body.
- Two organizational moves:
  1. **Group toggles by what they test** ("retry/backoff", "resume
     logic", "consistency tolerance") not by what they do, so connector
     authors browse by capability they want to verify.
  2. **One-click presets**: "Healthy", "Flaky upstream", "Eventually
     consistent", "Hostile". Each preset flips a coordinated set of
     toggles.

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
