defmodule SocketTranslatorPhx.TranslationHistories do
  alias SocketTranslatorPhx.TranslationHistories.TranslationHistory
  alias SocketTranslatorPhx.Repo

  @spec create_translation_history(map()) :: {:ok, TranslationHistory.t()} | {:error, any()}
  def create_translation_history(attrs) do
    %TranslationHistory{}
    |> TranslationHistory.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_translation_history(TranslationHistory.t(), map()) :: {:ok, TranslationHistory.t()} | {:error, any()}
  def update_translation_history(%TranslationHistory{} = translation_history, attrs) do
    translation_history
    |> TranslationHistory.changeset(attrs)
    |> Repo.update()
  end

  @spec delete(TranslationHistory.t()) :: :ok
  def delete(translation_history) do
    Repo.delete(translation_history)
  end

  @spec get_translation_history!(pos_integer()) :: TranslationHistory.t()
  def get_translation_history!(translation_history_id) do
    Repo.get!(TranslationHistory, translation_history_id)
  end

  @spec get_translation_history(pos_integer()) :: TranslationHistory.t() |  nil
  def get_translation_history(translation_history_id) do
    Repo.get(TranslationHistory, translation_history_id)
  end

  @spec list_translation_history() :: [TranslationHistory.t()]
  def list_translation_history() do
    TranslationHistory
    |> Repo.all()
  end

  @spec save_message_history(String.t(), String.t()) :: {:ok, TranslationHistory.t()} | {:error, any()}
  def save_message_history(original_message, translated_message) do
    translation_history_attrs = %{
      original_message: original_message,
      translated_message: translated_message
    }

    create_translation_history(translation_history_attrs)
  end
end
