defmodule ParticipantTest do
  use ExUnit.Case

  alias Participant, as: P

  test "inc_talk_times" do
    p = %P{display_name: "hello", talk_times: 2}
    assert P.inc_talk_times(p).talk_times == 3
  end
end
