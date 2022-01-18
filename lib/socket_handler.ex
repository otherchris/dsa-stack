defmodule SocketHandler do
  @moduledoc false

  @behaviour :cowboy_websocket

  @impl true
  def init(request, _state) do
    %{pid: pid} = request
    {:cowboy_websocket, request, %{pid: pid}}
  end

  @impl true
  def websocket_init(state) do
    {:ok, state}
  end

  @impl true
  def websocket_handle({:text, json}, state) do
    data = Jason.decode!(json)
    MessageHandler.handle(state.pid, data)
    {:ok, state}
  end

  @impl true
  def websocket_info(info, state) do
    {:reply, {:text, info}, state}
  end

  @impl true
  def terminate(_, _, state) do
    IO.inspect("SHUT IT DOWN, #{inspect(state.pid)}")
    :ok
  end
end
