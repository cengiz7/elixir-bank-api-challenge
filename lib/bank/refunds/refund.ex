defmodule Bank.Refunds.Refund do
  @moduledoc """
  Module and schema representing a refund.

  A refund is always tied to a specific payment record, but it is possible
  to make partial refunds (i.e. refund less than the total payment amount).
  In the same vein, it is possible to apply several refunds against the same
  payment record, the but sum of all refunded amounts for a given payment can
  never surpass the original payment amount.

  If a refund is persisted in the database, it is considered effective: the
  bank's client will have the money credited to their account.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Bank.Payments.Payment

  @type t :: %__MODULE__{}

  @required_fields [:payment_id, :merchant_ref, :amount]

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "refunds" do
    field :amount, :integer
    field :merchant_ref, :string

    belongs_to :payment, Payment, type: :binary_id

    timestamps()
  end

  @doc """
  Returns a changeset for given Refund and attributes to change.
  """
  @spec changeset(t(), attrs :: map) :: Ecto.Changeset.t()
  def changeset(refund, attrs) do
    refund
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_number(:amount, greater_than: 0)
    |> unique_constraint(:merchant_ref)
    |> foreign_key_constraint(:payment_id)
    |> check_constraint(:amount, name: :payment_refund_amount_constraint, message: "excessive refund amount requested")
  end

  def payment_id_format_valid?(%{"payment_id" => id}) do
    case Ecto.UUID.cast(id) do
      :error -> {:error, :not_found}
      _ -> :ok
    end
  end

  @spec classify_changeset_error(%{errors: nonempty_list()}) :: atom()
  def classify_changeset_error(%{errors: errors}) do
    case List.first(errors) do
      {:amount, {_msg, _opts}} -> :error
      {:payment_id, {_msg, _opts}} -> :not_found
      _error -> :error
    end
  end
end
