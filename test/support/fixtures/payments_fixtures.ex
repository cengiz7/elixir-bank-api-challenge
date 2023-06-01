defmodule Bank.PaymentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bank.Payments` context.
  """

  alias Bank.FakeCardNumber
  alias Bank.Payments

  @doc """
  Generate a payment.
  """
  def payment_fixture(attrs \\ %{}) do
    {:ok, payment} =
      attrs
      |> Enum.into(%{
        amount: 1205,
        merchant_ref: Ecto.UUID.generate(),
        card_number: FakeCardNumber.generate(),
        status: "approved"
      })
      |> Payments.create()

    payment
  end
end
