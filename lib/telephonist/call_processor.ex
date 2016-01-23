defmodule Telephonist.CallProcessor do
  @moduledoc """
  Allows you to progress a call through a `Telephonist.StateMachine`.
  See `process/3` for more details.

  For more information on how to design a compatible state machine, see the docs
  on `Telephonist.StateMachine`.
  """

  import Telephonist.Event, only: [notify: 2]

  alias Telephonist.Call

  @completed_statuses ["completed", "busy", "failed", "no-answer"]

  @type machine :: module
  @type twilio :: %{String.t => String.t}
  @type data :: map

  @doc """
  Process a call with a given default `Telephonist.StateMachine`. Returns a new
  `Telephonist.State` for the call. This state includes the correct TwiML for
  the current state of the call, so that you can render it back to Twilio.

  ### Parameters

    - `machine`: The `Telephonist.StateMachine` to use. This is used as a
      starting point if the call has not been seen before.

    - `twilio`: A `map` of all the Twilio request parameters that were given for
      the call. This will be forwarded to the StateMachine.

    - `data`: An optional `map` of custom data that you want to pass along
      to the StateMachine. For example, this could include information like user
      data, or URLs to use for call redirection or recording handling. It will
      be saved in that call's state for the remainder of its lifecycle, and
      passed into each StateMachine `transition` handler function.

  ## Examples

      # The web framework used here is pseudo-code
      def index(conn, twilio) do
        state = Telephonist.CallProcessor.process(StateMachine, twilio)
        render conn, xml: state.twiml
      end
  """
  @spec process(machine, twilio, data) :: Telephonist.State.t
  def process(machine, twilio, data \\ %{}) do
    notify :processing, {machine, twilio, data}
    call = find(twilio)
    do_processing(call, machine, twilio, data)
  end

  ###
  # Private API
  ###

  defp find(twilio) do
    sid = twilio["CallSid"]

    case storage.find(sid) do
      {:ok, call} ->
        notify :call_found, call
        call
      {:error, _} ->
        call = Call.new(sid, twilio["CallStatus"])
        notify :call_not_found, call
        call
    end
  end

  # When the call is complete
  defp do_processing(call, machine, %{"CallStatus" => status} = twilio, data)
  when status in @completed_statuses do
    state =
      %{machine: machine, data: data}
      |> Map.merge(call.state || %{})
      |> Telephonist.State.complete

    :ok = state.machine.on_complete(call, twilio, state.data)
    storage.delete(call)

    call = %{call | state: state}
    notify :completed, call
    call.state
  end

  # When the call is ongoing
  defp do_processing(call, machine, twilio, data) do
    state = get_next_state(call, machine, twilio, data)
    call = %{call | state: state}

    storage.save(call)
    notify :new_state, call
    state
  end

  # When the call hasn't been tracked yet
  defp get_next_state(%{state: nil}, machine, twilio, data) do
    machine.state(machine.initial_state, twilio, data)
  end

  # When the call has been tracked already
  defp get_next_state(%{state: state} = call, _, twilio, data) do
    try do
      data = Map.merge(data, state.data)
      notify :transition, {call, twilio, data}
      state.machine.transition(state.name, twilio, data)
    rescue
      exception ->
        notify :transition_failed, {exception, call, twilio, data}
        state.machine.on_transition_error(exception, state.name, twilio, data)
    end
  end

  defp storage do
    Application.get_env(:telephonist, :storage)
  end
end
