defmodule Symphony.Repo.Migrations.CreateTicketing do
  use Ecto.Migration

  def change do
    create table(:venue_sections) do
      add :venue_id, references(:venues, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :display_order, :integer, default: 0, null: false
      add :capacity, :integer, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:venue_sections, [:venue_id, :name])

    create table(:seats) do
      add :venue_section_id, references(:venue_sections, on_delete: :delete_all), null: false
      add :row_label, :string, null: false
      add :seat_number, :string, null: false
      add :accessibility, :string, null: false, default: "standard"

      timestamps(type: :utc_datetime)
    end

    create unique_index(:seats, [:venue_section_id, :row_label, :seat_number])

    create table(:price_tiers) do
      add :slug, :string, null: false
      add :display_name, :string, null: false
      add :is_comp, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:price_tiers, [:slug])

    create table(:performance_pricing) do
      add :performance_id, references(:performances, on_delete: :delete_all), null: false
      add :venue_section_id, references(:venue_sections, on_delete: :restrict), null: false
      add :price_tier_id, references(:price_tiers, on_delete: :restrict), null: false
      add :price_cents, :integer, null: false
      add :on_sale_at, :utc_datetime
      add :off_sale_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:performance_pricing,
             [:performance_id, :venue_section_id, :price_tier_id])

    create table(:performance_on_sale_states, primary_key: false) do
      add :performance_id, references(:performances, on_delete: :delete_all),
        primary_key: true, null: false
      add :status, :string, null: false
      add :announced_at, :utc_datetime
      add :on_sale_at, :utc_datetime
      add :cancelled_at, :utc_datetime
      add :cancellation_reason, :string

      timestamps(type: :utc_datetime)
    end

    create table(:season_subscriptions) do
      add :slug, :string, null: false
      add :display_name, :string, null: false
      add :description, :string
      add :ensemble_id, references(:ensembles, on_delete: :nilify_all)
      add :total_seats_per_holder, :integer, default: 1, null: false
      add :base_price_cents, :integer, null: false
      add :on_sale_at, :utc_datetime
      add :off_sale_at, :utc_datetime
      add :active, :boolean, default: true, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:season_subscriptions, [:slug])

    create table(:season_subscription_performances, primary_key: false) do
      add :subscription_id, references(:season_subscriptions, on_delete: :delete_all),
        primary_key: true, null: false
      add :performance_id, references(:performances, on_delete: :delete_all),
        primary_key: true, null: false

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:season_subscription_performances, [:performance_id])

    create table(:promo_codes) do
      add :code, :string, null: false
      add :display_name, :string, null: false
      add :discount_kind, :string, null: false
      add :discount_value, :integer, null: false
      add :min_total_cents, :integer, default: 0, null: false
      add :starts_at, :utc_datetime
      add :ends_at, :utc_datetime
      add :max_redemptions, :integer
      add :current_redemptions, :integer, default: 0, null: false
      add :applies_to_performance_id, references(:performances, on_delete: :nilify_all)
      add :active, :boolean, default: true, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:promo_codes, [:code])

    create table(:orders) do
      add :order_number, :string, null: false
      add :audience_member_id, references(:audience_members, on_delete: :restrict), null: false
      add :status, :string, null: false
      add :subtotal_cents, :integer, default: 0, null: false
      add :discount_cents, :integer, default: 0, null: false
      add :fees_cents, :integer, default: 0, null: false
      add :tax_cents, :integer, default: 0, null: false
      add :total_cents, :integer, default: 0, null: false
      add :currency, :string, default: "USD", null: false
      add :promo_code_id, references(:promo_codes, on_delete: :nilify_all)
      add :channel, :string, null: false
      add :placed_by_id, references(:musicians, on_delete: :nilify_all)
      add :placed_at, :utc_datetime, null: false
      add :notes, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:orders, [:order_number])
    create index(:orders, [:audience_member_id])
    create index(:orders, [:status])

    create table(:subscription_holdings) do
      add :subscription_id, references(:season_subscriptions, on_delete: :restrict), null: false
      add :audience_member_id, references(:audience_members, on_delete: :restrict), null: false
      add :seat_id, references(:seats, on_delete: :nilify_all)
      add :acquired_via_order_id, references(:orders, on_delete: :nilify_all)
      add :acquired_at, :utc_datetime, null: false
      add :expires_at, :utc_datetime
      add :status, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:subscription_holdings, [:subscription_id, :audience_member_id])
    create index(:subscription_holdings, [:audience_member_id])

    create table(:order_items) do
      add :order_id, references(:orders, on_delete: :delete_all), null: false
      add :kind, :string, null: false
      add :performance_id, references(:performances, on_delete: :nilify_all)
      add :subscription_id, references(:season_subscriptions, on_delete: :nilify_all)
      add :description, :string, null: false
      add :unit_price_cents, :integer, null: false
      add :quantity, :integer, default: 1, null: false
      add :line_total_cents, :integer, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:order_items, [:order_id])

    create table(:tickets) do
      add :performance_id, references(:performances, on_delete: :restrict), null: false
      add :seat_id, references(:seats, on_delete: :restrict), null: false
      add :price_tier_id, references(:price_tiers, on_delete: :restrict), null: false
      add :price_cents_paid, :integer, null: false
      add :audience_member_id, references(:audience_members, on_delete: :nilify_all)
      add :order_item_id, references(:order_items, on_delete: :nilify_all)
      add :status, :string, null: false
      add :reservation_expires_at, :utc_datetime
      add :barcode, :string, null: false
      add :issued_at, :utc_datetime, null: false
      add :used_at, :utc_datetime
      add :refunded_at, :utc_datetime
      add :refund_reason, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:tickets, [:performance_id, :seat_id])
    create unique_index(:tickets, [:barcode])
    create index(:tickets, [:audience_member_id])
    create index(:tickets, [:performance_id, :status])

    create table(:payments) do
      add :order_id, references(:orders, on_delete: :delete_all), null: false
      add :provider, :string, null: false
      add :provider_charge_id, :string
      add :amount_cents, :integer, null: false
      add :currency, :string, default: "USD", null: false
      add :status, :string, null: false
      add :last4, :string
      add :captured_at, :utc_datetime
      add :refunded_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:payments, [:order_id])

    create table(:refunds) do
      add :payment_id, references(:payments, on_delete: :restrict), null: false
      add :ticket_id, references(:tickets, on_delete: :nilify_all)
      add :amount_cents, :integer, null: false
      add :reason, :string, null: false
      add :issued_by_id, references(:musicians, on_delete: :restrict), null: false
      add :issued_at, :utc_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:refunds, [:payment_id])
    create index(:refunds, [:ticket_id])

    create table(:waitlist_entries) do
      add :performance_id, references(:performances, on_delete: :delete_all), null: false
      add :audience_member_id, references(:audience_members, on_delete: :delete_all), null: false
      add :party_size, :integer, default: 1, null: false
      add :max_price_cents, :integer
      add :joined_at, :utc_datetime, null: false
      add :notified_at, :utc_datetime
      add :fulfilled_at, :utc_datetime
      add :expired_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:waitlist_entries, [:performance_id, :audience_member_id])
  end
end
