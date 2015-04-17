defmodule Telephonist.State do
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
end
