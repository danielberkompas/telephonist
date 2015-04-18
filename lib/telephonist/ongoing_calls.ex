defmodule Telephonist.OngoingCalls do
  use GenServer

  @type sid    :: atom
  @type status :: String.t
  @type state  :: Telephonist.State.t
  @type call   :: {sid, status, state}
  @type error  :: {:error, String.t}

  @completed_statuses ["completed", "busy", "failed", "no-answer"]

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Retrieve the ETS table ID for the OngoingCalls process.
  """
  @spec table :: integer
  def table, do: call(:table)

  @spec process(atom, map, map) :: state
  def process(machine, twilio, options \\ %{}) do
    sid    = twilio[:CallSid] |> String.to_atom
    status = twilio[:CallStatus]

    call = case lookup_call(sid) do
      {:ok, call}    -> call
      {:error, _msg} -> {sid, status, nil}
    end

    call({:process, call, machine, twilio, options})
  end

  @spec save_call(call) :: :ok
  def save_call({sid, status, state}) when is_atom(sid) and is_binary(status) do
    cast({:save_call, {sid, status, state}})
    :ok
  end

  @spec lookup_call(sid) :: {:ok, call} | error
  def lookup_call(sid) do
    case call({:lookup_call, sid}) do
      nil  -> {:error, "No call with SID #{inspect sid} is in progress."}
      call -> {:ok, call}
    end
  end

  @spec delete_call(call) :: :ok
  def delete_call(call) do
    cast({:delete_call, call})
    :ok
  end

  ###
  # GenServer API
  ###

  @doc "Receive control of the ETS table from Immortal.EtsTableManager"
  def handle_info({:"ETS-TRANSFER", table, _pid, _data}, _state) do
    {:noreply, table}
  end

  def handle_call(:table, _from, table) do
    {:reply, table, table}
  end

  def handle_call({:lookup_call, sid}, _from, table) do
    calls = :ets.lookup(table, sid)
    {:reply, List.first(calls), table}
  end

  def handle_call({:process, call, machine, twilio, options}, _from, table) do
    {:reply, do_processing(call, machine, twilio, options), table}
  end

  def handle_cast({:save_call, call}, table) do
    :ets.insert(table, call)
    {:noreply, table}
  end

  def handle_cast({:delete_call, {sid, _, _}}, table) do
    :ets.delete(table, sid)
    {:noreply, table}
  end

  ###
  # Private API
  ###

  # When the call is complete
  defp do_processing({_, status, current_state} = call, machine, twilio, options) when status in @completed_statuses do
    save_call(call) # For debugging, garbage collecting

    # Ensure that we use the correct state machine
    machine = Map.get(current_state || %{}, :machine, machine)
    :ok = machine.on_complete(call, twilio, options)
    delete_call(call)

    :complete
  end

  # When the call hasn't been tracked yet
  defp do_processing({sid, status, _} = call, machine, twilio, options) do
    state = get_next_state(call, machine, twilio, options)
    save_call({sid, status, state})
    state
  end

  def get_next_state({_, _, nil}, machine, twilio, options) do
    machine.state(machine.initial_state, twilio, options)
  end

  def get_next_state({_, _, state}, _, twilio, options) do
    try do
      state.machine.transition(state.name, twilio, options)
    rescue
      e -> state.machine.on_transition_error(e, state.name, twilio, options)
    end
  end

  defp call(args) do
    GenServer.call(__MODULE__, args)
  end

  defp cast(args) do
    GenServer.cast(__MODULE__, args)
  end
end
