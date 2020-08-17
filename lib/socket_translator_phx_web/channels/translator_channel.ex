defmodule SocketTranslatorPhxWeb.Channels.TranslatorChannel do
  use Phoenix.Channel
  alias SocketTranslatorPhx.YandexTranslator
  alias SocketTranslatorPhx.TranslationHistories
  alias SocketTranslatorPhx.Workers.CacheWorker
  alias SocketTranslatorPhx.TranslateTasks
  require Logger

  def join("translator", _message, socket) do
    {:ok, socket}
  end

  def handle_in("translate", %{"message" => message}, socket) do
    if String.length(message) <= 280 do
      run_translate_task(message, socket)
      {:noreply, socket}
    else
      Logger.warn("Got long message > 280 characters, message: #{inspect(message)}")
      {:reply, {:ok, %{"error" => "Error! Too long message"}}, socket}
    end
  end

  def handle_info({_ref, {:ok, _translated_message, _message}}, socket) do
    {:noreply, socket}
  end

  def handle_info({_ref, {:error, reason}}, socket) do
    Logger.error("Error occured due async task in translator channel, reason: #{inspect(reason)}")
    {:noreply, socket}
  end

  def handle_info({:DOWN, _ref, :process, _pid, :normal}, socket) do
    {:noreply, socket}
  end

  def handle_info({:DOWN, _ref, :process, _pid, reason}, socket) do
    Logger.error("Raise exeption occured due task, reason: #{inspect(reason)}")
    {:noreply, socket}
  end

  defp run_translate_task(message, socket) do
    Task.Supervisor.async_nolink(TranslateTasks, fn ->
      case YandexTranslator.translate_message(message) do
        {:error, reason} ->
          broadcast!(socket, "translate", %{error: "Error! Please try again, later"})

          {:error, reason}

        translated_message ->
          TranslationHistories.save_message_history(translated_message, message)
          CacheWorker.put_message_to_cache(translated_message, message)

          broadcast!(socket, "translate", %{eng_message: translated_message})
          {:ok, translated_message, message}
      end
    end)
  end
end
