defmodule Telephonist.Subscription do
  use ExActor.GenServer, export: __MODULE__

  defstart start_link, do: initial_state(:ok)

  defhandleinfo {:"ETS-TRANSFER", table, _pid, _data} do
    new_state(table)
  end

  defcast add(module, events), state: table do
    :ets.insert(table, {module, events})
    new_state(table)
  end

  defcast clear, state: table do
    :ets.delete_all_objects(table)
    new_state(table)
  end

  defcall all, state: table do
    reply :ets.tab2list(table), table
  end
end
