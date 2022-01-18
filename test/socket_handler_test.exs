defmodule SocketHandlerTest do
  use ExUnit.Case

  setup do
    sh = start_supervised!(SocketHandler)
    %{socket_handler: sh}
  end
end
