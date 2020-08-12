defmodule SocketTranslatorPhxWeb.PageController do
  use SocketTranslatorPhxWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
