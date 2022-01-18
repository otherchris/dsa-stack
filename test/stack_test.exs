defmodule StackTest do
  use ExUnit.Case

  alias Stack, as: S

  setup do
    s = %Stack{
      participants: ["A", "B", "C"]
    }

    %{s: s}
  end

  describe "add_participant" do
    test "adds a participant" do
      s = %S{participants: [], state: :open}
      new_s = S.add_participant(s, "p_id")
      assert new_s.participants == ["p_id"]
    end

    test "removes nil" do
      s = %S{participants: [], state: :open}
      new_s = S.add_participant(s, nil)
      assert new_s.participants == []
    end

    test "removes last dupe" do
      s = %S{participants: ["A", "B"], state: :open}
      new_s = S.add_participant(s, "A")
      assert new_s.participants == ["A", "B"]
    end

    test "don't add if not open" do
      s = %S{participants: [], state: :closed}
      new_s = S.add_participant(s, "p_id")
      assert new_s.participants == []
    end
  end

  describe "move_up" do
    test "does nothing to the first", %{s: s} do
      assert S.move_up(s, 0) == s
    end

    test "does nothing with bad index", %{s: s} do
      assert S.move_up(s, -4) == s
      assert S.move_up(s, 4) == s
    end

    test "moves a participant up", %{s: s} do
      new_s = S.move_up(s, 1)
      assert new_s.participants == ["B", "A", "C"]
    end
  end

  describe "move_down" do
    test "does nothing to the last", %{s: s} do
      assert S.move_down(s, 2) == s
    end

    test "does nothing with bad index", %{s: s} do
      assert S.move_down(s, -4) == s
      assert S.move_down(s, 4) == s
    end

    test "moves a participant down", %{s: s} do
      new_s = S.move_down(s, 1)
      assert new_s.participants == ["A", "C", "B"]
    end
  end
end
