defmodule Demo.Presence do
  use Phoenix.Presence, otp_app: :demo,
                        pubsub_server: Demo.PubSub
end