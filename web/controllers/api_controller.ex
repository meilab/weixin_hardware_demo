defmodule Demo.ApiController do
  use Demo.Web, :controller

  def login(conn, %{"username" => username, "password" => password}) do
    render(conn, "user.json", %{user: ""})
  end

  def chat(conn, %{"token" => token, "message" => message}) do
    :ok = Demo.MqttClient.publish_msg("phoenix_client", message)
    render(conn, "chat.json", %{message: message})
  end
end