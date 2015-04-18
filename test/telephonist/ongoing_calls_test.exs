defmodule Telephonist.OngoingCallsTest do
  use ExUnit.Case
  alias Telephonist.OngoingCalls

  ###
  # Public API Tests
  ###

  test "has an ETS table" do
    table = OngoingCalls.table
    assert is_integer(table), "ETS table was not transfered to OngoingCalls"
  end

  test "its ETS table survives even if it crashes" do
    original_table = OngoingCalls.table
    restart_manager

    new_table = OngoingCalls.table
    assert is_integer(new_table), "OngoingCalls was not repopulated with ETS table after reboot"
    assert is_list(:ets.info(new_table))
    assert new_table == original_table, "New OngoingCalls table does not match old"
  end

  test ".save_call can insert a call if its properly formatted" do
    assert :ok == OngoingCalls.save_call({:Sid, "in-progress", %Telephonist.State{}})
  end

  test ".lookup_call can lookup a call by SID" do
    OngoingCalls.save_call({:Sid, "in-progress", %Telephonist.State{}})
    {:ok, call} = OngoingCalls.lookup_call(:Sid)
    assert call == {:Sid, "in-progress", %Telephonist.State{}}
  end

  test ".lookup_call returns {:error, message} if call cannot be found" do
    assert {:error, _msg} = OngoingCalls.lookup_call(:nonexistent)
  end

  test ".delete_call removes a call from the table" do
    call = {:DeleteMe, "in-progress", %{}}
    OngoingCalls.save_call(call)

    # Ensure call is in database
    assert {:ok, call} = OngoingCalls.lookup_call(:DeleteMe)

    # Delete, and try again
    :ok = OngoingCalls.delete_call(call)
    assert {:error, _msg} = OngoingCalls.lookup_call(:DeleteMe)
  end

  ###
  # Processing Tests
  ###

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

  test ".process first returns the :introduction state" do
    twilio = %{
      CallSid: "CA1234",
      CallStatus: "in-progress"
    }

    state = OngoingCalls.process(TestMachine, twilio, %{user: "daniel"})

    assert state.machine      == TestMachine
    assert state.name         == :introduction
    assert state.options.user == "daniel"
    assert state.twiml        =~ ~r/Hello/
  end

  test ".process returns :complete if the call has ended and we've never seen it before" do
    twilio = %{
      CallSid: "CANEVERSEEN",
      CallStatus: "failed"
    }

    assert :complete = OngoingCalls.process(TestMachine, twilio)
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
    OngoingCalls.process(TestMachine, twilio)

    # simulate user pressing digit
    twilio = Map.put(twilio, :Digits, digits)
    OngoingCalls.process(TestMachine, twilio)
  end

  defp restart_manager do
    pid = Process.whereis(OngoingCalls)
    Process.exit(pid, :normal)
    OngoingCalls.start_link
  end
end
