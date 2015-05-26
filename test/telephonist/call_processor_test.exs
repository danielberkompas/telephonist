defmodule Telephonist.CallProcessorTest do
  use ExUnit.Case
  alias Telephonist.OngoingCall
  alias Telephonist.CallProcessor

  defmodule TestMachine do
    use Telephonist.StateMachine, initial_state: :introduction

    state :introduction, _twilio, _options do
      say "Hello there!"
    end

    state :english, _twilio, _options do
      say "I speak English!"
    end

    state :spanish, _twilio, _options do
      say "I speak Espanol!"
    end

    state :secret, _twilio, _options do
      say "Secret!"
    end

    def transition(:introduction, %{Digits: "1"} = twilio, options) do
      state(:english, twilio, options)
    end

    def transition(:introduction, %{Digits: "2"} = twilio, options) do
      state(:spanish, twilio, options)
    end

    def on_complete(_, _, _), do: :ok

    def on_transition_error(_, _, twilio, options) do
      state(:secret, twilio, options)
    end
  end

  test ".process first returns the :introduction state, saves state of call" do
    twilio = %{
      CallSid: "test",
      CallStatus: "in-progress"
    }

    state = CallProcessor.process(TestMachine, twilio, %{user: "daniel"})

    assert state.machine      == TestMachine
    assert state.name         == :introduction
    assert state.options.user == "daniel"
    assert state.twiml        =~ ~r/Hello/
    assert_saved_state  :test, state
    assert_saved_status :test, "in-progress"
  end

  test ".process returns :complete state if the call has ended and we've never seen it before" do
    twilio = %{
      CallSid: "CANEVERSEEN",
      CallStatus: "failed"
    }

    state = CallProcessor.process(TestMachine, twilio, %{hello: "world!"})
    assert state.machine == TestMachine
    assert state.name    == :complete
    assert state.options == %{hello: "world!"}
    assert state.twiml   == "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response></Response>" 

    # Deletes call from OngoingCall lookup table
    assert {:error, _msg} = OngoingCall.lookup(:CANEVERSEEN)
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

  test ".process can recover from transition errors using .on_transition_error" do
    state = navigate("CASECRET", "3")
    assert state.name == :secret
  end

  ###
  # Helpers
  ###

  defp navigate(sid, digits) do
    twilio = %{
      CallSid: sid,
      CallStatus: "in-progress"
    }

    # set up initial state
    CallProcessor.process(TestMachine, twilio)

    # simulate user pressing digit
    twilio = Map.put(twilio, :Digits, digits)
    CallProcessor.process(TestMachine, twilio)
  end

  defp assert_saved_status(sid, status) do
    {:ok, {_sid, saved_status, _state}} = OngoingCall.lookup(sid)
    assert saved_status == status
  end

  defp assert_saved_state(sid, state) do
    {:ok, {_sid, _status, saved_state}} = OngoingCall.lookup(sid)
    assert saved_state == state
  end

end
