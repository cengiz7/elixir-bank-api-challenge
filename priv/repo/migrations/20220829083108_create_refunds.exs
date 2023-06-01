defmodule Bank.Repo.Migrations.CreateRefunds do
  use Ecto.Migration

  def change do
    create table(:refunds, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :payment_id, references(:payments, type: :uuid)
      add :merchant_ref, :string, null: false
      add :amount, :integer, null: false

      timestamps()
    end

    create index(:refunds, [:id], unique: true)
    create index(:refunds, [:merchant_ref], unique: true)
    create index(:refunds, [:payment_id])
  end
end
