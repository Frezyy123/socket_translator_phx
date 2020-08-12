defmodule SocketTranslatorPhxWeb.TranslatorChannelTest do
  use ExUnit.Case
  import Phoenix.ChannelTest
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

      push(socket, "translate", %{"message" => "Привет"})

      assert_broadcast(ref, %{message: "Hi"}, 500)
    end

    test "Fail case", %{socket: socket} do

      long_message = :crypto.strong_rand_bytes(281) |> Base.encode16()
      ref = push(socket, "translate", %{"message" => long_message})

      assert_reply(ref, :ok, %{"error" => "Error! Too long message"})
    end
  end
end
