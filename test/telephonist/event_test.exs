defmodule Telephonist.EventTest do
  use ExUnit.Case
  alias Telephonist.Event
  alias Telephonist.Subscription

  defmodule SubscriberOne do
    use Telephonist.Subscriber

    def on_event(_, _), do: :subscriber_1
  end

  defmodule SubscriberTwo do
    use Telephonist.Subscriber

    def on_event(_, _), do: :subscriber_2
  end

  setup do
    Subscription.clear
    Event.subscribe(SubscriberOne, [:test])
    Event.subscribe(SubscriberTwo, [:test])
  end

  test ".subscribe adds a Subscription" do
    expected = [
      {SubscriberTwo, [:test]}, 
      {SubscriberOne, [:test]}
    ] 
  
    assert expected == Subscription.all
  end

  test ".broadcast calls the on_event handlers of all subscribers" do
    results = Event.broadcast(:test, [])
              |> Enum.map(&Task.await/1)

    assert [:subscriber_2, :subscriber_1] = results
  end
end
