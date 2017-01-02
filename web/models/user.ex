defmodule PhoenixAppTemplate.User do
  use PhoenixAppTemplate.Web, :model
  import Comeonin.Bcrypt, only: [hashpwsalt: 1, checkpw: 2, dummy_checkpw: 0]

  alias PhoenixAppTemplate.Repo
  alias PhoenixAppTemplate.User
  alias PhoenixAppTemplate.Identity
  alias Ueberauth.Auth

  schema "users" do
    field :name, :string
    field :email, :string
    field :crypted_password, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    has_many :identities, PhoenixAppTemplate.Identity, on_delete: :delete_all

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :password, :password_confirmation])
    |> unique_constraint(:email)
    |> validate_required([:name, :email, :password, :password_confirmation])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_format(:email, ~r/@/)
    |> update_change(:email, &String.downcase/1)
    |> validate_length(:password, min: 6)
    |> hash_password
  end

  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :password, :password_confirmation])
    |> validate_required([:name, :password, :password_confirmation])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_length(:password, min: 6)
    |> hash_password
  end

  def oauth_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
  end

  def authenticate(email, password)
    when not is_nil(email) and not is_nil(password) do

    user = Repo.get_by(User, email: email)
    if user && checkpw(password, user.crypted_password) do
      {:ok, user}
    else
      dummy_checkpw() # prevent time based attacks
      {:error, "invalid"}
    end
  end
  def authenticate(_email, _password), do: {:error, "invalid"}

  def get_or_create_by_oauth(%Auth{provider: provider, info: info, uid: uid}) do
    if user = Identity.get_user(provider, uid) do
      {:ok, user}
    else
      case create_by_oauth(info) do
        {:ok, user} ->
          # It doesn't really matter if we were unable to create identity
          # It could have been created from the concurrent request or
          # we might have get an error. The only thing we bother about is User
          Identity.add_identity(user, provider, uid)
          {:ok, user}
        {:error, changeset} ->
          {:error, changeset}
      end
    end
  end

  defp create_by_oauth(%{email: email, name: name}) when not is_nil(email) do
    if user = Repo.get_by(User, email: email) do
      {:ok, user}
    else
      on_conflict = [set: [email: email]]
      User.oauth_changeset(%User{}, %{email: email, name: name})
      |> Repo.insert(on_conflict: on_conflict, conflict_target: :email)
    end
  end
  defp create_by_oauth(%{email: email, name: name}) do
    {:error, User.oauth_changeset(%User{}, %{email: email, name: name})}
  end

  defp hash_password(changeset) do
    if password = get_change(changeset, :password) do
      changeset
      |> put_change(:crypted_password, hashpwsalt(password))
    else
      changeset
    end
  end
end
