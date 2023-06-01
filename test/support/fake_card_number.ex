defmodule Bank.FakeCardNumber do
  @number_length 15

  def generate() do
    account_prefix = Enum.random(10..99)
    generate(account_prefix)
  end

  def generate(account_prefix) when is_integer(account_prefix) do
    account_prefix
    |> Integer.to_string()
    |> generate()
  end

  def generate(account_prefix) when is_binary(account_prefix) do
    rest = System.system_time(:millisecond) |> Integer.to_string()

    {number, _} = String.split_at(account_prefix <> rest, @number_length)
    number
  end
end
