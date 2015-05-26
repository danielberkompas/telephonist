defmodule Telephonist.FormatTest do
  use ExUnit.Case
  import Telephonist.Format
  doctest Telephonist.Format

  test ".atomize_keys will recursively convert keys in a map to atoms" do
    map = %{
      "first" => "value",
      "second" => %{
        "third" => "fourth"
      }
    }

    assert atomize_keys(map) == %{
      :first => "value",
      :second => %{
        :third => "fourth"
      }
    }
  end
end
