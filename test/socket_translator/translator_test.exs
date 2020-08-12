defmodule SocketTranslatorPhx.TranslatorTest do
  use ExUnit.Case

  alias SocketTranslatorPhx.Translator

  describe "Yandex translator integration" do
    setup do
      bypass = Bypass.open(port: 5000)
      {:ok, %{bypass: bypass}}
    end

    test "Success case, should return Привет", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/translate/v2/translate", fn conn ->
        response = %{translations: [%{text: "Hello"}]} |> Jason.encode!()

        Plug.Conn.resp(conn, 200, response)
      end)

      assert "Hello" = Translator.translate_message("Привет", "some-token")
    end

    test "Fail case, should return {:error, reason}", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/translate/v2/translate", fn conn ->

        Plug.Conn.resp(conn, 500, "")
      end)

      assert {:error, reason} = Translator.translate_message("Привет", "some-token")
    end
  end
end
