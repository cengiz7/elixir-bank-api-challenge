defmodule Bank.RefundsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bank.Refunds` context.
  """

  alias Bank.PaymentsFixtures
  alias Bank.Refunds

  @doc """
  Generate a refund.
  """
  def refund_fixture(attrs \\ %{}) do
    %{id: payment_id} = PaymentsFixtures.payment_fixture()

    refund_attrs =
      Enum.into(attrs, %{
        amount: 42,
        merchant_ref: Ecto.UUID.generate(),
        payment_id: payment_id
      })

    {:ok, refund} = Refunds.create(refund_attrs)

    refund
  end
end
