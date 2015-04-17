defmodule Telephonist.StateMachine do
  use Behaviour

  @type call       :: Telephonist.CallManager.call
  @type machine    :: atom
  @type state_name :: atom
  @type twilio     :: map
  @type options    :: map
  @type next_state :: state_name | {machine, state_name}

  ###
  # Behaviour
  ###

  defcallback initial_state                           :: state_name
  defcallback state(state_name, twilio, options)      :: Telephonist.State.t
  defcallback transition(state_name, twilio, options) :: Telephonist.State.t
  defcallback on_complete(call, twilio, options)      :: :ok
  defcallback on_transition_error(map, state_name, twilio, options)

  ###
  # Macros
  ###

  defmacro __using__(initial_state: initial_state) do
    quote do
      import Telephonist.StateMachine
      import ExTwiml
      @behaviour Telephonist.StateMachine
      def initial_state, do: unquote(initial_state)
      def on_transition_error(exception, _, _, _), do: raise exception

      defoverridable on_transition_error: 4
    end
  end

  defmacro __using__(_) do
    raise ArgumentError, "You must provide an initial state for the StateMachine."
  end

  defmacro state(name, twilio, options, block) do
    compile(name, twilio, options, block)
  end

  ###
  # Private Interface
  ###

  defp compile(name, twilio, options, do: block) do
    {options, guards} = extract_options_and_guards(options)

    quote do
      def state(unquote(name), unquote(twilio), unquote(options) = options) when unquote(guards) do
        xml = twiml do
          unquote(block)
        end

        %Telephonist.State{
          name: unquote(name),
          machine: __MODULE__,
          options: options,
          twiml: xml
        }
      end
    end
  end

  defp extract_options_and_guards({:when, _, [options, guards]}), do: {options, guards}
  defp extract_options_and_guards(options), do: {options, true}
end
