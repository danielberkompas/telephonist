defmodule Telephonist.Subscriber do
  use Behaviour
  
  @type event_name :: atom
  @type data       :: tuple

  defcallback on_event(event_name, data)

  defmacro __using__(_) do
    quote do
      @behaviour Telephonist.Subscriber
    end
  end
end
