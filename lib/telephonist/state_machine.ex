defmodule Telephonist.StateMachine do
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

        state :introduction, twilio, data do
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

  @type call       :: {String.t, String.t, Telephonist.State.t}
  @type machine    :: atom
  @type state_name :: atom
  @type twilio     :: map
  @type data       :: map
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
  @callback initial_state :: state_name

  @doc """
  Defines a particular state in your state machine. Can be defined easily using
  the `state/3` macro.
  """
  @callback state(state_name, twilio, data) :: Telephonist.State.t

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

        state :introduction, _twilio, _data do
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

        def transition(:introduction, %{"Digits" => ext_code} = twilio, data) do
          case find_extension(ext_code) do # a database check?
            {:ok, extension} ->
              data = Map.put(data, :extension, extension)
              state(:extension, twilio, data)
            _ ->
              error = "Sorry, we could not find that extension code. Try again?"
              data = Map.put(data, :error, error)
              state(:introduction, twilio, data)
          end
        end
      end

  The `transition/3` handler in this example checks to make sure that the digits
  entered by the user are a valid extension code by looking them up in a
  database.

  If the extension is found, it appends it to the `data`, and passes it to
  the `state/3` function for `:extension`.

  If the extension is not found, it appends an `:error` to the `data`, and
  returns the `:introduction` state. The pattern matching on `:introduction`
  notices that there is an `:error`, and runs the appropriate version of the
  `:introduction` state. The user can then try again.

  ### Handling Transition Errors

  It is possible that you will accidentally not define a correct `transition`
  handler for one or more of your states. When this happens, you will want to
  have a recovery plan.

  See `on_transition_error/4` for more details on how to do this.
  """
  @callback transition(state_name, twilio, data) :: Telephonist.State.t

  @doc """
  This callback is run when Twilio reports that the call has completed. It's a
  good place to put any cleanup logic or final logging that you want to perform
  when a call finishes.
  """
  @callback on_complete(call, twilio, data) :: :ok

  @doc """
  Whenever a call fails to transition due to an exception, this
  `on_transition_error` handler will be run, and will be given the error that
  occurred as its first argument.

  It should return a new state. If you `use Telephonist.StateMachine`, the
  default implementation will simply re-raise the exception.
  """
  @callback on_transition_error(map, state_name, twilio, data) :: :ok

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
    raise ArgumentError, "You must define an initial state."
  end

  @doc """
  A shortcut macro that makes it easier to define a `state/3` function.

  - `name`: the name of the state.
  - `twilio`: a map of Twilio request parameters.
  - `data`: the custom data provided for this state.

  ## Examples

  Macros from [ExTwiml](http://hexdocs.pm/ex_twiml) can be used in the body of
  the `state` definition:

      state :introduction, _twilio, _data do
        say "Welcome!"
      end

  You can pattern match on the `twilio` and `data` parameters:

      state :introduction, _twilio, %{error: message} do
        say "An error occurred!" <> message
      end

  You can also add guards:

      state :introduction, _twilio, %{error: code}
      when code in [:catastrophic, :terrible] do
        say "The death toll is catastrophic!"
      end

  ### Under the Hood

  The `state` macro just defines a simple function in this format:

      def state(name, twilio, data) do
        xml = twiml do
          # body evaluated here
        end

        %Telephonist.State{ ... }
      end

  If you prefer to define your states manually like this, just follow this
  pattern and everything should work fine.
  """
  defmacro state(name, twilio, data, block) do
    compile(name, twilio, data, block)
  end

  defp compile(name, twilio, data, do: block) do
    {data, guards} = extract_data_and_guards(data)

    quote do
      def state(unquote(name), unquote(twilio), unquote(data) = data)
      when unquote(guards) do
        xml = twiml do
          unquote(block)
        end

        %Telephonist.State{
          name: unquote(name),
          machine: __MODULE__,
          data: data,
          twiml: xml
        }
      end
    end
  end

  defp extract_data_and_guards({:when, _, [data, guards]}) do
    {data, guards}
  end
  defp extract_data_and_guards(data), do: {data, true}
end
