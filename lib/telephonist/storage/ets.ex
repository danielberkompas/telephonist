defmodule Telephonist.Storage.ETS do
  @moduledoc """
  Stores the state of calls in an ETS table. In order to use, make sure that you
  add `#{__MODULE__}` to your application supervisor.
  """

  @behaviour Telephonist.Storage

  # GenServer is only used to start a process to own the ETS table.
  # All interaction with the ETS table is done directly for maximum
  # performance.
  use GenServer

  @doc """
  Save the state of an ongoing call.

  ## Parameters

  - `call`: A tuple in the format `{sid, status, state}` where:
      - `sid`: a binary representing the Twilio call SID.
      - `status`: a binary representing the Twilio status. (e.g., "in-progress")
      - `state`: a `Telephonist.State`.

  ## Examples

      iex> Storage.save({"sid", "in-progress", %Telephonist.State{}})
      :ok

      iex> Storage.save(:invalid)
      {:error, "Call must be in format: {sid, status, state}, was :invalid"}
  """
  def save({_sid, _status, _state} = call) do
    :ets.insert(__MODULE__, call)
    :ok
  end
  def save(invalid) do
    msg = "Call must be in format: {sid, status, state}, was #{inspect invalid}"
    {:error, msg}
  end

  @doc ~S"""
  Lookup the state of an ongoing call.

  ## Parameters

  - `sid`: A string represnting the Twilio call SID.

  ## Examples

      iex> Storage.save({"sid", "in-progress", %{}})
      ...> Storage.find("sid")
      {:ok, {"sid", "in-progress", %{}}}

      iex> Storage.find("nonexistent")
      {:error, "No call with SID \"nonexistent\" is in progress."}
  """
  def find(sid) do
    case :ets.lookup(__MODULE__, sid) do
      []       -> {:error, "No call with SID #{inspect sid} is in progress."}
      [call|_] -> {:ok, call}
    end
  end

  @doc ~S"""
  Delete a call status from the Storage.Storage database.

  ## Parameters

  - `call` or `sid`: Either a call tuple or SID.

  ## Examples

      iex> Storage.save({"delete", "in-progress", %{}})
      ...> Storage.delete("delete")
      ...> Storage.find("delete")
      {:error, "No call with SID \"delete\" is in progress."}
  """
  def delete({sid, _, _}), do: delete(sid)
  def delete(sid) do
    :ets.delete(__MODULE__, sid)
    :ok
  end

  ##
  # GenServer API
  ##

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc false
  def init(_) do
    :ets.new(__MODULE__, [:named_table, :public])
    {:ok, nil}
  end
end
