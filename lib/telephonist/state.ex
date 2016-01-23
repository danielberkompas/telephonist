defmodule Telephonist.State do
  @moduledoc """
  `#{__MODULE__}` represents a given state for an ongoing phone call.

  ## Attributes

  - `name`: the name of the state.
  - `machine`: the module name of the state machine the state is a part of.
  - `data`: any custom data about the call that you want to store between
    Twilio requests.
  - `twiml`: the TwiML representation of the state.

  ## Example

      %Telephonist.State{
        name: "introduction",
        machine: IntroductionMachine,
        data: %{
          language: "en"
        },
        twiml: "<?xml ..."
      }
  """

  import ExTwiml

  @type t :: %__MODULE__{
               name: atom,
               machine: module,
               data: map,
               twiml: String.t
             }

  defstruct name: nil,
            machine: nil,
            data: %{},
            twiml: nil

  @doc "Returns a 'complete' state, with data from a given state"
  @spec complete(__MODULE__.t) :: __MODULE__.t
  def complete(state) do
    twiml = twiml do: nil
    %__MODULE__{
      name: :complete,
      machine: state.machine,
      data: state.data || %{},
      twiml: twiml
    }
  end
end

defimpl Inspect, for: Telephonist.State do
  def inspect(state, _opts) do
    data =
      [state.machine, state.name, state.data, state.twiml]
      |> Enum.join(", ")
    "#Telephonist.State<#{data}>"
  end
end
