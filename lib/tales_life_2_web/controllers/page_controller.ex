defmodule TalesLife2Web.PageController do
  use TalesLife2Web, :controller

  def home(conn, _params) do
    if conn.assigns.current_scope do
      redirect(conn, to: ~p"/stories")
    else
      render(conn, :home)
    end
  end
end
