defmodule Telephonist.OngoingCall do
  use GenServer

  @shortdoc @moduledoc """
  Stores the state of calls that are currently in progress in an ETS table.
  """

  @type sid    :: atom
  @type status :: String.t
  @type call   :: {sid, status, Telephonist.State.t}
  @type error  :: {:error, String.t}

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Save the state of an ongoing call.

  ## Parameters

  - `call`: A tuple in the format `{sid, status, state}` where:
      - `sid` is an atom representing the Twilio call SID.
      - `status` is a binary representing the Twilio status. (e.g., "in-progress")
      - `state` is a `Telephonist.State`.

  ## Examples

      iex> Telephonist.OngoingCall.save({:sid, "in-progress", %Telephonist.State{}})
      :ok

      iex> Telephonist.OngoingCall.save(:invalid)
      {:error, "Call must be in format: {sid, status, state}, was :invalid"}
  """
  @spec save(call) :: :ok | error
  def save({sid, _status, _state} = call) when is_atom(sid) do
    GenServer.call(__MODULE__, {:save, call})
  end
  def save(invalid) do
    {:error, "Call must be in format: {sid, status, state}, was #{inspect invalid}"}
  end

  @doc """
  Lookup the state of an ongoing call.

  ## Parameters

  - `sid`: An atom represnting the Twilio call SID.

  ## Examples

      iex> Telephonist.OngoingCall.save({:sid, "in-progress", %{}})
      ...> Telephonist.OngoingCall.lookup(:sid)
      {:ok, {:sid, "in-progress", %{}}}

      iex> Telephonist.OngoingCall.lookup(:nonexistent)
      {:error, "No call with SID :nonexistent is in progress."}
  """
  @spec lookup(sid) :: {:ok, call} | error
  def lookup(sid) do
    case :ets.lookup(__MODULE__, sid) do
      []       -> {:error, "No call with SID #{inspect sid} is in progress."}
      [call|_] -> {:ok, call}
    end
  end

  @doc """
  Delete a call status from the OngoingCall database.

  ## Parameters

  - `call` or `sid`: Either a call tuple or atom SID.

  ## Examples

      iex> Telephonist.OngoingCall.save({:delete, "in-progress", %{}})
      ...> Telephonist.OngoingCall.delete(:delete)
      ...> Telephonist.OngoingCall.lookup(:delete)
      {:error, "No call with SID :delete is in progress."}

      iex> Telephonist.OngoingCall.delete("invalid")
      {:error, "SID must be an atom, was \\"invalid\\""}
  """
  @spec delete(call | sid) :: :ok | error
  def delete({sid, _, _}), do: delete(sid)
  def delete(sid) when is_atom(sid) do
    GenServer.call(__MODULE__, {:delete, sid})
  end
  def delete(invalid) do
    {:error, "SID must be an atom, was #{inspect invalid}"}
  end

  ##
  # GenServer API
  ##

  @doc false
  def handle_call({:save, call}, _from, _state) do
    :ets.insert(__MODULE__, call)
    {:reply, :ok, nil}
  end

  @doc false
  def handle_call({:delete, sid}, _from, _state) do
    :ets.delete(__MODULE__, sid)
    {:reply, :ok, nil}
  end
end
