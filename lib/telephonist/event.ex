defmodule Telephonist.Event do
  alias Telephonist.Subscription

  def subscribe(module, events) do
    Subscription.add(module, events)
  end

  def broadcast(event_name, event) do
    Task.async fn ->
      for {module, events} <- Subscription.all,
          event_name in events,
          do: module.on_event(event_name, event)
    end
  end
end
