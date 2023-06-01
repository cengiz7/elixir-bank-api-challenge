defmodule Bank.Refunds do
  @moduledoc """
  The Refunds context.
  """

  import Ecto.Query, warn: false
  alias Bank.Repo

  alias Bank.Refunds.Refund

  @doc """
  Gets a single refund.

  Raises `Ecto.NoResultsError` if the Refund does not exist.

  ## Examples

      iex> get!(123)
      %Refund{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(Refund, id)

  @doc """
  Creates a refund.
  """
  def create(attrs) do
    %Refund{}
    |> Refund.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, refund} -> {:ok, refund}
      {:error, changeset} -> {Refund.classify_changeset_error(changeset), changeset}
    end
  end
end
