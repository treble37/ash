defmodule Ash.Test.Resource.AttributesTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Ash.Resource.Attribute

  defmacrop defposts(do: body) do
    quote do
      defmodule Post do
        @moduledoc false
        use Ash.Resource

        attributes do
          uuid_primary_key :id
        end

        unquote(body)
      end
    end
  end

  describe "representation" do
    test "attributes are persisted on the resource properly" do
      defposts do
        attributes do
          attribute :foo, :string
          attribute :bar, :boolean, private?: true
        end
      end

      assert [
               _,
               %Attribute{name: :foo, type: Ash.Type.String, primary_key?: false},
               %Attribute{
                 name: :bar,
                 type: Ash.Type.Boolean,
                 primary_key?: false,
                 private?: true
               }
             ] = Ash.Resource.Info.attributes(Post)

      assert [_, %Attribute{name: :foo}] = Ash.Resource.Info.public_attributes(Post)

      assert %Attribute{name: :bar} = Ash.Resource.Info.attribute(Post, :bar)

      assert nil == Ash.Resource.Info.attribute(Post, :totally_valid_attributes)

      assert nil == Ash.Resource.Info.public_attribute(Post, :bar)
    end
  end

  describe "validation" do
    test "raises if the attribute name is not an atom" do
      assert_raise(
        Ash.Error.Dsl.DslError,
        "[Ash.Test.Resource.AttributesTest.Post]\n attributes -> attribute -> 10:\n  expected :name to be an atom, got: 10",
        fn ->
          defposts do
            attributes do
              attribute 10, :string
            end
          end
        end
      )
    end

    test "raises if you pass an invalid value for `primary_key?`" do
      assert_raise(
        Ash.Error.Dsl.DslError,
        "[Ash.Test.Resource.AttributesTest.Post]\n attributes -> attribute -> foo:\n  expected :primary_key? to be a boolean, got: 10",
        fn ->
          defposts do
            attributes do
              attribute :foo, :string, primary_key?: 10
            end
          end
        end
      )
    end

    test "raises if you pass an invalid value for `private?`" do
      assert_raise(
        Ash.Error.Dsl.DslError,
        "[Ash.Test.Resource.AttributesTest.Post]\n attributes -> attribute -> foo:\n  expected :private? to be a boolean, got: \"an_invalid_value\"",
        fn ->
          defposts do
            attributes do
              attribute :foo, :string, private?: "an_invalid_value"
            end
          end
        end
      )
    end
  end
end
