defmodule Telephonist.Regression.ModifyStateTest do
  @moduledoc """
  This test was written to prevent regression of this bug:

  https://github.com/danielberkompas/telephonist/issues/5
  """

  use ExUnit.Case

  alias Telephonist.CallProcessor

  defmodule TestMachine do
    use Telephonist.StateMachine, initial_state: :prompt

    state :prompt, _twilio, _state do
      gather do
        say "Enter a time in minutes"
      end
    end

    state :confirmation, _twilio, %{eta: %{unconfirmed: minutes}} do
      say "You said #{minutes} minutes"
      gather do
        say "If this is correct, press 1"
      end
    end

    state :confirmed, _twilio, job do
      say "Your ETA is confirmed to be #{job.eta.confirmed} minutes"
    end

    def transition(:prompt, %{"Digits" => minutes} = twilio, data) do
      data = Map.put(data, :eta, %{unconfirmed: minutes})
      state :confirmation, twilio, data
    end

    def transition(:confirmation, %{"Digits" => "1"} = twilio, data) do
      minutes = data.eta.unconfirmed
      data = %{data | eta: %{confirmed: minutes}}
      state :confirmed, twilio, data
    end

    def on_complete(_, _, _), do: :ok
  end

  test "entering digits is saved for the next state" do
    twilio = %{
      "CallSid" => "state-modification",
      "CallStatus" => "in-progress",
    }

    # set up initial state
    CallProcessor.process(TestMachine, twilio)

    # simulate user entrering ETA
    twilio = Map.put(twilio, "Digits", "2")
    CallProcessor.process(TestMachine, twilio)

    # simulate user confirming ETA
    twilio = Map.put(twilio, "Digits", "1")
    state = CallProcessor.process(TestMachine, twilio)

    assert state.twiml =~ "Your ETA is confirmed to be 2 minutes"
  end
end
