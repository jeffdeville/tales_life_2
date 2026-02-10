defmodule TalesLife2Web.UserSessionHTML do
  use TalesLife2Web, :html

  embed_templates "user_session_html/*"

  defp local_mail_adapter? do
    Application.get_env(:tales_life_2, TalesLife2.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end
