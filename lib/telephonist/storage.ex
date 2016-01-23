defmodule Telephonist.Storage do
  @moduledoc """
  A behaviour defining how to store and lookup ongoing calls. Allows calls to
  be persisted in any kind of backend that implements the behaviour.
  """

  @type sid    :: String.t
  @type status :: String.t
  @type call   :: {sid, status, Telephonist.State.t}
  @type error  :: {:error, String.t}

  @doc """
  Save an ongoing call to the storage system.
  """
  @callback save(call) :: :ok | error

  @doc """
  Load a given call out of the storage system using its SID.
  """
  @callback find(sid) :: {:ok, call} | error

  @doc """
  Delete a call from the storage system by its SID.
  """
  @callback delete(sid) :: :ok | error
end
