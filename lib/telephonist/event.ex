defmodule Telephonist.Event do
  @shortdoc "Simple GenEvent broadcaster for Telephonist events."

  @moduledoc """
  This module publishes any events that Telephonist broadcasts. These events
  include things like state transitions and errors. See `Telephonist.Logger`
  for an example of how to implement a subscriber.

  ## How to Subscribe

  Just use the standard `GenEvent` interface:

      defmodule MyHandler do
        use GenEvent

        def start_link do
          handler = GenEvent.start_link(name: __MODULE__)
          GenEvent.add_handler(Telephonist.Event, __MODULE__, [])
          handler
        end

        # Define callbacks:

        def handle_event({:processing, {machine, twilio, options}}, _state) do
          # ...
        end
      end

  And be sure to start your handler in your supervisor:

      children = [
        worker(MyHandler, [])
      ]

  ## Events

  Telephonist publishes the following events:

  - `{:processing, {state_machine, twilio, options}}`: Fires when
    `CallProcessor.process/3` is called. The three elements of the second tuple
    represent the arguments passed to `process/3`.

      - `state_machine`: The module name (atom) of the state machine that should
        control the progression of the call.

      - `twilio`: A map of parameters passed from Twilio.

      - `options`: A map of options to be passed around with the call as it's
        processed through the system.

  - `{:lookup_succeeded, {sid, status, state}}`: Fired when the call could be
    found in the ongoing storage table. The second tuple is the
    data returned from storage.

      - `sid`: The Twilio SID of the call.

      - `status`: The Twilio status of the call. For example, "in-progress".

      - `state`: The most recent `Telephonist.State` of the call when it was
        saved to the lookup table.

  - `{:lookup_failed, {sid, status, state}}`: Fired when the call could not be
    found in the lookup table. This doesn't indicate an error, just that the
    call will start from the beginning state, rather than progressing from a
    previous state.

  - `{:completed, {sid, state_machine, twilio, options}}`: Fired when a call is
    completed. This can happen when the user drops or hangs up.

      - `sid`: The Twilio SID of the phone call.

      - `state_machine`: The module name of the state machine that the call
        ended on.

      - `twilio`: A map of parameters passed by Twilio.

      - `options`: A map of custom options.

  - `{:transition, {sid, state_machine, state_name, twilio, options}}`: Fired
    when Telephonist attempts to transition a call to a new state.

      - `sid`: The Twilio SID of the call.

      - `state_machine`: The module name (atom) of the state machine.
      `transition/3` will be called on this state machine.

      - `state_name`: The name of the current state to be transitioned from.

      - `twilio`: A map of parameters from Twilio.

      - `options`: A map of custom options.


  - `{:transition_failed, {sid, exception, state_machine, state_name, twilio, options}}`:
    Fired when a transition couldn't take place, usually due to an exception.

      - `sid`: The Twilio SID of the call.

      - `exception`: The exception that caused the transition to fail.

      - `state_machine`: The module name (atom) of the state machine that
        Telephonist attempted to use to do the transition.

      - `state_name`: The name of the state that Telephonist was trying to
        transition from.

      - `twilio`: A map of parameters from Twilio.

      - `options`: A map of custom options.

  - `{:new_state, {sid, status, state}}`: Fired when a call successfully
    transitions to a new state.

      - `sid`: The Twilio SID of the call.

      - `status`: The most recent Twilio status of the call. For example,
        "in-progress".

      - `state`: The new state of the call.

  In your subscriber, add a `handle_event/2` callback for any of the above
  events. You should also add a fallback definition to catch those events you
  don't care about:

      def handle_event(_event, _state), do: {:ok, :not_handled}
  """

  use GenEvent

  @doc false
  def start_link do
    GenEvent.start_link(name: __MODULE__)
  end

  @doc """
  Broadcast an event to all subscribers to `Telephonist.Event`, using
  `GenServer.notify/2`.

  - `event`: The atom name of the event to broadcast.
  - `data`: Any term representing the data you want to broadcast.

  When sent through GenEvent, the event and data will be wrapped in a tuple,
  meaning that if you use `notify/2` like this:

      notify(:my_event, {:some, :data})

  You will need to implement a `handle_event/2` function in your subscriber that
  looks like this:

      def handle_event({:my_event, {first, second}})
  """
  def notify(event, data) do
    GenEvent.notify(__MODULE__, {event, data})
  end
end
