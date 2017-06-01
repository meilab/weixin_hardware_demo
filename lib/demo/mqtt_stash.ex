defmodule Demo.MqttStash do
  
  def start_link do
    {:ok, _pid} = Agent.start_link( fn -> %{} end, name: __MODULE__)
  end

  def get() do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def update(pid) do
    Agent.update(__MODULE__,
                fn state ->
                  pid
                end)
  end
end