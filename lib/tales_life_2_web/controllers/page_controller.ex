defmodule TalesLife2Web.PageController do
  use TalesLife2Web, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
