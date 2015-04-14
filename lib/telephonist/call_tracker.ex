defmodule Telephonist.CallTracker do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Retrieve the ETS table ID for the CallTracker process.
  """
  def table do
    GenServer.call(__MODULE__, :retrieve_table)
  end

  ###
  # GenServer API
  ###

  @doc "Receive control of the ETS table from Immortal.EtsTableManager"
  def handle_info({:"ETS-TRANSFER", table, _pid, _data}, _state) do
    {:noreply, table}
  end

  def handle_call(:retrieve_table, _from, table) do
    {:reply, table, table}
  end
end
