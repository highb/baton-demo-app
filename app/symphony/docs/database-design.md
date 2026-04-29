# Symphony Database Design

A SQLite-backed schema for a Phoenix app that runs a working symphony — its
musicians, instruments, sheet music, performances, and ticket sales — and
that is fully manageable by a `baton-sdk` connector.

## 1. Goals

1. **Run a real symphony.** Track musicians, who plays in which section,
   what instruments and equipment they have checked out, what sheet music
   they can access, what performances they're scheduled for.
2. **Sell tickets.** Run a working box office: seat maps, pricing, orders,
   payments, refunds, season subscriptions, waitlists, comps, promo codes.
3. **Be a complete `baton-sdk` exemplar.** Every resource trait, every
   capability, every action type, and every event type the SDK supports
   should have a non-trivial home in this schema. A connector built against
   this database should exercise the full SDK surface.
4. **Run on SQLite.** Single file on disk; no external services required to
   develop, demo, or run the app. WAL mode for concurrency.

## 2. Two-user-trait architecture

The schema models **two distinct user populations** as separate resource
types, both carrying the SDK's `TRAIT_USER`:

- **`musicians`** — staff. Players, conductors, librarians, stage managers,
  box-office agents. They have employee IDs, payroll-shaped lifecycle, an
  internal SSO identity, and a role catalog tied to running the orchestra.
- **`audience_members`** — customers. They buy tickets, hold subscriptions,
  earn loyalty points, opt in/out of marketing, and have a separate consumer
  SSO / password lifecycle.

Don't merge them. Two `TRAIT_USER` resource types in one connector is
idiomatic baton — Okta-shaped connectors do the same with employees and
end-users. Their role catalogs, account-creation schemas, and revocation
semantics are different enough that one table would be a constant
discriminator-column dance.

## 3. Layers

### 3.1 Domain layer

Models the physical reality of running an orchestra.

| Table | Purpose | SDK trait (if any) |
|---|---|---|
| `musicians`, `musician_emails`, `musician_login_aliases` | Staff identities | `TRAIT_USER` |
| `audience_members`, `audience_emails`, `audience_addresses` | Customer identities | `TRAIT_USER` |
| `sections`, `section_memberships` | Instrument families ("strings", "brass") and who plays in each | `TRAIT_GROUP` |
| `ensembles`, `ensemble_memberships` | Performance groupings (full orchestra, chamber, pit, quartet) | `TRAIT_GROUP` |
| `venues` | Physical locations; rehearsal halls, concert halls | (untraited) |
| `instruments` | Checkoutable instruments (asset-tagged) | (untraited) |
| `equipment` | Mics, stands, mutes, cables, pedals | (untraited) |
| `sheet_music`, `sheet_music_parts` | Library scores and per-instrument parts | (untraited) |
| `performances`, `performance_setlist` | Scheduled rehearsals/concerts/recordings | (untraited) |

`sections` are nested (`parent_section_id`): "1st violins" parents into
"strings". This gives the connector a real `parent_resource_id` chain to
exercise, not just flat lists.

### 3.2 RBAC layer

Standard role-based access control, expressed in a way that the connector
can reflect into baton's entitlement / grant / scope-binding model.

| Table | Purpose | SDK mapping |
|---|---|---|
| `roles` | Role catalog: `music_director`, `section_leader`, `librarian`, `box_office_agent`, etc. | `TRAIT_ROLE` |
| `permissions` | Vocabulary of capabilities: `instrument:checkout`, `sheet_music:read` | (defines entitlement names) |
| `role_permissions` | role × permission junction | (assembles entitlements per role) |
| `role_assignments` | role → musician/audience_member grants | grants of the `member` assignment-entitlement |
| `role_scope_bindings` | role × (section ∣ ensemble ∣ venue) | `TRAIT_SCOPE_BINDING` |
| `resource_owners` | ownership-purpose entitlements (primary, secondary, curator) | ownership entitlements |
| `applications`, `application_assignments` | DAW, library portal, scheduler, box-office app | `TRAIT_APP` |

### 3.3 Checkouts layer

Materializes "this person currently has this thing" relationships. These
are entitlement grants in baton's view; an open row is an active grant,
setting the return timestamp is a revoke.

| Table | What it grants |
|---|---|
| `instrument_checkouts` | `instrument:checkout` permission entitlement → musician |
| `equipment_checkouts` | `equipment:checkout` permission entitlement → musician |
| `sheet_music_access` | `sheet_music:read` permission entitlement → musician (for restricted scores) |

Open rows (NULL `returned_at`) are filtered indexes for fast "who has X
right now" queries.

### 3.4 Ticketing layer (performance management)

Powers the box office: seat maps, pricing, orders, payments, refunds,
subscriptions, waitlists.

| Table | Purpose |
|---|---|
| `venue_sections` | Named seating sections within a venue (Orchestra, Mezzanine, Box A) |
| `seats` | Individual seats with row, number, accessibility flag |
| `price_tiers` | Premium / Standard / Student / Comp |
| `performance_pricing` | (performance, section, tier) → cents + on-sale window |
| `performance_on_sale_state` | Per-performance lifecycle: draft / announced / on_sale / sold_out / cancelled / closed |
| `tickets` | An issued seat for a performance — status reserved/sold/used/refunded/voided/comped |
| `orders`, `order_items` | Purchase headers and line items |
| `payments`, `refunds` | Captured payments and partial/full refunds |
| `promo_codes` | Discount codes |
| `season_subscriptions`, `season_subscription_performances` | The package SKU and its included performances |
| `subscription_holdings` | A subscription granted to an audience member |
| `waitlist_entries` | Waitlist state per (performance, audience member) |

A `tickets` row is **both** an operational record and a baton-managed grant
of the `attend` permission entitlement on a `performance` resource. Listing
grants for a performance = `SELECT … FROM tickets WHERE performance_id = ?`.

### 3.5 Cross-cutting tables

Glue layer that gives the SDK its non-resource capabilities:

| Table | Capability backed |
|---|---|
| `api_keys`, `door_badges` | `TRAIT_SECRET` — synced and rotatable |
| `security_findings` | `TRAIT_SECURITY_INSIGHT` |
| `request_schemas`, `request_custom_field_defs`, `requests`, `request_assignees` | `TICKETING` capability — the SDK's "ticket" sense (refund disputes, accessibility requests, group-sales inquiries) |
| `audit_events` | `EVENT_FEED_V2` — single immutable log table; cursor = `(occurred_at, id)` |
| `action_invocations` | `ACTIONS` capability — record of every connector-invoked action |

## 4. baton-sdk capability map

Every SDK capability has a concrete home in this schema:

| Capability | Implementation |
|---|---|
| `SYNC` | `ResourceSyncer` over each resource-type table |
| `TARGETED_SYNC` | Single-row lookups on the same tables |
| `PROVISION` | Grant/Revoke on `role_assignments`, `section_memberships`, `ensemble_memberships`, `application_assignments`, `sheet_music_access`, `instrument_checkouts`, `equipment_checkouts`, `tickets` (comps), `subscription_holdings` |
| `RESOURCE_CREATE` | Create rows in `instruments`, `equipment`, `sheet_music`, `sections`, `ensembles`, `roles`, `performances`, `season_subscriptions`, `venue_sections`, `seats`, `promo_codes` |
| `RESOURCE_DELETE` | Soft-delete or hard-delete on the above; cascades to junction tables |
| `ACCOUNT_PROVISIONING` | `CreateAccount` writes `musicians` (staff) or `audience_members` (customers); honors all four credential options (random, none, SSO, encrypted) |
| `CREDENTIAL_ROTATION` | Resets `password_hash` on users; rotates `api_keys` (with `rotated_from_id` chain); reissues `door_badges` |
| `EVENT_FEED_V2` | Two feeds: usage (door scans) and lifecycle (resource_change / create_grant / create_revoke) |
| `TICKETING` | `request_schemas`/`requests` — schemas for refund-dispute, accessibility, group-sales |
| `ACTIONS` | Per-resource-type and global actions (see §5) |
| `SYNC_SECRETS` | `api_keys` and `door_badges` exposed via `TRAIT_SECRET` |
| `SERVICE_MODE_TARGETED_SYNC` | Same as targeted sync; service-mode runtime variant |

## 5. Action catalog

Implemented via `GlobalActionProvider` and per-resource-type
`ResourceActionProvider`.

### 5.1 Account actions (musicians and audience members)

- `musician.disable` (`ACTION_TYPE_ACCOUNT_DISABLE`)
- `musician.enable` (`ACTION_TYPE_ACCOUNT_ENABLE`)
- `musician.update_profile` (`ACTION_TYPE_ACCOUNT_UPDATE_PROFILE`)
- `audience.disable` / `audience.enable` / `audience.update_profile`
- `audience.merge_duplicates` (global; CRM-style dedup)

### 5.2 Resource lifecycle actions

- `instrument.retire` / `instrument.send_to_maintenance` / `instrument.return`
- `equipment.retire`
- `sheet_music.archive`
- `door_badge.revoke`

### 5.3 Performance & ticketing actions

- `performance.publish` (draft → on_sale)
- `performance.cancel` (cancels and bulk-refunds; `ACTION_TYPE_RESOURCE_DISABLE`)
- `ticket.refund` / `ticket.void` / `ticket.transfer` / `ticket.scan`
- `ticket.expire_reservations` (global sweep job; visible in audit)
- `subscription.convert_to_grants` (materializes individual `tickets` from
  a `subscription_holding` for each included performance)

### 5.4 Inventory / housekeeping

- `inventory.audit` (global, dynamic) — emits a snapshot to `audit_events`
- `roster.export` (global, dynamic) — bulk export hook

## 6. Entitlements catalog

Three purposes: **assignment** (membership), **permission** (capability),
**ownership** (curator/owner).

| Resource type | Entitlement | Purpose | Grantable to |
|---|---|---|---|
| `role` | `member` | assignment | `musician`, `audience_member` |
| `section` | `member`, `principal` | assignment | `musician` |
| `ensemble` | `member`, `concertmaster` | assignment | `musician` |
| `application` | `assigned` | assignment | `musician` |
| `instrument` | `checkout` | permission | `musician` |
| `equipment` | `checkout` | permission | `musician` |
| `sheet_music` | `read` | permission | `musician` |
| `performance` | `attend` | permission | `audience_member` |
| `performance` | `box_office_manage` | permission | `musician` |
| `venue_section` | `usher` | permission | `musician` |
| `season_subscription` | `holder` | assignment | `audience_member` |
| `promo_code` | `redeem` | permission | `audience_member` |
| `instrument`, `sheet_music`, `ensemble` | `owner`, `curator` | ownership | `musician` |

## 7. Event feeds

Single `audit_events` table, two logical feeds exposed via
`EventProviderV2`:

- **Usage feed** — `event_type='usage'`. Door scans, login events,
  application launches.
- **Lifecycle feed** — `event_type IN ('resource_change','create_grant','create_revoke')`.
  Performance state transitions, role assignments/removals, ticket
  comps/voids, subscription changes.

Cursor: lexicographic on `(occurred_at, id)`. The connector's pagination
implementation re-emits events strictly in cursor order.

## 8. Schema module organization

Elixir contexts mirror the layer boundaries:

```
lib/symphony/
  identity/      # Musician, AudienceMember, emails, login aliases, addresses
  orchestra/    # Section, Ensemble, Venue + memberships
  inventory/    # Instrument, Equipment, SheetMusic, SheetMusicPart
  rbac/         # Role, Permission, RoleAssignment, RoleScopeBinding,
                # ResourceOwner, Application, ApplicationAssignment
  checkouts/    # InstrumentCheckout, EquipmentCheckout, SheetMusicAccess
  scheduling/   # Performance, PerformanceSetlistEntry
  ticketing/    # VenueSection, Seat, PriceTier, PerformancePricing,
                # PerformanceOnSaleState, Ticket, Order, OrderItem,
                # Payment, Refund, PromoCode, SeasonSubscription,
                # SeasonSubscriptionPerformance, SubscriptionHolding,
                # WaitlistEntry
  secrets/      # ApiKey, DoorBadge
  security/    # Finding
  requests/     # Schema, CustomFieldDef, Request, RequestAssignee
  audit/        # Event
  actions/      # Invocation
```

## 9. Data-model invariants & gotchas

1. **One open checkout per asset.** Partial unique indexes on
   `instrument_checkouts` and `equipment_checkouts` enforce
   "at most one open checkout per asset" via
   `WHERE returned_at IS NULL`.
2. **One ticket per (performance, seat).** `UNIQUE(performance_id, seat_id)`
   on `tickets` prevents double-issuance.
3. **One subscription holding per (subscription, audience member).**
   `UNIQUE(subscription_id, audience_member_id)` on
   `subscription_holdings`.
4. **No PCI data.** `payments.last4` only — never PAN. The provider's
   charge ID is the source of truth for refunds.
5. **Reserved-seat TTL.** `tickets.status='reserved'` rows have
   `reservation_expires_at`. A periodic action
   (`ticket.expire_reservations`) sweeps them. Sweep is itself an audit
   event so reservations have a clear lifecycle in the event feed.
6. **Ticket holders are nullable.** `tickets.audience_member_id` is NULL
   for reserves and unassigned holds; assigned at sale or comp time.
7. **JSON fields use `:map`.** SQLite stores them as TEXT; ecto_sqlite3
   transparently encodes/decodes.
8. **Composite primary keys** are used on pure junction tables
   (memberships, role_permissions, request_assignees, etc.) to avoid
   surrogate-key noise.
9. **Soft-delete on users.** `status='deleted'` on `musicians` /
   `audience_members` instead of removing rows, so historical
   grants/orders remain attributable.

## 10. Future extensions (not yet implemented)

- **Donor / fundraising layer.** Pledges, gifts, donor-circle membership.
  Maps cleanly into a new resource type with its own assignment
  entitlement. Loyalty-tier-style.
- **Streaming rights.** Per-performance recording-and-distribution
  permissions for musicians' union compliance. Fits into existing
  permission-entitlement model.
- **Volunteer / docent model.** Third user-trait population if it grows
  beyond a handful of people; otherwise a role on `audience_members`.
- **Multi-tenant.** Add a `tenants` table and a `tenant_id` column
  everywhere. Out of scope for v0; the demo is single-tenant.

## 11. Configuration

- **Repo adapter:** `Ecto.Adapters.SQLite3`.
- **Database files:**
  - dev: `config/../symphony_dev.db` (relative to config dir → `app/symphony/symphony_dev.db`)
  - test: `config/../symphony_test{partition}.db`
  - prod: `DATABASE_PATH` environment variable (required).
- **PRAGMAs:** `journal_mode=wal`, `cache_size=-64000`, `temp_store=memory`.
- **Test isolation:** `Ecto.Adapters.SQL.Sandbox` (works with
  ecto_sqlite3 in shared mode).
