defmodule Demo.WechatController do
  use Demo.Web, :controller

  plug Wechat.Plugs.CheckUrlSignature
  plug Wechat.Plugs.CheckMsgSignature when action in [:create]

  def index(conn, %{"echostr" => echostr}) do
    text conn, echostr
  end

  def create(conn, _params) do
    msg = conn.assigns[:msg]
    reply = build_text_reply(msg, msg.content)
    render conn, "text.xml", reply: reply
  end

  defp build_text_reply(%{tousername: to, fromusername: from}, content) do
    %{from: to, to: from, content: content}
  end
end