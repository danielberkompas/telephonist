defmodule Telephonist.CallProcessorTest do
  use ExUnit.Case

  alias Telephonist.CallProcessor

  defmodule TestMachine do
    use Telephonist.StateMachine, initial_state: :introduction

    state :introduction, _twilio, _data do
      say "Hello there!"
    end

    state :english, _twilio, _data do
      say "I speak English!"
    end

    state :spanish, _twilio, _data do
      say "I speak Espanol!"
    end

    state :secret, _twilio, _data do
      say "Secret!"
    end

    def transition(:introduction, %{"Digits" => "1"} = twilio, data) do
      state(:english, twilio, data)
    end

    def transition(:introduction, %{"Digits" => "2"} = twilio, data) do
      state(:spanish, twilio, data)
    end

    def on_complete(_, _, _), do: :ok

    def on_transition_error(_, _, twilio, data) do
      state(:secret, twilio, data)
    end
  end

  test ".process first returns the :introduction state, saves state of call" do
    twilio = %{
      "CallSid" => "test",
      "CallStatus" => "in-progress"
    }

    state = CallProcessor.process(TestMachine, twilio, %{user: "daniel"})

    assert state.machine      == TestMachine
    assert state.name         == :introduction
    assert state.data.user == "daniel"
    assert state.twiml        =~ ~r/Hello/
    assert_saved_state  "test", state
    assert_saved_status "test", "in-progress"
  end

  test ".process returns :complete state if the call has ended" do
    twilio = %{
      "CallSid" => "CANEVERSEEN",
      "CallStatus" => "failed"
    }

    state = CallProcessor.process(TestMachine, twilio, %{hello: "world!"})
    assert state.machine == TestMachine
    assert state.name    == :complete
    assert state.data == %{hello: "world!"}
    assert state.twiml ==
      ~S{<?xml version="1.0" encoding="UTF-8"?><Response></Response>}
  end

  test ".process can navigate to the :english state" do
    state = navigate("CAENGLISH", "1")
    assert state.name  == :english
    assert state.twiml =~ ~r/English/
  end

  test ".process can navigate to the :spanish state" do
    state = navigate("CASPANISH", "2")
    assert state.name == :spanish
    assert state.twiml =~ ~r/Espanol/
  end

  test ".process can recover from transition errors" do
    state = navigate("CASECRET", "3")
    assert state.name == :secret
  end

  ###
  # Helpers
  ###

  defp navigate(sid, digits) do
    twilio = %{
      "CallSid" => sid,
      "CallStatus" => "in-progress"
    }

    # set up initial state
    CallProcessor.process(TestMachine, twilio)

    # simulate user pressing digit
    twilio = Map.put(twilio, "Digits", digits)
    CallProcessor.process(TestMachine, twilio)
  end

  defp assert_saved_status(sid, status) do
    {:ok, %{status: saved_status}} = storage.find(sid)
    assert saved_status == status
  end

  defp assert_saved_state(sid, state) do
    {:ok, %{state: saved_state}} = storage.find(sid)
    assert saved_state == state
  end

  defp storage do
    Application.get_env(:telephonist, :storage)
  end
end
