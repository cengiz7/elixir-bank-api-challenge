defmodule Bank.PaymentInstruments.Card do
  @moduledoc """
  Represents a virtual credit card used for pyaments.

  Card numbers have 15 digits, and the linked account number can be derived
  from the card number.

  Each time it is used a different card number is generated and provided
  to merchants for payment.
  """

  @complete_number_length 15
  @account_prefix_length 2

  @type t :: %__MODULE__{}

  defstruct [:number]

  @doc """
  Parses a string representation of a credit card number into a `t:t/0` instance.

  Returns `{:ok, %Card{}}` on success, or `{:error, :invalid_number}` if the card number
  is invalid.

  ## Examples

      iex> alias Bank.PaymentInstruments.Card
      iex> {:ok, %Card{}} = Card.from_string("123456789123456")
      iex> Card.from_string("123")
      {:error, :invalid_number}
  """
  @spec from_string(number :: String.t()) :: {:ok, t()} | {:error, :invalid_number}

  def from_string(number) when is_binary(number) do
    case String.match?(number, ~r/^\d{#{@complete_number_length}}$/) do
      true -> {:ok, %__MODULE__{number: number}}
      false -> {:error, :invalid_number}
    end
  end

  def from_string(_), do: {:error, :invalid_number}

  @doc """
  Parses a string representation of a credit card number into a `t:t/0` instance.

  Same as `from_string/1` but raises if the card number is invalid.

  ## Examples

      iex> alias Bank.PaymentInstruments.Card
      iex> %Card{} = Card.from_string!("123456789123456")
  """

  @spec from_string!(number :: String.t()) :: t() | no_return()
  def from_string!(number) do
    case from_string(number) do
      {:ok, %__MODULE__{} = card} -> card
      {:error, :invalid_number} -> raise "invalid card number: #{inspect(number)}"
    end
  end

  @doc """
  Returns the account number associated with the given card.
  """
  @spec account_number(card :: t()) :: Bank.account_number()
  def account_number(%__MODULE__{} = card) do
    {account_number, _} = String.split_at(card.number, @account_prefix_length)
    account_number
  end
end
