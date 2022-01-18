defmodule Participant do
  @derive {Jason.Encoder, only: [:display_name, :id, :talk_times]}
  defstruct [:display_name, :id, talk_times: 0]

  @type t() :: %__MODULE__{
          id: String.t(),
          display_name: String.t(),
          talk_times: integer()
        }

  @spec inc_talk_times(__MODULE__.t()) :: __MODULE__.t()
  def inc_talk_times(p), do: Map.put(p, :talk_times, p.talk_times + 1)
end
