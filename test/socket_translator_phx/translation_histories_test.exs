defmodule SocketTranlatorPhx.TranslationHistoriesTest do
  use ExUnit.Case

  alias SocketTranslatorPhx.TranslationHistories
  alias SocketTranslatorPhx.TranslationHistories.TranslationHistory
  alias SocketTranslatorPhx.Repo

  describe "CRUD tests" do
    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
      Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    end
    test "create and delete translation history" do
      translation_history_attrs = %{original_message: "original_message", translated_message: "translated_message"}
      {:ok, translation_history} = TranslationHistories.create_translation_history(translation_history_attrs)

      assert %TranslationHistory{original_message: "original_message", translated_message: "translated_message"} =
               Repo.get(TranslationHistory, translation_history.id)


      TranslationHistories.delete(translation_history)
      assert nil ==  Repo.get(TranslationHistory, translation_history.id)
    end

    test "update traslation history" do
      translation_history_attrs = %{original_message: "original_message", translated_message: "translated_message"}
      {:ok, translation_history} = TranslationHistories.create_translation_history(translation_history_attrs)

      upd_attrs = %{original_message: "another original message"}
      {:ok, updated_translation_history} = TranslationHistories.update_translation_history(translation_history, upd_attrs)

      assert %TranslationHistory{original_message: "another original message", translated_message: "translated_message"} =
               Repo.get(TranslationHistory, updated_translation_history.id)
    end
  end
end
