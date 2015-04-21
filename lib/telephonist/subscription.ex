defmodule Telephonist.Subscription do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def add(module, events), do: cast({:add, module, events})
  def all,                 do: call(:all)
  def clear,               do: cast(:clear)

  ###
  # GenServer API
  ###

  @doc "Receive control of the ETS table from Immortal.EtsTableManager"
  def handle_info({:"ETS-TRANSFER", table, _pid, _data}, _state) do
    {:noreply, table}
  end

  def handle_cast({:add, module, events}, table) do
    :ets.insert(table, {module, events})
    {:noreply, table}
  end

  def handle_cast(:clear, table) do
    :ets.delete_all_objects(table)
    {:noreply, table}
  end

  def handle_call(:all, _from, table) do
    {:reply, :ets.tab2list(table), table}
  end

  ###
  # Private API
  ###

  def call(args), do: GenServer.call(__MODULE__, args)
  def cast(args), do: GenServer.cast(__MODULE__, args)
end
