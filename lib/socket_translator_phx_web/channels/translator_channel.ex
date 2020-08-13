defmodule SocketTranslatorPhxWeb.Channels.TranslatorChannel do
  use Phoenix.Channel
  alias SocketTranslatorPhx.YandexTranslator
  alias SocketTranslatorPhx.TranslationHistories
  alias SocketTranslatorPhx.Workers.CacheWorker
  require Logger

  def join("translator", _message, socket) do
    {:ok, socket}
  end

  def handle_in("translate", %{"message" => message}, socket) do
    if String.length(message) <= 280 do
      run_translate_task(message, socket)
      {:noreply, socket}
    else
      Logger.warn("Got long message (> 280 characters), message: #{inspect(message)}")
      {:reply, {:ok, %{"error" => "Error! Too long message"}}, socket}
    end
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  defp run_translate_task(message, socket) do
    Task.async(fn ->
        # TODO Вынести из функции бд
        case YandexTranslator.translate_message(message) do
          {:error, reason} ->
            Logger.error("Error occured due async task in translator channel, reason: #{inspect(reason)}")
            broadcast!(socket, "translator", %{error: "Error! Please try again, later"})

          translated_message ->
            TranslationHistories.save_message_history(translated_message, message)
            CacheWorker.put_message_to_cache(translated_message, message)

            translated_message
        end
    end)
  end
end
