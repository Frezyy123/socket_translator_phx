defmodule SocketTranslatorPhx.Repo.Migrations.CreateTranslationHistory do
  use Ecto.Migration

  def change do
    create table(:translation_histories) do
      add :original_message, :string, size: 280
      add :translated_message, :string, size: 280

      timestamps()
    end
  end
end
