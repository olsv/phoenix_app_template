defmodule PhoenixAppTemplate.Identity do
  use PhoenixAppTemplate.Web, :model
  alias PhoenixAppTemplate.Repo
  alias PhoenixAppTemplate.User
  alias PhoenixAppTemplate.Identity

  @primary_key false
  schema "identities" do
    field :provider, :string
    field :uid, :string
    belongs_to :user, PhoenixAppTemplate.User, primary_key: true
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:provider, :uid])
    |> validate_required([:provider, :uid])
    |> assoc_constraint(:user)
    |> unique_constraint(:provider, name: :identity_idx)
  end

  @doc """
  Adds a new identity to the specified `user`.
  Returns an empty changeset unless `user` is a %User{}
  Accepts either atom or string as the `provider`
  """
  def add_identity(%User{} = user, provider, uid) when is_atom(provider) do
    add_identity(user, to_string(provider), uid)
  end
  def add_identity(%User{} = user, provider, uid) do
    changeset(%Identity{}, %{uid: uid, provider: provider})
    |> put_assoc(:user, user)
    |> Repo.insert
  end
  def add_identity(_anything_else, provider, uid) do
    changeset =
      changeset(%Identity{}, %{provider: provider, uid: uid})
      |> add_error(:user, "is invalid (expected User record)")
    {:error, changeset}
  end

  @doc """
  Returns %User{} record related to the `provider` and `uid`
  Returns nil unless identity exists
  Accepts either atom or string as the `provider`
  """
  def get_user(provider, uid) when is_atom(provider) do
    get_user(to_string(provider), uid)
  end
  def get_user(provider, uid) do
    User
    |> first
    |> join(:inner, [u], a in assoc(u, :identities))
    |> where([_, a], a.provider == ^provider )
    |> where([_, a], a.uid == ^uid)
    |> Repo.one
  end
end
