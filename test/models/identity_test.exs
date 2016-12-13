defmodule PhoenixAppTemplate.IdentityTest do
  use PhoenixAppTemplate.ModelCase

  alias PhoenixAppTemplate.Identity
  alias PhoenixAppTemplate.Repo
  alias PhoenixAppTemplate.User

  @valid_attrs %{provider: "some content", uid: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Identity.changeset(%Identity{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Identity.changeset(%Identity{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "add_identity for the existing user by provider and uid" do
    {_ok, user} = Repo.insert(%User{email: "some@email.com"})
    Identity.add_identity(user, "some", "1")
    assert Repo.get_by(Identity, user_id: user.id, provider: "some", uid: "1")
  end

  test "add_identity transparently handles atom as provider and creates identity" do
    {_ok, user} = Repo.insert(%User{email: "some@email.com"})
    Identity.add_identity(user, :some, "1")
    assert Repo.get_by(Identity, user_id: user.id, provider: "some", uid: "1")
  end

  test "add_identity does not create identity if nil is passed as user" do
    {:error, identity} = Identity.add_identity(nil, "some", "1")
    refute Repo.get_by(Identity, provider: "some", uid: "1")
    assert {:user, {"is invalid (expected User record)", []}} in identity.errors
  end

  test "add_identity does not create identity if changeset is passed as user" do
    changeset = User.changeset(%User{}, %{})
    {:error, identity} = Identity.add_identity(changeset, "some", "1")
    refute Repo.get_by(Identity, provider: "some", uid: "1")
    assert {:user, {"is invalid (expected User record)", []}} in identity.errors
  end

  test "should not be possible to create two identical identities" do
    user = Repo.insert!(%User{email: "some@user.com"})
    changeset =
      Identity.changeset(%Identity{}, %{provider: "some", uid: "1"})
      |> Ecto.Changeset.put_assoc(:user, user)
    assert Repo.insert!(changeset)
    {:error, identity} = Repo.insert(changeset)
    assert {:provider, {"has already been taken", []}} in identity.errors
  end

  test "should not be possible to create identity for a non existing user" do
    user = Repo.insert!(%User{email: "some@user.com"})
    Repo.delete!(user)
    changeset =
      Identity.changeset(%Identity{}, %{provider: "some", uid: "1"})
      |> Ecto.Changeset.put_assoc(:user, user)
    {:error, identity} = Repo.insert(changeset)
    assert {:user, {"does not exist", []}} in identity.errors
  end

  # Integrity specs. The following specs are vital
  test "should not be possible to create identity with missing params" do
    assert_raise Postgrex.Error, fn ->
      Repo.insert! %Identity{provider: "some", uid: "1"}
    end
    assert_raise Postgrex.Error, fn ->
      Repo.insert! %Identity{user_id: 1, uid: "1"}
    end
    assert_raise Postgrex.Error, fn ->
      Repo.insert! %Identity{user_id: 1, provider: "some"}
    end
  end

  test "get_user returns the User associated with the provider and uid" do
    user = Repo.insert! %User{email: "some@user.com"}
    Repo.insert! %Identity{user_id: user.id, provider: "some", uid: "1"}
    assert user == Identity.get_user("some", "1")
  end

  test "get_user returns nil when identity does not exist" do
    assert nil == Identity.get_user("some", "1")
  end
end
