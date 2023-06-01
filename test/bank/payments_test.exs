defmodule Bank.PaymentsTest do
  use Bank.DataCase

  import Bank.PaymentsFixtures

  alias Bank.FakeCardNumber
  alias Bank.Payments
  alias Bank.Payments.Payment

  @invalid_attrs %{amount: nil, merchant_ref: nil}

  test "get!/1 returns the payment with given id" do
    payment = payment_fixture()
    assert Payments.get!(payment.id) == payment
  end

  test "create/1 with valid data creates a payment" do
    merchant_ref = Ecto.UUID.generate()

    valid_attrs = %{
      amount: 1205,
      merchant_ref: merchant_ref,
      card_number: FakeCardNumber.generate(),
      status: "approved"
    }

    assert {:ok, %Payment{merchant_ref: ^merchant_ref, amount: 1205}} =
             Payments.create(valid_attrs)
  end

  test "create/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Payments.create(@invalid_attrs)
  end
end
