defmodule Telephonist.OngoingCall do
  use ExActor.GenServer, export: __MODULE__

  @moduledoc """
  Stores the state of calls that are currently in progress in an ETS table.
  """

  @type sid    :: atom
  @type status :: String.t
  @type call   :: {sid, status, Telephonist.State.t}
  @type error  :: {:error, String.t}

  @doc false
  defstart start_link, do: initial_state(:ok)

  @doc false
  defhandleinfo {:"ETS-TRANSFER", table, _pid, _data} do
    new_state(table)
  end

  @doc "Retrieve the ETS table"
  @spec table :: integer
  defcall table, state: table do
    reply(table)
  end

  @doc "Find a given call in the ETS table by its SID"
  @spec lookup(sid) :: {:ok, call} | error
  defcall lookup(sid), state: table do
    response = case :ets.lookup(table, sid) do
      []       -> {:error, "No call with SID #{inspect sid} is in progress."}
      [call|_] -> {:ok, call}
    end

    reply(response, table)
  end

  @doc "Save a call to the ETS table"
  @spec save(call) :: :ok
  defcast save(call), state: table do
    :ets.insert(table, call)
    noreply
  end

  @doc "Delete a call from the ETS table by its SID"
  @spec delete(call | sid) :: :ok
  def delete({sid, _, _}), do: delete(sid)
  defcast delete(sid), state: table do
    :ets.delete(table, sid)
    noreply
  end
end
