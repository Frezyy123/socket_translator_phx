defmodule SocketTranslatorPhx.Workers.CacheWorker do
  use GenServer

  defstruct [
    :ets_ref,
    :time_to_live
  ]

  def start_link(args) do
    GenServer.start_link(__MODULE__, [args], name: __MODULE__)
  end

  def init(_args) do
    :timer.send_interval(1000, :expire_cache)

    ets_ref = :ets.new(:translator_cache, [:set])
    time_to_live = get_time_to_live()
    {:ok, %__MODULE__{ets_ref: ets_ref, time_to_live: time_to_live}}
  end

  def handle_info(:expire_cache, %__MODULE__{ets_ref: ets_ref} = state) do
    timestamp = get_current_timestamp()

    :ets.match_delete(ets_ref, {:_, :_, timestamp})
    {:noreply, state}
  end

  def handle_info({:put_to_cache, original_message, translated_message}, %__MODULE__{ets_ref: ets_ref, time_to_live: time_to_live} = state) do
    timestamp = get_timestamp_of_expiration(time_to_live)

    :ets.insert(ets_ref, {original_message, translated_message, timestamp})
    {:noreply, state}
  end

  def handle_call({:get_from_cache, original_message}, _from, %__MODULE__{ets_ref: ets_ref} = state) do
    translated_message =
      case :ets.lookup(ets_ref, original_message) do
        [] ->
          nil
        [{_original_message, translated_message, _timestamp}] ->
           translated_message
      end

    {:reply, translated_message, state}
  end

  @spec get_translated_message_from_cache(String.t()) :: String.t() | nil
  def get_translated_message_from_cache(original_message) do
    GenServer.call(__MODULE__, {:get_from_cache, original_message})
  end

  @spec put_message_to_cache(String.t(), String.t()) :: :ok
  def put_message_to_cache(translated_message, original_message) do
    send(__MODULE__, {:put_to_cache, original_message, translated_message})
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
