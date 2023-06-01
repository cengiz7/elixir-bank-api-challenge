defmodule Bank.Payments.Validator do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bank.PaymentInstruments.Card

  @type changeset :: Ecto.Changeset.t()
  @type validation_errors ::
          :not_equal_to
          | :greater_than_or_equal_to
          | :card_number_constraint
          | :invalid_card_number
          | :merchant_ref_constraint
          | :error
  # TODO: move validation error types into Payments

  @required_fields [:amount, :merchant_ref, :card_number]

  embedded_schema do
    field :amount, :integer
    field :merchant_ref, :string
    field :card_number, :string
    field :status, :string
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_number(:amount, greater_than_or_equal_to: 0)
    |> validate_number(:amount, not_equal_to: 0)
    |> validate_card_number(:card_number)
  end

  @spec validate_card_number(changeset, atom(), list() ) :: Ecto.Changeset.t()
  def validate_card_number(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, card_number ->
      case Card.from_string(card_number) do
        {:ok, _} -> []
        {:error, _} -> [{field, options[:message] || "Invalid card number"}]
      end
    end)
  end

  @spec validate_params(map()) :: {validation_errors | :ok, changeset}
  def validate_params(params) do
    params
    |> changeset()
    |> validate_changeset()
    |> put_initial_payment_status()
  end

  @spec validate_changeset(changeset) :: {validation_errors | :ok, changeset}
  def validate_changeset(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: false} = changeset ->
        {classify_changeset_error(changeset), changeset}

      %Ecto.Changeset{valid?: true} = changeset ->
        {:ok, changeset}
    end
  end

  @spec put_initial_payment_status({atom(), Ecto.Changeset.t()}) :: {atom(), Ecto.Changeset.t()}
  def put_initial_payment_status({result, changeset}) do
    {result, put_change(changeset, :status, "declined")}
  end

  @spec classify_changeset_error(changeset) :: validation_errors
  def classify_changeset_error(%{errors: errors}) do
    # TODO: is there an error response code priority order in the Readme doc?
    case List.first(errors) do
      {:card_number, {_msg, opts}} -> get_card_number_error_type(opts)
      {:amount, {_msg, opts}} -> get_amount_error_type(opts)
      {:merchant_ref, {_, _}} -> :merchant_ref_constraint
      _error -> :error
    end
  end

  @spec get_amount_error_type(Keyword.t()) :: atom()
  def get_amount_error_type(opts) do
    case Keyword.get(opts, :kind) do
      :not_equal_to -> :zero_amount
      :greater_than_or_equal_to -> :negative_amount
      _else -> :error
    end
  end

  @spec get_card_number_error_type(Keyword.t()) :: atom()
  def get_card_number_error_type(opts) do
    case Keyword.get(opts, :validation) do
      :unique -> :card_number_constraint
      :unsafe_unique -> :card_number_constraint
      _else -> :invalid_card_number
    end
  end
end
