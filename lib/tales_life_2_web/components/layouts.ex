defmodule TalesLife2Web.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use TalesLife2Web, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="w-full border-b border-base-content/10" id="app-header">
      <nav
        class="mx-auto flex max-w-5xl items-center justify-between px-4 py-3 sm:px-6 lg:px-8"
        id="app-nav"
      >
        <.link navigate={~p"/"} class="flex items-center gap-2" id="nav-logo">
          <span class="text-2xl" aria-hidden="true">&#x1f4d6;</span>
          <span class="text-lg font-semibold" style="font-family: var(--tl-font-serif);">
            TalesLife
          </span>
        </.link>

        <div class="flex items-center gap-1 sm:gap-3 text-sm">
          <%= if @current_scope do %>
            <.link
              navigate={~p"/stories"}
              class="rounded-lg px-3 py-2 font-medium transition-colors hover:bg-base-content/5"
              id="nav-stories"
            >
              My Stories
            </.link>
            <.link
              navigate={~p"/questions"}
              class="rounded-lg px-3 py-2 font-medium transition-colors hover:bg-base-content/5"
              id="nav-questions"
            >
              Questions
            </.link>
            <.link
              navigate={~p"/interviews/new"}
              class="rounded-lg px-3 py-2 font-medium transition-colors hover:bg-base-content/5"
              id="nav-new-interview"
            >
              New Interview
            </.link>

            <div class="hidden sm:block px-2 text-base-content/50">
              {@current_scope.user.email}
            </div>

            <.link
              href={~p"/users/settings"}
              class="rounded-lg px-3 py-2 transition-colors hover:bg-base-content/5"
              id="nav-settings"
            >
              <.icon name="hero-cog-6-tooth-mini" class="size-5" />
            </.link>
            <.link
              href={~p"/users/log-out"}
              method="delete"
              class="rounded-lg px-3 py-2 text-base-content/70 transition-colors hover:bg-base-content/5"
              id="nav-logout"
            >
              Log out
            </.link>
          <% else %>
            <.link
              href={~p"/users/register"}
              class="rounded-lg px-3 py-2 font-medium transition-colors hover:bg-base-content/5"
              id="nav-register"
            >
              Register
            </.link>
            <.link
              href={~p"/users/log-in"}
              class="rounded-lg bg-primary px-4 py-2 font-medium text-primary-content transition-opacity hover:opacity-90"
              id="nav-login"
            >
              Log in
            </.link>
          <% end %>

          <.theme_toggle />
        </div>
      </nav>
    </header>

    <main class="px-4 py-10 sm:px-6 sm:py-14 lg:px-8">
      <div class="mx-auto max-w-3xl">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div
      class="relative flex items-center rounded-full border border-base-content/15 bg-base-content/5"
      id="theme-toggle"
    >
      <div class="absolute h-full w-1/3 rounded-full bg-base-content/10 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex cursor-pointer p-2 w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex cursor-pointer p-2 w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex cursor-pointer p-2 w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
