defmodule Telephonist do
  @moduledoc """
  Telephonist has 3 important parts:

  - `Telephonist.State`: a struct defining what a call state looks like.
  - `Telephonist.StateMachine`: provides a set of functions that makes it easy
    to define states and transitions between them.
  - `Telephonist.CallProcessor`: performs the real work of taking input from
    Twilio and calling the correct callbacks on your state machines.

  ## State

  A `Telephonist.State` looks like this:

      %Telephonist.State{
        name: "introduction",
        machine: IntroductionMachine,
        options: %{
          language: "en"
        },
        twiml: "<?xml ..."
      }

  Each of these fields has the following meaning:

  - `name`: obviously, the name of the state.
  - `machine`: the name of the `Telephonist.StateMachine` that is currently
    in charge of handling the call.
  - `options`: a map of custom options that have been appended to this call so
    far. This is a great place to store variables you want to keep track of
    throughout the progression of a call.
  - `twiml`: the XML that should be presented to Twilio to progress the call.

  ## State Machines

  State machines are easy to define using the `Telephonist.StateMachine` module.
  
      defmodule CustomCallFlow do
        use Telephonist.StateMachine, initial_state: :choose_language

        state :choose_language, twilio, options do
          say "#\{options[:error]}" # say any error, if present
          gather timeout: 10 do
            say "For English, press 1"
            say "Para español, presione 2"
          end
        end

        state :english, twilio, options do
          say "Proceeding in English..."
        end

        state :spanish, twilio, options do
          say "Procediendo en español..."
        end

        # If the user pressed "1" on their keypad, transition to English state
        def transition(:choose_language, %{Digits: "1"} = twilio, options) do
          state :english, twilio, options
        end

        # If the user pressed "2" on their keypad, transition to Spanish state
        def transition(:choose_language, %{Digits: "2"} = twilio, options) do
          state :spanish, twilio, options
        end

        # If neither of the above are true, append an error to the options and
        # remain on the current state
        def transition(:choose_language, twilio, options) do
          options = Map.put(options, :error, "You pressed an invalid digit. Please try again.")
          state :choose_language, twilio, options
        end
      end

  See the `Telephonist.StateMachine` documentation for more details on how to
  define state machines.

  ## Call Processing
  
  Once you've defined a state machine, it's extremely easy to process calls
  using it. 

      new_state = Telephonist.CallProcessor.process(CustomCallFlow, twilio, options)

  `CustomCallFlow` is the name of the state machine you want to use to
  handle the call, `twilio`, is a map of parameters from Twilio, and `options`
  is a map of custom options that you want to initialize the call with.

  This `process/3` function will perform the following tasks:

  - Look up the call based on the `twilio` params in an internal lookup table, to
    determine the state that it's currently in.
  
  - Call the `transition/3` handler on the given StateMachine with the current
    state.

  - Save the new state to the lookup table, and return it. It is then the
    responsibility of the calling process to render back `new_state.twiml` to
    Twilio.

  ## Other Topics

  ### Event Broadcasting

  Telephonist broadcasts events through `Telephonist.Event`. It's possible to 
  implement custom subscribers, exactly how `Telephonist.Logger` is implemented.

  ### Lookup Table

  Telephonist's lookup table is managed by `Telephonist.OngoingCall`. If you
  need to inspect its contents, see that module's documentation.
  """

  use Application

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Telephonist.Worker, [arg1, arg2, arg3])
      worker(Telephonist.OngoingCall, []),
      worker(Telephonist.Event, []),
      worker(Telephonist.Logger, []),
      worker(Immortal.ETSTableManager, [Telephonist.OngoingCall, [:named_table, :protected]])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Telephonist.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
