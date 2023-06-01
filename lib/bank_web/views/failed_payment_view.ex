defmodule BankWeb.FailedPaymentView do
  use BankWeb, :view

  def render("payment.json", changes) do
    %{
      merchant_ref: Map.get(changes, :merchant_ref),
      amount: Map.get(changes, :amount),
      card_number: Map.get(changes, :card_number),
      status: Map.get(changes, :status)
    }
  end
end
