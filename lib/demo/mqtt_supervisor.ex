defmodule Demo.MqttSupervisor do
  use Supervisor

  def start_link() do
    {:ok, _sup} = Supervisor.start_link(__MODULE__,[], name: __MODULE__)
    start_workers(__MODULE__)
  end

  def start_workers(__MODULE__) do
    Supervisor.start_child(__MODULE__,worker(Demo.MqttStash, []))
    Supervisor.start_child(__MODULE__,worker(Demo.MqttClient, []))
  end

  def init(_) do
    supervise [], strategy: :one_for_one
  end
end