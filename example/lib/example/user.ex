defmodule Example.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Example.Repo
  alias Example.User

  schema "users" do
    field :email, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
  end

  @doc "find a user from email"
  def find_by_email(email_address) do
    query = from u in User,
      where: u.email == ^email_address

    Repo.one(query)
  end

  @doc "create a user from auth info"
  def create_from_auth(info) do
    Repo.insert!(%User{name: info[:name], email: info[:email]})
  end

  @doc "find or create a user from auth info"
  def find_or_create_from_auth(info) do
    User.find_by_email(info[:email]) || User.create_from_auth(info)
  end
end
