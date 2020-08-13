defmodule SocketTranslatorPhx.YandexTranslatorTest do
  use ExUnit.Case, async: false

  alias SocketTranslatorPhx.YandexTranslator
  alias SocketTranslatorPhx.Repo

  describe "Yandex translator integration" do
    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
      Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

      bypass = Bypass.open(port: 5000)

      {:ok, %{bypass: bypass}}
    end

    test "Success case, should return Привет", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/translate/v2/translate", fn conn ->
        response = %{translations: [%{text: "Hello"}]} |> Jason.encode!()

        Plug.Conn.resp(conn, 200, response)
      end)

      assert "Hello" = YandexTranslator.translate_message("Привет")
    end

    test "Fail case, should return {:error, reason}", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/translate/v2/translate", fn conn ->

        Plug.Conn.resp(conn, 500, "")
      end)

      assert {:error, reason} = YandexTranslator.translate_message("Привет")
    end
  end
end
