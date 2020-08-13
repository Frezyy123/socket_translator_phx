defmodule SocketTranslatorPhxWeb.TranslatorChannelTest do
  use ExUnit.Case
  import Phoenix.ChannelTest
  alias SocketTranslatorPhxWeb.Channels.TranslatorChannel
  alias SocketTranslatorPhx.Repo
  alias SocketTranslatorPhx.Workers.CacheWorker
  alias SocketTranslatorPhx.TranslationHistories.TranslationHistory

  @endpoint SocketTranslatorPhxWeb.Endpoint

  describe "WebSocket channels" do
    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
      Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

      {:ok, _, socket} =
        SocketTranslatorPhxWeb.UserSocket
        |> socket("user_id", %{some: :assign})
        |> subscribe_and_join(TranslatorChannel, "translator")

      bypass = Bypass.open(port: 5000)
      on_exit(fn -> CacheWorker.clear_cache() end)

      {:ok, %{socket: socket, bypass: bypass}}
    end

    test "Success case", %{socket: socket, bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/translate/v2/translate", fn conn ->
        response = %{translations: [%{text: "World"}]} |> Jason.encode!()

        Plug.Conn.resp(conn, 200, response)
      end)

      push(socket, "translate", %{"message" => "Мир"})

      assert_broadcast(ref, %{eng_message: "World"}, 500)
      # Асинхронность требует жертв :C
      # Не успевает записать в БД при тесте
      :timer.sleep(100)
      refute nil == Repo.get_by(TranslationHistory, original_message: "World")
    end

    test "Fail case", %{socket: socket} do
      long_message = :crypto.strong_rand_bytes(281) |> Base.encode16()
      ref = push(socket, "translate", %{"message" => long_message})

      assert_reply(ref, :ok, %{"error" => "Error! Too long message"})
      :timer.sleep(100)
      assert nil == Repo.get_by(TranslationHistory, original_message: "World")
    end
  end
end
