defmodule Telephonist.Storage.ETS do
  @moduledoc """
  Stores the state of calls in an ETS table. In order to use, make sure that you
  add `#{__MODULE__}` to your application supervisor.
  """

  @behaviour Telephonist.Storage

  # GenServer is only used to start a process to own the ETS table.
  # All interaction with the ETS table is done directly for maximum
  # performance.
  use GenServer

  alias Telephonist.Call

  @doc """
  Save the state of an ongoing call.

  ## Examples

      iex> Storage.save(Call.new("sid", "in-progress"))
      :ok
  """
  @spec save(Call.t) :: :ok
  def save(call) do
    :ets.insert(__MODULE__, {call.sid, call})
    :ok
  end

  @doc ~S"""
  Lookup the state of an ongoing call.

  ## Examples

      iex> Storage.save(Call.new("sid", "in-progress"))
      ...> Storage.find("sid")
      {:ok, %Call{sid: "sid", status: "in-progress"}}

      iex> Storage.find("nonexistent")
      {:error, "No call with SID \"nonexistent\" is in progress."}
  """
  @spec find(Call.sid) :: {:ok, Call.t} | {:error, String.t}
  def find(sid) do
    case :ets.lookup(__MODULE__, sid) do
      [] ->
        {:error, "No call with SID #{inspect sid} is in progress."}
      [{_sid, call}|_] ->
        {:ok, call}
    end
  end

  @doc ~S"""
  Delete a call status from the Storage.Storage database.

  ## Parameters

  - `call` or `sid`: Either a call tuple or SID.

  ## Examples

      iex> Storage.save(Call.new("delete", "in-progress"))
      ...> Storage.delete("delete")
      ...> Storage.find("delete")
      {:error, "No call with SID \"delete\" is in progress."}
  """
  def delete(%{sid: sid}), do: delete(sid)
  def delete(sid) do
    :ets.delete(__MODULE__, sid)
    :ok
  end

  ##
  # GenServer API
  ##

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc false
  def init(_) do
    :ets.new(__MODULE__, [:named_table, :public])
    {:ok, nil}
  end
end
