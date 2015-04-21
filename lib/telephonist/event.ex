defmodule Telephonist.Event do
  alias Telephonist.Subscription

  @spec subscribe(atom, list) :: :ok
  def subscribe(module, events) do
    Subscription.add(module, events)
  end

  @spec broadcast(atom, any) :: [Task.t]
  def broadcast(event_name, event) do
    for {module, events} <- Subscription.all,
        event_name in events,
        do: Task.async(fn -> module.on_event(event_name, event) end)
  end
end
