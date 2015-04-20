defmodule Telephonist.OngoingCall do
  use GenServer

  @moduledoc """
  Stores the state of calls that are currently in progress in an ETS table.
  """

  @type sid    :: atom
  @type status :: String.t
  @type state  :: Telephonist.State.t
  @type call   :: {sid, status, state}
  @type error  :: {:error, String.t}

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Retrieve the ETS table ID for the OngoingCall process.
  """
  @spec table :: integer
  def table, do: call(:table)

  @doc """
  Save a call to the ETS table.

  ## Example

      iex> Telephonist.OngoingCall.save({:CATest, "in-progress", %{}})
      :ok
  """
  @spec save(call) :: :ok
  def save({sid, status, state}) when is_atom(sid) and is_binary(status) do
    cast({:save, {sid, status, state}})
    :ok
  end

  @doc """
  Look up a call in the ETS table by its SID.
  """
  @spec lookup(sid) :: {:ok, call} | error
  def lookup(sid) do
    case call({:lookup, sid}) do
      nil  -> {:error, "No call with SID #{inspect sid} is in progress."}
      call -> {:ok, call}
    end
  end

  @doc """
  Remove a call from the ETS table.
  """
  @spec delete(call | sid) :: :ok
  def delete({sid, _, _}), do: delete(sid)
  def delete(sid) when is_atom(sid) do
    cast({:delete, sid})
    :ok
  end

  ###
  # GenServer API
  ###

  @doc "Receive control of the ETS table from Immortal.EtsTableManager"
  def handle_info({:"ETS-TRANSFER", table, _pid, _data}, _state) do
    {:noreply, table}
  end

  @doc "Retrieve the ETS table"
  def handle_call(:table, _from, table) do
    {:reply, table, table}
  end

  @doc "Find a given call in the ETS table by its SID"
  def handle_call({:lookup, sid}, _from, table) do
    calls = :ets.lookup(table, sid)
    {:reply, List.first(calls), table}
  end

  @doc "Save a call to the ETS table"
  def handle_cast({:save, call}, table) do
    :ets.insert(table, call)
    {:noreply, table}
  end

  @doc "Delete a call from the ETS table by its SID"
  def handle_cast({:delete, sid}, table) do
    :ets.delete(table, sid)
    {:noreply, table}
  end

  ###
  # Private API
  ###

  defp call(args) do
    GenServer.call(__MODULE__, args)
  end

  defp cast(args) do
    GenServer.cast(__MODULE__, args)
  end
end
