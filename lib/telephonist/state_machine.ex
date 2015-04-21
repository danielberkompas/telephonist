defmodule Telephonist.StateMachine do
  use Behaviour

  @shortdoc "Behaviour and macros for defining state machines"

  @moduledoc """
  This module provides a `Behaviour` and macros that make designing a
  Telephonist-compatible state machine much easier. 

  ## Usage

  You can use `Telephonist.StateMachine` in two ways:

  Use the behaviour and implement all the callbacks yourself:

      defmodule MyStateMachine do
        @behaviour Telephonist.StateMachine
      end

  Use the `__using__` macro. This will set the `@behaviour` attribute, and
  provide default implementations for `initial_state/0` and 
  `on_transition_error/3`, as well as macros for constructing states:

      defmodule MyStateMachine do
        uses Telephonist.StateMachine, initial_state: :introduction

        state :introduction, twilio, options do
          say "Welcome to my state machine!"
        end
      end

  ### Callbacks
  
  A complete `Telephonist.StateMachine` must implement the following callbacks:

  - `initial_state/0`
  - `state/3` 
  - `transition/3`
  - `on_complete/3`
  - `on_transition_error/4`
  """

  @type call       :: Telephonist.CallManager.call
  @type machine    :: atom
  @type state_name :: atom
  @type twilio     :: map
  @type options    :: map
  @type next_state :: state_name | {machine, state_name}

  ###
  # Behaviour
  ###

  @doc """
  Defines the initial state for the state machine. If you `use
  Telephonist.StateMachine`, this will be defined for you.

  ## Examples

  Implementing it yourself:

      def initial_state, do: :welcome

  With `__using__/1` macro:

      use Telephonist.StateMachine, initial_state: :welcome
  """
  defcallback initial_state :: state_name

  @doc """
  Defines a particular state in your state machine. Can be defined easily using
  the `state/3` macro.
  """
  defcallback state(state_name, twilio, options) :: Telephonist.State.t

  @doc """
  Defines a transition from a given state to a new state. This callback will be
  run when the user gives input, say, by pressing some digits on their phone.
  Each `transition/3` definition must return a new `Telephonist.State`.

  ## Example

  Suppose you have two states: `:introduction` and `:extension`. The
  `:introduction` state welcomes the user and asks them to enter an extension.
  After they enter an extension, you validate it and send them through to the
  `:extension` menu, where they'll be connected. You can define a state machine
  like this:

      defmodule Extensions do
        use Telephonist.StateMachine

        state :introduction, _twilio, %{error: message} do
          gather finish_on_key: "#" do
            say message
          end
        end

        state :introduction, _twilio, _options do
          gather finish_on_key: "#" do
            say \"\"\"
            Welcome to Company, Inc!
            If you know the extension of the person you are trying to reach,
            please enter it now, followed by the pound sign.
            \"\"\"
          end
        end

        state :extension, _twilio, %{extension: extension} do
          say "We will now connect you."
          dial extension.number
        end

        def transition(:introduction, %{Digits: ext_code} = twilio, options) do
          case find_extension(ext_code) do # a database check?
            {:ok, extension} ->
              options = Map.put(options, :extension, extension)
              state(:extension, twilio, options)
            _ ->
              options = Map.put(options, :error, "Sorry, we could not find that extension code. Please try again!")
              state(:introduction, twilio, options)
          end
        end
      end

  The `transition/3` handler in this example checks to make sure that the digits
  entered by the user are a valid extension code by looking them up in a
  database.

  If the extension is found, it appends it to the `options`, and passes it to
  the `state/3` function for `:extension`.

  If the extension is not found, it appends an `:error` to the `options`, and
  returns the `:introduction` state. The pattern matching on `:introduction`
  notices that there is an `:error`, and runs the appropriate version of the
  `:introduction` state. The user can then try again.

  ### Handling Transition Errors

  It is possible that you will accidentally not define a correct `transition`
  handler for one or more of your states. When this happens, you will want to
  have a recovery plan.

  See `on_transition_error/4` for more details on how to do this.
  """
  defcallback transition(state_name, twilio, options) :: Telephonist.State.t

  @doc """
  This callback is run when Twilio reports that the call has completed. It's a
  good place to put any cleanup logic or final logging that you want to perform
  when a call finishes.
  """
  defcallback on_complete(call, twilio, options) :: :ok

  @doc """
  Whenever a call fails to transition due to an exception, this 
  `on_transition_error` handler will be run, and will be given the error that 
  occurred as its first argument.

  It should return a new state. If you `use Telephonist.StateMachine`, the
  default implementation will simply re-raise the exception.
  """
  defcallback on_transition_error(map, state_name, twilio, options)

  ###
  # Macros
  ###

  @doc """
  Imports the module, sets the `@behaviour` attribute, and provides default
  implementations for `initial_state/0` and `on_transition_error/4`.

  Don't forget to set an initial state!

  ## Example

      defmodule MyModule do
        use Telephonist.StateMachine, initial_state: :welcome
      end
  """
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

  @doc """
  A shortcut macro that makes it easier to define a `state/3` function.

  - `name`: the name of the state.
  - `twilio`: a map of Twilio request parameters.
  - `options`: the custom options provided for this state.

  ## Examples

  Macros from `ExTwiml` can be used in the body of the `state` definition:

      state :introduction, _twilio, _options do
        say "Welcome!"
      end

  You can pattern match on the `twilio` and `options` parameters:

      state :introduction, _twilio, %{error: message} do
        say "An error occurred!" <> message
      end

  You can also add guards:

      state :introduction, _twilio, %{error: code} when code in [:catastrophic, :terrible] do
        say "The death toll is catastrophic!"
      end

  ### Under the Hood

  The `state` macro just defines a simple function in this format:

      def state(name, twilio, options) do
        xml = twiml do
          # body evaluated here
        end

        %Telephonist.State{ ... }
      end

  If you prefer to define your states manually like this, just follow this
  pattern and everything should work fine.
  """
  defmacro state(name, twilio, options, block) do
    compile(name, twilio, options, block)
  end

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
