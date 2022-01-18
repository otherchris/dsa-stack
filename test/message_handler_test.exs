defmodule MessageHandlerTest do
  use ExUnit.Case
  alias MessageHandler, as: MH

  describe "handle start-meeting" do
    test "creates a meeting" do
      before = Registry.count(Registry.DsaStack)
      MH.handle(self(), %{"command" => "start-meeting"})
      assert Registry.count(Registry.DsaStack) == before + 1
    end

    test "sends the meeting state back to the client" do
      MH.handle(self(), %{"command" => "start-meeting"})
      {:messages, m} = Process.info(self(), :messages)
      m_data = Enum.map(m, &Jason.decode!(&1))
      message = Enum.filter(m_data, fn d -> d["message-type"] == "meeting-data" end)
    end
  end

  describe "handle join-meeting" do
    test "adds participant with display name to meeting" do
      {code, pid} = Meeting.create_and_register_meeting()

      MH.handle(self(), %{
        "command" => "join-meeting",
        "payload" => %{"display-name" => "hello", "meeting-code" => code}
      })

      %{participants: [p | _]} = :sys.get_state(pid)
      assert p.display_name == "hello"
    end

    test "sends self id back to the client" do
      {code, pid} = Meeting.create_and_register_meeting()

      MH.handle(self(), %{
        "command" => "join-meeting",
        "payload" => %{"display-name" => "hello", "meeting-code" => code}
      })

      %{participants: [p | _]} = :sys.get_state(pid)

      {:messages, m} = Process.info(self(), :messages)
      m_data = Enum.map(m, &Jason.decode!(&1))
      message = Enum.filter(m_data, fn d -> d["message-type"] == "participant-id" end)
      assert length(message) == 1
    end
  end

  describe "handle create-stack" do
    test "adds a new stack" do
      {code, pid} = Meeting.create_and_register_meeting()

      MH.handle(self(), %{
        "command" => "create-stack",
        "payload" => %{"display-name" => "hello", "meeting-code" => code}
      })

      %{stacks: [s | _]} = :sys.get_state(pid)
      assert s.display_name == "hello"
    end
  end

  describe "handle open-stack" do
    test "sets the stack state to open" do
      {code, pid} = Meeting.create_and_register_meeting()
      stack_id = Meeting.create_stack(pid, "a-stack")

      MH.handle(self(), %{
        "command" => "open-stack",
        "payload" => %{
          "meeting-code" => code,
          "stack-id" => stack_id
        }
      })

      %{stacks: [%{state: s}]} = :sys.get_state(pid)
      assert s == :open
    end
  end

  describe "handle close-stack" do
    test "sets the stack state to closed" do
      {code, pid} = Meeting.create_and_register_meeting()
      stack_id = Meeting.create_stack(pid, "a-stack")

      MH.handle(self(), %{
        "command" => "close-stack",
        "payload" => %{
          "meeting-code" => code,
          "stack-id" => stack_id
        }
      })

      %{stacks: [%{state: s}]} = :sys.get_state(pid)
      assert s == :closed
    end
  end

  describe "handle join-stack" do
    test "adds participant to stack" do
      {code, pid} = Meeting.create_and_register_meeting()
      stack_id = Meeting.create_stack(pid, "a-stack")
      part_id = Meeting.create_participant(pid, "a-part")
      Meeting.set_stack_state(pid, stack_id, :open)

      MH.handle(self(), %{
        "command" => "join-stack",
        "payload" => %{
          "meeting-code" => code,
          "participant-id" => part_id,
          "stack-id" => stack_id
        }
      })

      %{stacks: [%{participants: [p | _]}]} = :sys.get_state(pid)
      assert p == part_id
    end
  end
end
