defmodule BankWeb.PaymentFallbackController do
  @moduledoc """
  Translates payment controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use BankWeb, :controller

  alias Bank.Payments.Payment

  @unhappy_path_errors [:error, :card_number_constraint, :merchant_ref_constraint]

  def call(conn, {:zero_amount, %Ecto.Changeset{} = _changeset}) do
    send_resp(conn, 204, "")
  end

  # This clause handles errors returned by Ecto's insert/update/delete. (Unhappy path errors)
  def call(conn, {error, %Ecto.Changeset{} = changeset}) when error in @unhappy_path_errors do
    conn
    |> put_status(error_to_status_code(error))
    |> put_view(BankWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {error, %Ecto.Changeset{changes: changes}}) do
    conn
    |> put_status(error_to_status_code(error))
    |> put_view(BankWeb.FailedPaymentView)
    |> render("payment.json", changes)
  end

  def call(conn, {error, %Payment{} = payment}) do
    conn
    |> put_status(error_to_status_code(error))
    |> put_resp_header("location", Routes.payment_path(conn, :show, payment))
    |> put_view(BankWeb.PaymentView)
    |> render("show.json", payment: payment)
  end


  defp error_to_status_code(:service_unavailable), do: 503
  defp error_to_status_code(:internal_error), do: 500
  defp error_to_status_code(:invalid_card_number), do: 422
  defp error_to_status_code(:card_number_constraint), do: 422
  defp error_to_status_code(:merchant_ref_constraint), do: 409
  defp error_to_status_code(:invalid_account_number), do: 403
  defp error_to_status_code(:insufficient_funds), do: 402
  defp error_to_status_code(:negative_amount), do: 400
  defp error_to_status_code(_), do: 422
end
