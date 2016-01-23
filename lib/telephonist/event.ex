defmodule Telephonist.Event do
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

        def handle_event({:processing, {machine, twilio, data}}, _state) do
          # ...
        end
      end

  And be sure to start your handler in your supervisor:

      children = [
        worker(MyHandler, [])
      ]

  ## Events

  You can see all of the events currently broadcasted by `Telephonist.Event` in
  the `Telephonist.Event.event` typespec.

  In your subscriber, add a `handle_event/2` callback for any of these
  events. You should also add a fallback definition to catch those events you
  don't care about:

      def handle_event(_event, _state), do: {:ok, :not_handled}
  """

  use GenEvent

  alias Telephonist.Call

  @type twilio :: %{String.t => String.t}
  @type data :: map
  @type exception :: struct
  @type event :: {:processing, {module, twilio, data}}
               | {:call_found, Call.t}
               | {:call_not_found, Call.t}
               | {:completed, Call.t}
               | {:new_state, Call.t}
               | {:transition, {Call.t, twilio, data}}
               | {:transition_failed, {exception, Call.t, twilio, data}}

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
