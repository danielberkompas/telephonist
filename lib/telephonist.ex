defmodule Telephonist do

  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Telephonist.Worker, [arg1, arg2, arg3])
      worker(Telephonist.OngoingCall, []),
      worker(Telephonist.Subscription, []),
      worker(Immortal.EtsTableManager, [Telephonist.OngoingCall], id: OngoingCallTableWatcher),
      worker(Immortal.EtsTableManager, [Telephonist.Subscription], id: SubscriptionTableWatcher)
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Telephonist.Supervisor]
    result = Supervisor.start_link(children, opts)

    # Custom setup
    Telephonist.Event.subscribe Telephonist.Logger, [
      :start_processing,
      :lookup_success,
      :call_complete,
      :attempt_transition,
      :transition_error,
      :next_state
    ]

    # End custom setup

    result
  end
end
