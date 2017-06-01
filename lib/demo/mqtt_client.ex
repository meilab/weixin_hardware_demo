defmodule Demo.MqttClient do
  use GenMQTT

  def start_link do
    result = { :ok, pid } = GenMQTT.start_link(__MODULE__, nil, [client: "phoenix", host: "47.92.27.57", port: 1883 ])
    Demo.MqttStash.update(pid)

    result
  end

  def on_connect(state) do
    :ok = GenMQTT.subscribe(self(), "sensor/+/temp", 0)
    {:ok, state}
  end

  def on_publish(["sensor", sensorId, "temp"], message, state) do
    IO.puts "It is #{message} degree of #{sensorId}"
    {:ok, state}
  end

  def publish_msg(clientId, message) do
    pid = Demo.MqttStash.get()
    :ok = GenMQTT.publish(pid, "sensor/" <> clientId <>"/temp", message, 0)
  end

end