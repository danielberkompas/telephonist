defmodule Telephonist.Logger do
  use Telephonist.Subscriber
  require Logger

  def on_event(:start_processing, {_, twilio, _} = params) do
    log twilio[:CallSid], "Start: #{inspect params}"
  end

  def on_event(:lookup_success, {sid, status, state}) do
    log sid, "Call found in status #{inspect status} and #{inspect state}"
  end

  def on_event(:call_complete, {sid, _machine, twilio, options}) do
    log sid, "Call completed. Twilio: #{inspect twilio} Options: #{inspect options}"
  end

  def on_event(:attempt_transition, {sid, _state_machine, state_name, twilio, options}) do
    log sid, "Calling transition(#{inspect state_name}, #{inspect twilio}, #{inspect options})"
  end

  def on_event(:transition_error, {sid, exception, _state_machine, state_name, twilio, options}) do
    log sid, "Transition failed! Calling on_transition_error(#{inspect exception}, #{inspect state_name}, #{inspect twilio}, #{inspect options})"
  end

  def on_event(:next_state, {sid, _status, state}) do
    log sid, "Returned state: #{inspect state}"
  end

  defp log(sid, string) when sid == nil, do: log("unknown", string)
  defp log(sid, string) do
    Logger.debug "Telephonist: [#{sid}] #{string}"
  end
end
