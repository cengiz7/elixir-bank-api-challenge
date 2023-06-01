defmodule Bank.Payments do
  @moduledoc """
  The Payments context.
  """

  import Ecto.Query, warn: false

  alias Bank.Repo
  alias Bank.Payments.Payment
  alias Bank.Payments.Validator, as: PaymentValidator

  @doc """
  Gets a single payment.

  Raises `Ecto.NoResultsError` if the Payment does not exist.

  ## Examples

      iex> get!(123)
      %Payment{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(Payment, id)

  @doc """
  Creates a payment.
  """
  @spec create(attrs :: map()) :: {atom(), Ecto.Changeset.t()} | any()
  def create(attrs \\ %{}) do
    with changeset <- Payment.changeset(%Payment{}, attrs),
         changeset <- Payment.pre_payment_constraint_validations(changeset),
         {:ok, changeset} <- PaymentValidator.validate_changeset(changeset),
         {hold_result, hold_reference, changeset} <- Payment.verify_account_funds(changeset)
    do
      # Save payment and complete the account service operations
      case Repo.insert(changeset) do
        {:ok, payment} ->
          Payment.withdraw_account_funds(hold_result, hold_reference)
          {hold_result, payment}

        {:error, changeset} ->
          Payment.release_account_funds(hold_result, hold_reference)
          PaymentValidator.validate_changeset(changeset)
      end
    else
      error -> error
    end
  end

end
