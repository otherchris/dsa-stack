defmodule MeetingTest do
  use ExUnit.Case

  setup do
    meeting = start_supervised!(Meeting)
    %{meeting: meeting}
  end

  describe "create_and_register_meeting" do
    test "creates aed registers meeting" do
      before = Registry.count(Registry.DsaStack)
      {code, pid} = Meeting.create_and_register_meeting()
      new_pid = Registry.whereis_name({Registry.DsaStack, code})
      assert pid == new_pid
      assert Kernel.match?(%Meeting{}, :sys.get_state(new_pid))
    end
  end

  describe "start_link" do
    test "starts with empty list of stacks", %{meeting: m} do
      assert :sys.get_state(m).stacks == []
    end

    test "starts with empty list of participants", %{meeting: m} do
      assert :sys.get_state(m).participants == []
    end

    test "creates a five letter meeting code if not given", %{meeting: m} do
      code = :sys.get_state(m).code
      assert String.match?(code, ~r([A-Z]{5}))
    end

    test "uses a meeting code if given" do
      {:ok, pid} = Meeting.start_link([code: "any code"], [])
      assert :sys.get_state(pid).code == "any code"
    end
  end

  describe "create_participant" do
    test "adds a new participant by name", %{meeting: m} do
      test_id = Meeting.create_participant(m, "A. Display Name")

      %{participants: [%Participant{id: id, display_name: dn, talk_times: tt}]} =
        :sys.get_state(m)

      assert dn == "A. Display Name"
      assert tt == 0
      assert test_id == id
    end

    test "assigns and returns uuid to the participant when added", %{meeting: m} do
      id_reply = Meeting.create_participant(m, "A. Display Name")
      %{participants: [%Participant{id: id}]} = :sys.get_state(m)

      assert String.match?(
               id,
               ~r/^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/i
             )

      assert id == id_reply
    end
  end

  describe "create_stack" do
    test "adds a new stack by name", %{meeting: m} do
      Meeting.create_stack(m, "A. Display Name")
      %{stacks: [%Stack{display_name: dn, state: state, participants: p}]} = :sys.get_state(m)
      assert dn == "A. Display Name"
      assert state == :pending
      assert p == []
    end

    test "assigns and returns a uuid to the stack when added", %{meeting: m} do
      stack_id = Meeting.create_stack(m, "A. Display Name")
      %{stacks: [%Stack{id: id}]} = :sys.get_state(m)

      assert String.match?(
               id,
               ~r/^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/i
             )

      assert stack_id == id
    end
  end

  describe "set_stack_state" do
    test "sets a stack state if present", %{meeting: m} do
      Meeting.create_stack(m, "A")
      Meeting.create_stack(m, "B")
      %{stacks: [%{id: stack_id} | _]} = :sys.get_state(m)
      Meeting.set_stack_state(m, stack_id, :open)
      %{stacks: [%{state: state}, %{state: other_state}]} = :sys.get_state(m)
      assert state == :open
      assert other_state == :pending
    end

    test "do nothing if not present", %{meeting: m} do
      Meeting.create_stack(m, "A")
      state = :sys.get_state(m)
      Meeting.set_stack_state(m, "an id", :open)
      new_state = :sys.get_state(m)
      assert state == new_state
    end
  end

  describe "add_participant_to_stack" do
    test "adds a participant to an open stack", %{meeting: m} do
      Meeting.create_stack(m, "A")
      Meeting.create_participant(m, "A. Display Name")
      %{stacks: [%{id: stack_id}], participants: [%{id: p_id}]} = :sys.get_state(m)
      Meeting.set_stack_state(m, stack_id, :open)
      Meeting.add_participant_to_stack(m, p_id, stack_id)
      %{stacks: [%{participants: [id]}]} = :sys.get_state(m)
      assert id == p_id
    end

    test "dont add if stack is not open", %{meeting: m} do
      Meeting.create_stack(m, "A")
      Meeting.create_participant(m, "A. Display Name")
      %{stacks: [%{id: stack_id}], participants: [%{id: p_id}]} = :sys.get_state(m)
      Meeting.add_participant_to_stack(m, p_id, stack_id)
      %{stacks: [%{participants: p}]} = :sys.get_state(m)
      assert p == []
    end

    test "dont add if participant doesn't exist", %{meeting: m} do
      Meeting.create_stack(m, "A")
      %{stacks: [%{id: stack_id}]} = :sys.get_state(m)
      Meeting.set_stack_state(m, stack_id, :open)
      Meeting.add_participant_to_stack(m, "p_id", stack_id)
      %{stacks: [%{participants: p}]} = :sys.get_state(m)
      assert p == []
    end
  end
end
