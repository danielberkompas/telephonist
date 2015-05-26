defmodule Telephonist.Format do
  @moduledoc """
  Contains functions to convert values between formats.
  """

  @doc """
  Converts all binary keys in a map to atoms, recursively.

  ## Example

      iex> Telephonist.Format.atomize_keys(%{"hello" => %{"there" => "everyone"}})
      %{:hello => %{:there => "everyone"}}
  """
  def atomize_keys(map) when is_map(map) do
    for {key, val} <- map, into: %{}, do: {atomize(key), atomize_keys(val)}
  end
  def atomize_keys(value), do: value

  defp atomize(val) when is_binary(val), do: String.to_atom(val)
  defp atomize(val),                     do: val
end
