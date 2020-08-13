defmodule SocketTranslatorPhxWeb.Channels.TranslatorChannel do
  use Phoenix.Channel
  alias SocketTranslatorPhx.YandexTranslator

  def join("translator", _message, socket) do
    {:ok, socket}
  end

  def handle_in("translate", %{"message" => message}, socket) do
    if String.length((message)) <= 280 do
      run_translate_task(socket)
      {:noreply, socket}
    else
      {:reply, {:ok, %{"error" => "Error! Too long message"}}, socket}
    end
  end

  def handle_info(_ , _, socket) do
    [:noreply, socket]
  end

  defp run_translate_task(socket) do
    Task.async(fn ->
      translated_message = YandexTranslator.translate_message("message")
      broadcast!(socket, "translator", %{eng_message: translated_message})
    end)
  end

end
