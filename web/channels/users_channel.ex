defmodule Demo.UsersChannel do
  use Demo.Web, :channel

  alias Demo.Presence

  def join("room:" <> room_id, params, socket) do
    IO.puts "room Params"
    IO.inspect params
    send(self(), :after_join)
    {:ok, %{}, socket}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.username, %{
      username: socket.assigns.username
    })
    push socket, "presence_state", Presence.list(socket)

    {:noreply, socket}
  end

  def handle_in("new_status", %{"status" => status}, socket) do
    {:ok, _} = Presence.update(socket, socket.assigns.username, %{
      username: socket.assigns.username
    })

    {:noreply, socket}
  end

  def handle_in("new_msg", params, socket) do
    IO.puts "new messge"
    IO.inspect params 
    broadcast! socket, "new_msg", %{
      id: 1,
      user: Demo.UserView.render("user.json", %{user: %{id: 1, username: "hehe"}}),
      body: params.body,
      at: params.at
    }

    {:reply, :ok, socket}
  end
end