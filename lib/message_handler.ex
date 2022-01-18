defmodule MessageHandler do
  @spec handle(pid(), term()) :: :ok
  def handle(pid, %{"command" => "start-meeting"}) do
    {_, meeting_pid} = Meeting.create_and_register_meeting()
    send_meeting_data(pid, meeting_pid)
    Registry.register(Registry.MeetingPubSub, :sys.get_state(meeting_pid).code, [])
    :ok
  end

  def handle(pid, %{
        "command" => "join-meeting",
        "payload" => %{"display-name" => dn, "meeting-code" => code}
      }) do
    meeting = Registry.whereis_name({Registry.DsaStack, code})
    participant_id = Meeting.create_participant(meeting, dn)
    send_meeting_data(pid, meeting)
    send_participant_id(pid, participant_id)
    Registry.register(Registry.MeetingPubSub, :sys.get_state(meeting).code, [])
  end

  def handle(_, %{
        "command" => "create-stack",
        "payload" => %{"meeting-code" => code, "display-name" => sname}
      }) do
    meeting = Registry.whereis_name({Registry.DsaStack, code})
    Meeting.create_stack(meeting, sname)
  end

  def handle(_, %{
        "command" => "join-stack",
        "payload" => %{"meeting-code" => mc, "participant-id" => part_id, "stack-id" => stack_id}
      }) do
    meeting = Registry.whereis_name({Registry.DsaStack, mc})
    Meeting.add_participant_to_stack(meeting, part_id, stack_id)
  end

  def handle(_, %{
        "command" => "open-stack",
        "payload" => %{"meeting-code" => mc, "stack-id" => stack_id}
      }) do
    meeting = Registry.whereis_name({Registry.DsaStack, mc})
    Meeting.set_stack_state(meeting, stack_id, :open)
  end

  def handle(_, %{
        "command" => "close-stack",
        "payload" => %{"meeting-code" => mc, "stack-id" => stack_id}
      }) do
    meeting = Registry.whereis_name({Registry.DsaStack, mc})
    Meeting.set_stack_state(meeting, stack_id, :closed)
  end

  @spec send_meeting_data(pid(), pid()) :: :ok
  defp send_meeting_data(target_pid, meeting_pid) do
    Process.send(
      target_pid,
      %{"message-type" => "meeting-data", "message" => :sys.get_state(meeting_pid)}
      |> Jason.encode!(),
      []
    )
  end

  @spec send_participant_id(pid(), term()) :: :ok
  defp send_participant_id(target_pid, participant_id) do
    Process.send(
      target_pid,
      %{"message-type" => "participant-id", "message" => %{"participant-id" => participant_id}}
      |> Jason.encode!(),
      []
    )
  end
end
