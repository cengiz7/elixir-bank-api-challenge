defmodule Bank.Repo.Migrations.TriggerRefundAmountValidation do
  use Ecto.Migration

  def up do
    execute "CREATE TRIGGER check_payment_refund_amount_trigger
    AFTER INSERT OR UPDATE ON refunds
    FOR EACH ROW EXECUTE PROCEDURE check_payment_refund_amount();"
  end

  def down do
    execute "DROP TRIGGER IF EXISTS check_payment_refund_amount_trigger ON refunds;"
  end
end
