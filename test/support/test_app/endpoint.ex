defmodule AdminKit.TestApp.Endpoint do
  use Phoenix.Endpoint, otp_app: :admin_kit

  @session_options [
    store: :cookie,
    key: "_admin_kit_test_key",
    signing_salt: "test_salt"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason

  plug Plug.Session, @session_options
  plug AdminKit.TestApp.Router
end
