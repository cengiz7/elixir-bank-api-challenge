if Mix.env() != :prod do
  defmodule Bank.Accounts.DummyService do
    @moduledoc """
    A naive implementation of the `Bank.Accounts.Service` behavior.

    This implementation is intended for testing and development only.

    For the sake of simplicity, there's no tracking of account balances,
    held amounts, etc.: we use "magic" values to trigger unhappy paths
    instead.
    """
    alias Bank.Accounts.HoldReference
    alias Bank.Accounts.Service

    @behaviour Bank.Accounts.Service

    @impl true
    @doc """
    Places a hold on the account.

    If the `account_number` starts with "0", returns `{:error, :invalid_account_number}`.

    If the `amount` is negative, returns `{:error, :invalid_amount}`.

    If the `amount` is greater than `1_000_000_00`, returns `{:error, :insufficient_funds}`.

    Returns `{:ok, %Bank.Accounts.HoldReference{...}}` otherwise.
    """
    @spec place_hold(Bank.account_number(), Bank.amount()) ::
            {:ok, Service.hold_ref()} | {:error, Service.place_hold_error()}

    def place_hold("0" <> _ = _account_number, _amount), do: {:error, :invalid_account_number}

    def place_hold(_account_number, amount) when is_integer(amount) do
      cond do
        amount < 0 -> {:error, :invalid_amount}
        amount > 1_000_000_00 -> {:error, :insufficient_funds}
        amount -> {:ok, HoldReference.new(Ecto.UUID.generate())}
      end
    end

    @impl true
    @doc """
    Releases the provided hold.

    Returns `:ok` if provided with a hold reference, otherwise returns `{:error, :invalid_hold_reference}`.
    """
    @spec release_hold(Service.hold_ref()) :: :ok | {:error, Service.hold_ref_error()}
    def release_hold(%HoldReference{}), do: :ok
    def release_hold(_), do: {:error, :invalid_hold_reference}

    @impl true
    @doc """
    Withdraws the held funds and releases the provided hold.

    Returns `:ok` if provided with a `t:Bank.Accounts.HoldReference.t/0` hold reference, otherwise returns `{:error, :invalid_hold_reference}`.
    """
    @spec withdraw_funds(Service.hold_ref()) :: :ok | {:error, Service.hold_ref_error()}
    def withdraw_funds(%HoldReference{}), do: :ok
    def withdraw_funds(_), do: {:error, :invalid_hold_reference}
  end
end
