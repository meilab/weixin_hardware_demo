defmodule Demo.ApiView do
  use Demo.Web, :view

  def render("user.json", %{user: user}) do
    %{
      "code": "200",
      "token": "111"
    }
  end

  def render("chat.json", %{message: message}) do
      message
  end
end