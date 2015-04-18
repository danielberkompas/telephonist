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
