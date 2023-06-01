defmodule BankWeb.RefundControllerTest do
  use BankWeb.ConnCase

  import Bank.PaymentsFixtures, only: [payment_fixture: 0, payment_fixture: 1]

  @create_attrs %{
    amount: 42,
    merchant_ref: "some merchant_ref",
    payment_id: "7488a646-e31f-11e4-aace-600308960662"
  }
  @invalid_attrs %{amount: nil, merchant_ref: nil, payment_id: nil}

  setup %{conn: conn} do
    %{id: payment_id} = payment_fixture()

    {:ok, conn: put_req_header(conn, "accept", "application/json"), payment_id: payment_id}
  end

  describe "create refund" do
    test "renders refund when data is valid", %{conn: conn, payment_id: payment_id} do
      conn =
        post(conn, Routes.payment_refund_path(conn, :create, payment_id), refund: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.payment_refund_path(conn, :show, payment_id, id))

      assert %{
               "id" => ^id,
               "amount" => 42,
               "merchant_ref" => "some merchant_ref",
               "payment_id" => ^payment_id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, payment_id: payment_id} do
      conn =
        post(conn, Routes.payment_refund_path(conn, :create, payment_id), refund: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders error when amount is too high", %{conn: conn} do
      %{id: payment_id} = payment_fixture(%{amount: 1_00})

      conn =
        post(conn, Routes.payment_refund_path(conn, :create, payment_id),
          refund: %{amount: 1_01, payment_id: payment_id, merchant_ref: Ecto.UUID.generate()}
        )

      assert ["excessive refund amount requested"] == json_response(conn, 422)["errors"]["amount"]
    end
  end
end
