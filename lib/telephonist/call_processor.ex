defmodule Telephonist.CallProcessor do
  alias Telephonist.OngoingCall
  import Task, only: [async: 1, await: 1]
  import Telephonist.Event, only: [notify: 2]

  @shortdoc "Process calls using a `Telephonist.StateMachine`"

  @moduledoc """
  Allows you to progress a call through a `Telephonist.StateMachine`. 
  See `process/3` for more details.

  For more information on how to design a compatible state machine, see the docs
  on `Telephonist.StateMachine`.
  """

  @completed_statuses ["completed", "busy", "failed", "no-answer"]

  @doc """
  Process a call with a given default `Telephonist.StateMachine`. Returns a new
  `Telephonist.State` for the call. This state includes the correct TwiML for
  the current state of the call, so that you can render it back to Twilio.

  ### Parameters 

    - `machine`: The `Telephonist.StateMachine` to use. This is used as a
      starting point if the call has not been seen before.

    - `twilio`: A `map` of all the Twilio request parameters that were given for
      the call. This will be forwarded to the StateMachine.

    - `options`: An optional `map` of custom options that you want to pass along
      to the StateMachine. For example, this could include information like user
      data, or URLs to use for call redirection or recording handling.

  ## Examples

      # The web framework used here is pseudo-code
      def index(conn, twilio) do
        state = Telephonist.CallProcessor.process(StateMachine, twilio)
        render conn, xml: state.twiml
      end
  """
  @spec process(atom, map, map) :: Telephonist.State.t
  def process(machine, twilio, options \\ %{}) do
    twilio = for pair <- twilio, into: %{}, do: atomize_key(pair)
    notify :processing, {machine, twilio, options}

    result = async fn ->
      call = lookup(twilio)
      do_processing(call, machine, twilio, options)
    end

    await result
  end

  defp atomize_key({key, val}) when is_atom(key),   do: {key, val}
  defp atomize_key({key, val}) when is_binary(key), do: {String.to_atom(key), val}

  defp lookup(twilio) do
    sid = twilio[:CallSid] |> String.to_atom

    case OngoingCall.lookup(sid) do
      {:ok, call} -> 
        notify :lookup_succeeded, call
        call
      {:error, _} -> 
        call = {sid, twilio[:CallStatus], nil}
        notify :lookup_failed, call
        call
    end
  end

  # When the call is complete
  defp do_processing({sid, _, state} = call, machine, %{CallStatus: status} = twilio, options) when status in @completed_statuses do
    notify :completed, {sid, machine, twilio, options}
    state = state || %{}
    state = Map.put_new(state, :machine, machine)
    state = Map.put_new(state, :options, options)

    OngoingCall.save(call) # For debugging, garbage collecting
    :ok = state.machine.on_complete(call, twilio, options)
    OngoingCall.delete(call)

    Telephonist.State.complete(state)
  end

  # When the call is ongoing 
  defp do_processing({sid, status, _} = call, machine, twilio, options) do
    state = get_next_state(call, machine, twilio, options)

    call = {sid, status, state}
    OngoingCall.save(call)
    notify :new_state, call

    state
  end

  # When the call hasn't been tracked yet
  defp get_next_state({_, _, nil}, machine, twilio, options) do
    machine.state(machine.initial_state, twilio, options)
  end

  # When the call has been tracked already
  defp get_next_state({sid, _, state}, _, twilio, options) do
    try do
      notify :transition, {sid, state.machine, state.name, twilio, options}
      state.machine.transition(state.name, twilio, options)
    rescue
      e ->
        notify :transition_failed, {sid, e, state.machine, state.name, twilio, options}
        state.machine.on_transition_error(e, state.name, twilio, options)
    end
  end
end
