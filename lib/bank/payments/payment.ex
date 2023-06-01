defmodule Bank.Payments.Payment do
  @moduledoc """
  Module and schema representing a payment.

  Once a payment has been persisted with an "approved" state, the merchant is guaranteed to
  receive money from the bank: they can therefore release the purchased goods to the customer.

  Other payment statuses:

  * processing: the payment is being processed, and it's state is unknown
  * declined: the payment was declined by the bank (e.g. insufficient funds)
  * failed: the payment was unable to complete (e.g. banking system crashed)
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Bank.Repo
  alias Bank.Refunds.Refund
  alias Bank.Accounts.Service, as: AccountService
  alias Bank.PaymentInstruments.Card

  @type t :: %__MODULE__{}
  @type status :: :processing | :approved | :declined | :failed
  @type verification_errors ::
          :insufficient_funds
          | :invalid_account_number
          | :service_unavailable
          | :internal_error

  @status [:processing, :approved, :declined, :failed]
  @required_fields [:amount, :merchant_ref, :card_number, :status]

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "payments" do
    field :amount, :integer
    field :merchant_ref, :string
    field :card_number, :string
    field :status, Ecto.Enum, values: @status

    has_many :refunds, Refund

    timestamps()
  end

  @doc false
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_number(:amount, greater_than_or_equal_to: 0)
    |> unique_constraint(:merchant_ref)
    |> unique_constraint(:card_number)
  end

  def pre_payment_constraint_validations(changeset) do
    changeset
    |> unsafe_validate_unique([:merchant_ref], Repo)
    |> unsafe_validate_unique([:card_number], Repo)
  end

  @spec verify_account_funds(Ecto.Changeset.t()) ::
          {verification_errors | :ok, AccountService.hold_ref() | nil, Ecto.Changeset.t()}
  def verify_account_funds(changeset) do
    changes = changeset.changes
    {:ok, card} = Card.from_string(changes.card_number)
    account_number = Card.account_number(card)

    case AccountService.place_hold(account_number, changes.amount) do
      {:error, :insufficient_funds} -> {:insufficient_funds, nil, put_change(changeset, :status, :declined)}
      {:error, :invalid_account_number} -> {:invalid_account_number, nil, put_change(changeset, :status, :declined)}
      {:error, :service_unavailable} -> {:service_unavailable, nil, put_change(changeset, :status, :failed)}
      {:error, :internal_error} -> {:internal_error, nil, put_change(changeset, :status, :failed)}
      {:ok, hold_reference} -> {:ok, hold_reference, put_change(changeset, :status, :approved)}
    end
  end

  @spec withdraw_account_funds(:ok | :error, AccountService.hold_ref()) :: any()
  def withdraw_account_funds(:ok, hold_reference) do
    AccountService.withdraw_funds(hold_reference)
    AccountService.release_hold(hold_reference)
  end
  def withdraw_account_funds(_, _), do: nil

  @spec release_account_funds(:ok | :error, AccountService.hold_ref()) :: any()
  def release_account_funds(:ok, hold_reference) do
    AccountService.release_hold(hold_reference)
  end
  def release_account_funds(_, _), do: nil
end
