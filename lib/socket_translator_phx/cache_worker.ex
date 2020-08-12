defmodule SocketTranslatorPhx.CacheWorker do
  use GenServer

  defstruct [
    :ets_ref
  ]

  def start_link(args) do
    # you may want to register your server with `name: __MODULE__`
    # as a third argument to `start_link`
    GenServer.start_link(__MODULE__, [args], name: __MODULE__)
  end

  def init(_args) do
    :timer.send_interval(1000, :expire_cache)

    ets_ref = :ets.new(:translator_cache, [:set])

    {:ok, %__MODULE__{ets_ref: ets_ref}}
  end

  def handle_info(:expire_cache, %__MODULE__{ets_ref: ets_ref} = state) do
    timestamp = get_current_timestamp()

    :ets.match_delete(ets_ref, {:_, :_, timestamp})
    {:noreply, state}
  end

  def handle_info({:put_to_cache, original_message, translated_message}, %__MODULE__{ets_ref: ets_ref} = state) do
    timestamp =
      get_time_to_live()
      |> get_timestamp_of_expiration()

    :ets.insert(ets_ref, {original_message, translated_message, timestamp})
    {:noreply, state}
  end

  def handle_call({:get_from_cache, original_message}, _from,  %__MODULE__{ets_ref: ets_ref} = state) do
    translated_message =
      case :ets.lookup(ets_ref, original_message) do
        [] -> nil
        [{_original_message, translated_message, _timestamp}] -> translated_message
      end

    {:reply, translated_message, state}
  end

  @spec get_translated_message_from_cache(String.t()) :: String.t() | nil
  def get_translated_message_from_cache(original_message) do
    GenServer.call(__MODULE__, {:get_from_cache, original_message})
  end

  @spec get_timestamp_of_expiration(non_neg_integer()) :: pos_integer()
  defp get_timestamp_of_expiration(time_to_live) do
    Timex.now()
    |> Timex.shift(seconds: time_to_live)
    |> Timex.to_unix()
  end

  @spec get_current_timestamp() :: pos_integer()
  defp get_current_timestamp() do
    Timex.now()
    |> Timex.to_unix()
  end

  @spec get_time_to_live() :: non_neg_integer()
  defp get_time_to_live() do
    Application.get_env(:socket_translator_phx, __MODULE__)[:time_to_live]
  end
end