defmodule Telephonist.Storage do
  @moduledoc """
  A behaviour defining how to store and lookup ongoing calls. Allows calls to
  be persisted in any kind of backend that implements the behaviour.
  """

  @type error  :: {:error, String.t}

  @doc """
  Save an ongoing call to the storage system.
  """
  @callback save(Telephonist.Call.t) :: :ok | error

  @doc """
  Load a given call out of the storage system using its SID.
  """
  @callback find(Telephonist.Call.sid) :: {:ok, Telephonist.Call.t} | error

  @doc """
  Delete a call from the storage system by its SID.
  """
  @callback delete(Telephonist.Call.sid) :: :ok | error
end
