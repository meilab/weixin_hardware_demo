defmodule Demo.WechatController do
  use Demo.Web, :controller

  plug Wechat.Plugs.CheckUrlSignature
  plug Wechat.Plugs.CheckMsgSignature when action in [:create]

  def index(conn, %{"echostr" => echostr}) do
    text conn, echostr
  end

  def create(conn, _params) do
    deliver_mqtt_msg("hehe")

    msg = conn.assigns[:msg]
    reply = build_text_reply(msg, msg.content)
    render conn, "text.xml", reply: reply
  end

  defp build_text_reply(%{tousername: to, fromusername: from}, content) do
    %{from: to, to: from, content: content}
  end

  defp deliver_mqtt_msg(message) do
    :ok = Demo.MqttClient.publish_msg("weixin_client", message)
  end
end