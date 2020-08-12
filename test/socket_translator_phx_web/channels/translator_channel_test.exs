defmodule SocketTranslatorPhxWeb.TranslatorChannelTest do
  use ExUnit.Case
  use Phoenix.ChannelTest
  alias SocketTranslatorPhxWeb.Channels.TranslatorChannel
  @endpoint SocketTranslatorPhxWeb.Endpoint

  describe "WebSocket channels" do
    setup do
    {:ok, _, socket} =
      SocketTranslatorPhxWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(TranslatorChannel, "translator")

      bypass = Bypass.open(port: 5000)

      {:ok, %{socket: socket, bypass: bypass}}
    end

    test "Success case", %{socket: socket, bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/translate/v2/translate", fn conn ->
        response = %{translations: [%{text: "Hi"}]} |> Jason.encode!()

        Plug.Conn.resp(conn, 200, response)
      end)

      ref = push(socket, "translate", %{"message" => "Привет"})

      assert_broadcast(ref, %{message: "Hi"}, 500)
    end
  end
end
