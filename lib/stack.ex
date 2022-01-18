defmodule Stack do
  @derive {Jason.Encoder, only: [:display_name, :participants, :id, :meeting_id, :state]}
  defstruct [:display_name, :id, :meeting_id, participants: [], state: :pending]

  @type state() :: :open | :pending | :closed

  @type t() :: %__MODULE__{
          display_name: String.t(),
          meeting_id: String.t(),
          participants: list(String.t()),
          state: state()
        }

  @spec add_participant(__MODULE__.t(), String.t()) :: __MODULE__.t()
  def add_participant(s = %{state: :open}, p) do
    participants =
      s
      |> Map.get(:participants)
      |> Kernel.++([p])
      |> Enum.uniq()
      |> Enum.reject(&is_nil(&1))

    Map.put(s, :participants, participants)
  end

  def add_participant(s, _), do: s

  @spec move_up(__MODULE__.t(), integer()) :: __MODULE__.t()
  def move_up(s, i) do
    Map.put(s, :participants, move_up_list(s.participants, i))
  end

  @spec move_down(__MODULE__.t(), integer()) :: __MODULE__.t()
  def move_down(s, i) do
    Map.put(s, :participants, move_down_list(s.participants, i))
  end

  @spec move_up_list(list(), integer()) :: list()
  defp move_up_list(l, i) do
    cond do
      i <= 0 ->
        l

      i >= length(l) ->
        l

      true ->
        Enum.slice(l, 0, i - 1) ++
          [Enum.at(l, i), Enum.at(l, i - 1)] ++ Enum.slice(l, (i + 1)..-1)
    end
  end

  @spec move_down_list(list(), integer()) :: list()
  defp move_down_list(l, i) do
    cond do
      i < 0 ->
        l

      i >= length(l) - 1 ->
        l

      true ->
        Enum.slice(l, 0, i) ++
          [Enum.at(l, i + 1), Enum.at(l, i)] ++ Enum.slice(l, (i + 2)..-1)
    end
  end
end
