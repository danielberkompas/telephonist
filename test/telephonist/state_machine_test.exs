defmodule Telephonist.StateMachineTest do
  use ExUnit.Case

  defmodule TestMachine do
    use Telephonist.StateMachine, initial_state: :welcome

    state :welcome, _twilio, %{error: code} when code in [:ok, :bad] do
      say "Bad"
    end

    state :welcome, _twilio, %{error: :terrible} do
      say "Terrible"
    end

    state :welcome, _twilio, _options do
      say "Welcome"
    end

    state :call, _, _ do
      say "Call"
    end

    def transition(:welcome, %{Digits: digits} = twilio, options)
    when byte_size(digits) == 3 do
      state(:call, twilio, options)
    end

    def transition(:welcome, twilio, options) do
      options = Map.put(options, :error, :terrible)
      state(:welcome, twilio, options)
    end

    def on_complete(_, _, _), do: :ok
  end

  test "initial_state is :welcome" do
    assert TestMachine.initial_state == :welcome
  end

  test ":welcome state says 'Welcome' if there are no errors" do
    state = TestMachine.state(:welcome, %{}, %{option: "val"})
    assert state.twiml =~ ~r/Welcome/
    assert %{option: "val"} = state.options
  end

  test ":welcome can differentiate between different types of errors" do
    state = TestMachine.state(:welcome, %{}, %{error: :ok})
    assert state.twiml =~ ~r/Bad/

    state = TestMachine.state(:welcome, %{}, %{error: :bad})
    assert state.twiml =~ ~r/Bad/

    state = TestMachine.state(:welcome, %{}, %{error: :terrible})
    assert state.twiml =~ ~r/Terrible/
  end

  test "transition to :call if 3 digits are entered" do
    state = TestMachine.transition(:welcome, %{Digits: "123"}, %{})
    assert state.name == :call
  end

  test "transition to :welcome with an error if less than three digits" do
    state = TestMachine.transition(:welcome, %{Digits: "12"}, %{})
    assert state.name == :welcome
    assert %{error: _msg} = state.options
  end
end
