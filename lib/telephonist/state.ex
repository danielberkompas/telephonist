defmodule Telephonist.State do
  import ExTwiml

  @moduledoc """
  `#{__MODULE__}` represents a given state for an ongoing phone call.

  ## Attributes

  - `name`: the name of the state.
  - `machine`: the module name of the state machine the state is a part of.
  - `options`: the custom options that were passed to this state.
  - `twiml`: the TwiML representation of the state.
  """

  @type t :: %__MODULE__{
               name: atom,
               machine: atom,
               options: map,
               twiml: String.t
             }

  defstruct name: nil,
            machine: nil,
            options: %{},
            twiml: nil

  @doc "Returns a 'complete' state, with data from a given state"
  @spec complete(__MODULE__.t) :: __MODULE__.t
  def complete(state) do
    twiml = twiml do: nil
    %__MODULE__{
      name: :complete,
      machine: state[:machine], 
      options: state[:options] || %{},
      twiml: twiml
    }
  end
end

defimpl Inspect, for: Telephonist.State do
  def inspect(state, _opts) do
    "#Telephonist.State<#{state.machine}, #{inspect state.name}, #{inspect state.options}, #{inspect state.twiml}>"
  end
end
