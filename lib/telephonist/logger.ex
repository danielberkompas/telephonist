defmodule Telephonist.Logger do
  use GenEvent
  require Logger

  def start_link do
    handler = GenEvent.start_link(name: __MODULE__)
    GenEvent.add_handler(Telephonist.Event, Telephonist.Logger, [])
    handler
  end

  def handle_event({:processing, {_, twilio, _} = params}, _state) do
    log twilio[:CallSid], "Processing: #{inspect params}"
  end

  def handle_event({:lookup_succeeded, {sid, status, state}}, _state) do
    log sid, "Call found in status #{inspect status} and #{inspect state}"
  end

  def handle_event({:lookup_failed, {sid, _, _}}, _state) do
    log sid, "Call not found"
  end

  def handle_event({:completed, {sid, _machine, twilio, options}}, _state) do
    log sid, "Call completed. Twilio: #{inspect twilio} Options: #{inspect options}"
  end

  def handle_event({:transition, {sid, _state_machine, state_name, twilio, options}}, _state) do
    log sid, "Calling transition(#{inspect state_name}, #{inspect twilio}, #{inspect options})"
  end

  def handle_event({:transition_failed, {sid, exception, _state_machine, state_name, twilio, options}}, _state) do
    log sid, "Transition failed! Calling on_transition_error(#{inspect exception}, #{inspect state_name}, #{inspect twilio}, #{inspect options})"
  end

  def handle_event({:new_state, {sid, _status, state}}, _state) do
    log sid, "New state: #{inspect state}"
  end

  def handle_event(_event, _state), do: {:ok, :not_handled}

  defp log(sid, string) when sid == nil, do: log("unknown", string)
  defp log(sid, string) do
    msg = "Telephonist: [#{sid}] #{string}"
    Logger.debug msg
    {:ok, msg}
  end
end
