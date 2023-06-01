defmodule Bank.Accounts.HoldReference do
  @moduledoc """
  Represents a hold on a bank customer's funds within their account.

  This struct should be considered opaque.

  For the sake of simplicity, the amount that is held and the reference
  to the account aren't tracked anywhere, but you can assume the hold
  reference contains this information.
  """

  defstruct [:id]

  @typedoc """
  Represents a hold on funds in a customer's account.
  """
  @opaque t :: %__MODULE__{}

  @doc """
  Creates a new reference to a hold placed on a customer's funds.
  """
  @spec new(id :: Ecto.UUID.t()) :: t()
  def new(id) do
    %__MODULE__{id: id}
  end
end
