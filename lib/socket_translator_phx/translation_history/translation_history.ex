defmodule SocketTranslatorPhx.TranslationHistories.TranslationHistory do
  alias __MODULE__
  use Ecto.Schema
  import Ecto.Changeset

  @cast_fields [:original_message, :translated_message]

  @required_fields @cast_fields
  schema "translation_histories" do
    field :original_message, :string
    field :translated_message, :string

    timestamps()
  end

  def changeset(%TranslationHistory{} = translation_history, attrs) do
    translation_history
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
  end
end
