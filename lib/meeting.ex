defmodule Meeting do
  use GenServer

  @derive {Jason.Encoder, only: [:code, :participants, :stacks]}
  defstruct [:code, participants: [], stacks: []]

  @type t() :: %__MODULE__{
          code: String.t(),
          participants: list(Participant.t()),
          stacks: list(Stack)
        }

  @spec generate_code() :: String.t()
  def generate_code() do
    for _ <- 1..5,
        into: "",
        do: <<Enum.random(?A..?Z)>>
  end

  @spec create_and_register_meeting() :: {String.t(), pid()}
  def create_and_register_meeting() do
    code = Meeting.generate_code()
    name = {:via, Registry, {Registry.DsaStack, code}}
    {:ok, meeting_pid} = Meeting.start_link([code: code], name: name)
    {code, meeting_pid}
  end

  @spec broadcast_update(Meeting.t()) :: :ok
  def broadcast_update(meeting = %{code: code}) do
    message =
      %{
        "message-type" => "meeting-data",
        "message" => meeting
      }
      |> Jason.encode!()

    Registry.dispatch(Registry.MeetingPubSub, code, fn entries ->
      for {pid, _} <- entries, do: send(pid, message)
    end)
  end

  @spec start_link([code: String.t()], term()) :: {:ok, pid()}
  def start_link([code: code], opts) do
    GenServer.start_link(__MODULE__, %{code: code}, opts)
  end

  @spec start_link(term()) :: {:ok, pid()}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @spec(create_participant(pid(), String.t()) :: String, t())
  def create_participant(m, name) do
    GenServer.call(m, {:create_participant, name})
  end

  @spec create_stack(pid(), String.t()) :: :ok
  def create_stack(m, name) do
    GenServer.call(m, {:create_stack, name})
  end

  @spec set_stack_state(pid(), String.t(), Stack.state()) :: :ok
  def set_stack_state(m, stack_id, state) do
    GenServer.cast(m, {:set_stack_state, stack_id, state})
  end

  @spec add_participant_to_stack(pid(), String.t(), String.t()) :: :ok
  def add_participant_to_stack(m, participant_id, stack_id) do
    GenServer.cast(m, {:add_participant_to_stack, participant_id, stack_id})
  end

  # Server callbacks

  # init
  @spec init(:ok | %{code: String.t()}) :: {:ok, Meeting.t()}

  @impl true
  def init(:ok) do
    {:ok,
     %Meeting{
       code: generate_code(),
       participants: [],
       stacks: []
     }}
  end

  @impl true
  def init(%{code: code}) do
    {:ok,
     %Meeting{
       code: code,
       participants: [],
       stacks: []
     }}
  end

  # handle_call
  @spec handle_call(term(), pid(), Meeting.t()) :: {:reply, Meeting.t()}

  @impl true
  def handle_call({:create_participant, name}, _, state = %{participants: p}) do
    id = UUID.uuid4()

    new_state =
      Map.put(
        state,
        :participants,
        p ++ [%Participant{display_name: name, id: id}]
      )

    broadcast_update(new_state)

    {:reply, id, new_state}
  end

  @impl true
  def handle_call({:create_stack, name}, _, state = %{stacks: s}) do
    id = UUID.uuid4()
    new_state = Map.put(state, :stacks, s ++ [%Stack{display_name: name, id: id}])
    broadcast_update(new_state)
    {:reply, id, new_state}
  end

  # handle_cast
  @spec handle_cast(term(), Meeting.t()) :: {:noreply, Meeting.t()}

  @impl true
  def handle_cast({:set_stack_state, stack_id, stack_state}, state = %{stacks: s}) do
    new_stacks =
      Enum.map(s, fn stack = %{id: id} ->
        if stack_id == id, do: Map.put(stack, :state, stack_state), else: stack
      end)

    new_state = Map.put(state, :stacks, new_stacks)

    broadcast_update(new_state)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast(
        {:add_participant_to_stack, participant_id, stack_id},
        state = %{stacks: s, participants: p}
      ) do
    participant_id =
      Enum.find(p, fn part -> part.id == participant_id end)
      |> case do
        %{id: id} -> id
        _ -> nil
      end

    new_stacks =
      Enum.map(s, fn stack ->
        if stack.id == stack_id do
          Stack.add_participant(stack, participant_id)
        else
          stack
        end
      end)

    new_state = Map.put(state, :stacks, new_stacks)

    broadcast_update(new_state)

    {:noreply, new_state}
  end
end
