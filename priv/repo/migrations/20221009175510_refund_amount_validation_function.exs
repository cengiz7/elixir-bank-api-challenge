defmodule Bank.Repo.Migrations.RefundAmountValidationFunction do
  use Ecto.Migration

  # INFO/Note: Also check https://wiki.postgresql.org/wiki/SSI
  def up do
    execute """
    CREATE OR REPLACE FUNCTION check_payment_refund_amount()
      RETURNS TRIGGER AS $$
    DECLARE
      payment_amount BIGINT;
      refunds_total     BIGINT;
    BEGIN
      SELECT INTO payment_amount amount
      FROM payments
      WHERE id = NEW.payment_id;

      SELECT INTO refunds_total SUM(amount)
      FROM refunds
      WHERE payment_id = NEW.payment_id;

      IF refunds_total > payment_amount
      THEN
        RAISE EXCEPTION 'Refunds amount total exceeds payment amount [id:%] by [%]',
        NEW.payment_id,
        (refunds_total - payment_amount)
        USING ERRCODE = 'check_violation',
        CONSTRAINT = 'payment_refund_amount_constraint';
      END IF;
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    """
  end

  def down do
    execute "DROP FUNCTION IF EXISTS check_payment_refund_amount() CASCADE;"
  end
end
