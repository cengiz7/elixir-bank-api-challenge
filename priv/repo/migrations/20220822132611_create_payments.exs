defmodule Bank.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :amount, :integer, null: false
      add :merchant_ref, :string, null: false
      add :card_number, :string, null: false
      add :status, :string, null: false

      timestamps()
    end

    create index(:payments, [:id], unique: true)
    create index(:payments, [:merchant_ref], unique: true)
    create index(:payments, [:card_number], unique: true)
  end
end
