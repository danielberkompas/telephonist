defmodule Telephonist.Logger do
  @moduledoc """
  Logs all the events broadcasted by `Telephonist.Event`, using the `Logger`
  module. Since it's implemented as a GenEvent subscriber, and listens on all
  implemented events, its source code is a good place to look if you want to
  implement your own subscriber.

  See the source of `start_link/0` for more details.
  """

  use GenEvent

  require Logger

  defmodule AddLoggerHandler do
    @moduledoc """
    A GenServer which adds Telephonist.Logger handler to Telephonist.Event

    It links to Telephonist.Event, and is supervised (as Telephonist.Logger)
    so that if the manager should die, this GenServer will too, and the
    handler will be re-added when they restart.
    """
    use GenServer

    def init(_) do
      true = Process.whereis(Telephonist.Event) |> Process.link
      :ok = GenEvent.add_handler(Telephonist.Event, Telephonist.Logger, [])
      {:ok, nil}
    end
  end

  @doc """
  Start the `Telephonist.Logger` process.
  """
  def start_link do
    GenServer.start_link(AddLoggerHandler, nil)
  end

  @doc false
  def handle_event({:processing, {_, twilio, _} = params}, _state) do
    log twilio["CallSid"], "Processing: #{inspect params}"
  end

  def handle_event({:call_found, call}, _state) do
    log call.sid, """
    Call found in status #{inspect call.status} and #{inspect call.state}"
    """
  end

  def handle_event({:call_not_found, call}, _state) do
    log call.sid, "Call not found"
  end

  def handle_event({:completed, call}, _state) do
    log call.sid, "Call completed"
  end

  def handle_event({:transition, {call, twilio, _data}}, _state) do
    log call.sid, """
    Transitioning on #{inspect call.state.name} in response to #{inspect twilio}
    """
  end

  def handle_event({:transition_failed,
                    {_exception, call, _twilio, _data}}, _state) do
    log call.sid, "Transition on #{inspect call.state.name} failed!"
  end

  def handle_event({:new_state, call}, _state) do
    log call.sid, "New state: #{inspect call.state}"
  end

  def handle_event(_event, _state), do: {:ok, :not_handled}

  defp log(sid, string) when sid == nil, do: log("unknown", string)
  defp log(sid, string) do
    msg = "Telephonist: [#{sid}] #{string}"
    Logger.debug msg
    {:ok, msg}
  end
end
