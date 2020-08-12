defmodule SocketTranslatorPhx.Translator do

  @spec translate_message(String.t(), String.t()) :: {:ok, String.t()} | {:error, atom()}
  def translate_message(message, _token \\ "") do
    token = "CggVAgAAABoBMxKABLW9R3iMYkJjjI-1CogbUuPPgmDV7AERy_lcsnekg7bGkD9fUBzYLf_uFZMFNkHylFDk-NTkA0IZLb9aVqwLJ06y3Zse8lfkfVcsRrU43yeZxbxWV-jAU-l7MvCjvJl94D1QN_hhpU4yS1UyVUHQI753ZrKAW3zBnRpPaAEk9wfbzhOF4OX_VlSnt5bQ7uW9d7CBePMnpjvJK2CfyYz4sliW-jaE0iaMihQmBivgptPN847fgiTKOr6-4zm8BQQP0oqrD8Gdg77pHPaeFMMnmAI-sNd8g3bVwO-hHGxkW8gG813Pm_m7rB678eUt4pKOXdRdEs7aEJto8fOZoLk0vQRr1AkkDvssdPdaB4on4v6EY5vMfdfxBGgh6WE9KYdkzbrpY2AjB8gnYl86_knU8gri_vt-tInNS89BUGoCTFIrziEkWTWL5X_UnmimsDVa3CyfgepmTNr806aa0t9Tuv6tEfsUdfX4aGze38LFaqwEbwYLdqX_Jej3LQuhcBXTVQZTJgIS4aZ98wWbgK2qzWN50tMse9yOJ-NlqlBXVOKqYEM6glrd0LhGWiNEAb4VMHZjRCRWNhgtP9prh2MIiguwE01FFxoEDlOxnzL74xbBmiG_cZpKuCxptKzlO7mBE99Y02R4tCj9uJp0JdMpAetgGu8IwCvjaLU98TePG0zJGiQQktHQ-QUY0qLT-QUiFgoUYWplaWJsbzJwM29tdmN1azB2dGs="

    headers = [{"Content-Type", "application/json"}, {"Authorization", "Bearer #{token}"}]

    body =
      %{
        folder_id: "b1g75qo3ke15tavldsvv",
        texts: message,
        targetLanguageCode: "ru"
      }
      |> Jason.encode!()

    api_url = get_api_url()

    case HTTPoison.post(api_url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200} = response} -> parse_response(response)
      {:ok, %HTTPoison.Response{status_code: 400} = response} -> parse_error(response)
      {:ok, %HTTPoison.Response{status_code: 500} = response} -> parse_error(response)
      {:error, %HTTPoison.Error{} = error} -> parse_error(error)
    end
  end


  defp parse_response(%HTTPoison.Response{body: body}) do
    result = Jason.decode!(body)

    %{"translations" => translations} = result

    Enum.reduce(translations, "", fn %{"text" => text}, acc -> acc  <> text <> " " end)
    |> String.trim()
  end

  defp parse_error(%HTTPoison.Error{reason: reason}), do: {:error, reason}

  defp parse_error(%HTTPoison.Response{status_code: 400}), do: {:error, :bad_request}

  defp parse_error(%HTTPoison.Response{status_code: 500}), do: {:error, :internal_server_error}

  defp get_api_url(), do: Application.get_env(:socket_translator_phx, __MODULE__)[:api_url]
end
