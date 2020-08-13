defmodule SocketTranslatorPhx.Workers.TokenWorker do
  use GenServer

  def start_link(init_args) do
    GenServer.start_link(__MODULE__, [init_args], name: __MODULE__)
  end

  def init(_args) do
    # обновляем токен каждый час, в соответстии с докой
    :timer.send_interval(1000 * 60 * 60, :refresh_token)
    token = create_new_token()

    {:ok, %{token: token}}
  end

  def handle_info(:refresh_token, state) do
    token = create_new_token()

    {:noreply, %{state | token: token}}
  end

  def handle_call(:get_token, _from, %{token: token} = state) do
    {:reply, token, state}
  end

  def get_token() do
    GenServer.call(__MODULE__, :get_token)
  end

  defp create_new_token() do
    {token, 0} = System.cmd("yc", ~w(iam create-token))

    token
    |> String.trim()
  end

end
