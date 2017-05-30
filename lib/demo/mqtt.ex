defmodule Demo.Mqtt do
  use GenMQTT

  def start_link do
    GenMQTT.start_link(__MODULE__, nil, [client: "phoenix", host: "47.92.27.57", port: 1883 ])
  end

  def on_connect(state) do
    IO.puts "connected"
    :ok = GenMQTT.subscribe(self(), "sensor/+/temp", 0)
    :ok = GenMQTT.publish(self(), "sensor/phoenix/temp", "Phoenix Connected", 0)
    {:ok, state}
  end

  def on_publish(["sensor", sensorId, "temp"], message, state) do
    IO.puts "It is #{message} degree of #{sensorId}"
    {:ok, state}
  end

  def publish_msg(clientId, message) do
    GenMQTT.publish(self(), "sensor/phoenix/temp", "Phoenix Connected out", 0)
    :ok = GenMQTT.publish(self(), "sensor/" <> clientId <>"/temp", message, 0)
  end

  :ok = GenMQTT.publish(self(), "sensor/phoenix/temp", "Phoenix Connected out", 0)
end