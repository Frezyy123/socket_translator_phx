defmodule SocketTranslatorPhx.YandexTranslator do
  alias SocketTranslatorPhx.Workers.TokenWorker
  alias SocketTranslatorPhx.Workers.CacheWorker
  alias SocketTranslatorPhx.TranslationHistories
  @spec translate_message(String.t()) :: {:ok, String.t()} | {:error, atom()}
  def translate_message(message) do

    case CacheWorker.get_translated_message_from_cache(message) do
      nil -> post_request_to_yandex_translator(message)
      translated_message -> translated_message
    end
  end

  defp post_request_to_yandex_translator(message) do
    token = TokenWorker.get_token()

    headers = [{"Content-Type", "application/json"}, {"Authorization", "Bearer #{token}"}]

    body =
      %{
        folder_id: "b1g75qo3ke15tavldsvv",
        texts: message,
        targetLanguageCode: "en"
      }
      |> Jason.encode!()

    api_url = get_api_url()

    case HTTPoison.post(api_url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200} = response} ->
        translated_message = parse_response(response)

        CacheWorker.put_message_to_cache(translated_message, message)
        TranslationHistories.save_message_history(translated_message, message)

        translated_message

      {:ok, %HTTPoison.Response{status_code: 400} = response} ->
        parse_error(response)

      {:ok, %HTTPoison.Response{status_code: 500} = response} ->
        parse_error(response)

      {:error, %HTTPoison.Error{} = error} ->
        parse_error(error)
    end
  end

  @spec parse_response(HTTPoison.Response.t()) :: String.t()
  defp parse_response(%HTTPoison.Response{body: body}) do
    result = Jason.decode!(body)

    %{"translations" => translations} = result

    translated_message =
      translations
      |> Enum.reduce("", fn %{"text" => text}, acc -> acc <> text <> " " end)
      |> String.trim()
  end

  @spec parse_error(HTTPoison.Error.t() | HTTPoison.Response.t()) :: {:error, atom()}
  defp parse_error(%HTTPoison.Error{reason: reason}), do: {:error, reason}

  defp parse_error(%HTTPoison.Response{status_code: 400}), do: {:error, :bad_request}

  defp parse_error(%HTTPoison.Response{status_code: 500}), do: {:error, :internal_server_error}

  @spec get_api_url() :: String.t()
  defp get_api_url(), do: Application.get_env(:socket_translator_phx, __MODULE__)[:api_url]
end
