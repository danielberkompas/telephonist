defmodule Telephonist.Event do
  use GenEvent

  def start_link do
    GenEvent.start_link(name: __MODULE__)
  end

  def notify(event, data) do
    GenEvent.notify(__MODULE__, {event, data})
  end
end
