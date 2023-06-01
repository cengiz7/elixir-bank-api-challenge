defmodule Bank.Accounts.Service do
  @moduledoc """
  Client to interact with a remote service to interact with customer accounts.
  """

  @type place_hold_error ::
          :insufficient_funds
          | :invalid_account_number
          | :internal_error
          | common_errors()
  @type hold_ref_error :: :invalid_hold_reference | common_errors()
  @type common_errors :: :service_unavailable
  @opaque hold_ref :: Bank.Accounts.HoldReference.t()

  @doc """
  Places a hold on the account.

  Reduces the `account_number` account's actual balance by `amount`.

  Placing a hold does NOT remove or transfer money from the account, it
  merely prevents the money from being otherwise spent until the money
  is removed from the account and sent to the proper recipient during
  settlement (via `withdraw_funds/1`).
  """
  @callback place_hold(Bank.account_number(), Bank.amount()) ::
              {:ok, hold_ref} | {:error, place_hold_error}

  @doc """
  Releases a hold on the account.

  Increases the `account_number` account's actual balance by the amount previously held.

  Typically, this is used when the payment for which the hold was created doesn't go
  through fully (it was canceled, the system failed, etc.). Unless holds are released,
  a failed payment would mean that the customer wouldn't get the goods (because the merchant
  wasn't paid), but wouldn't have access to his money either because a hold is still present
  on the funds.
  """
  @callback release_hold(hold_ref()) :: :ok | {:error, hold_ref_error}

  @doc """
  Withdraws the held money from the account.

  Decreases the current balance of the account linked to the hold reference by the amount previously held.
  The hold on the customer's funds is implicitly released atomically.

  This is the mechanism by which money is transferred out from the customer's account and
  into the merchant's account during the settlement process.
  """
  @callback withdraw_funds(hold_ref()) :: :ok | {:error, hold_ref_error}

  @spec place_hold(Bank.account_number(), Bank.amount()) ::
          {:ok, hold_ref} | {:error, place_hold_error}
  def place_hold(account_number, amount), do: impl().place_hold(account_number, amount)

  @spec release_hold(hold_ref()) :: :ok | {:error, hold_ref_error}
  def release_hold(hold_ref), do: impl().release_hold(hold_ref)

  @spec withdraw_funds(hold_ref()) :: :ok | {:error, hold_ref_error}
  def withdraw_funds(hold_ref), do: impl().withdraw_funds(hold_ref)

  defp impl, do: Application.fetch_env!(:bank, :accounts_service)
end
