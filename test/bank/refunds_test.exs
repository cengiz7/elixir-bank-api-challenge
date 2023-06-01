defmodule Bank.RefundsTest do
  use Bank.DataCase

  import Bank.PaymentsFixtures, only: [payment_fixture: 0]
  import Bank.RefundsFixtures

  alias Bank.Payments.Payment
  alias Bank.Refunds

  alias Bank.Refunds.Refund

  @invalid_attrs %{amount: "foo", merchant_ref: "bar"}

  setup do
    %Payment{id: payment_id} = payment_fixture()
    {:ok, %{payment_id: payment_id}}
  end

  test "get!/1 returns the refund with given id" do
    refund = refund_fixture()
    assert Refunds.get!(refund.id) == refund
  end

  test "create/1 with valid data creates a refund", %{payment_id: payment_id} do
    merchant_ref = Ecto.UUID.generate()

    valid_attrs = %{
      amount: 42,
      merchant_ref: merchant_ref,
      payment_id: payment_id
    }

    assert {:ok, %Refund{} = refund} = Refunds.create(valid_attrs)
    assert refund.amount == 42
    assert refund.merchant_ref == merchant_ref
    assert refund.payment_id == payment_id
  end

  test "create/1 with invalid data returns error changeset", %{payment_id: payment_id} do
    attrs = Map.merge(@invalid_attrs, %{payment_id: payment_id})
    assert {:error, %Ecto.Changeset{}} = Refunds.create(attrs)
  end
end
