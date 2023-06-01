defmodule BankWeb.PaymentView do
  use BankWeb, :view
  alias BankWeb.PaymentView

  def render("show.json", %{payment: payment}) do
    %{data: render_one(payment, PaymentView, "payment.json")}
  end

  def render("payment.json", %{payment: payment}) do
    %{
      id: payment.id,
      merchant_ref: payment.merchant_ref,
      amount: payment.amount,
      card_number: payment.card_number,
      status: payment.status
    }
  end
end
