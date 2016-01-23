defmodule Telephonist.Call do
  @moduledoc ~S"""
  Represents a call that `Telephonist` is managing.

  ## Attributes

  - `sid`: The Twilio SID of the call.

  - `status`: The Twilio "CallStatus" of the call. A list of all possible
    statuses [can be found here][0].

  - `state`: The `Telephonist.State` of the call.

  ## Example

      %Telephonist.Call{
        sid: "CA8f65fe38772ea4c2e1c14a46543142cf",
        status: "in-progress",
        state: %Telephonist.State{
          name: "introduction",
          machine: StateMachineName,
          data: %{
            language: "en"
          },
          twiml: "<?xml ..."
        }
      }

  [0]: https://www.twilio.com/docs/api/rest/call#call-status-values
  """

  defstruct sid: nil,
            status: nil,
            state: nil

  @type sid :: String.t
  @type status :: String.t
  @type t :: %__MODULE__{
    sid: sid,
    status: status,
    state: Telephonist.State.t
  }

  def new(sid, status) do
    %__MODULE__{sid: sid, status: status}
  end
end
