defmodule Telephonist.SubscriptionTest do
  use ExUnit.Case
  alias Telephonist.Subscription

  defmodule TestSubscriber do
    use Telephonist.Subscriber

    def on_event(_event, _data), do: nil
  end

  setup do
    Subscription.clear
  end

  test "can add a subscriber to the list" do
    assert [] = Subscription.all
    Subscription.add(TestSubscriber, [:attempt_transition])
    assert [{TestSubscriber, [:attempt_transition]}] = Subscription.all
  end
end
