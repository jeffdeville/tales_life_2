defmodule TalesLife2Web.StoryLibraryLive do
  use TalesLife2Web, :live_view

  alias TalesLife2.Interviews

  @impl true
  def mount(_params, _session, socket) do
    interviews_with_progress =
      Interviews.list_interviews_with_progress(socket.assigns.current_scope)

    socket =
      socket
      |> assign(:page_title, "My Stories")
      |> assign(:filter, "all")
      |> assign(:all_interviews, interviews_with_progress)
      |> assign_filtered_interviews(interviews_with_progress, "all")

    {:ok, socket}
  end

  @impl true
  def handle_event("filter", %{"status" => status}, socket) do
    socket =
      socket
      |> assign(:filter, status)
      |> assign_filtered_interviews(socket.assigns.all_interviews, status)

    {:noreply, socket}
  end

  defp assign_filtered_interviews(socket, interviews, "all") do
    assign(socket, :interviews, interviews)
  end

  defp assign_filtered_interviews(socket, interviews, status) do
    filtered =
      Enum.filter(interviews, fn {interview, _progress} -> interview.status == status end)

    assign(socket, :interviews, filtered)
  end

  defp progress_percent(%{total_questions: 0}), do: 0

  defp progress_percent(%{total_questions: total, answered_questions: answered}) do
    round(answered / total * 100)
  end

  defp format_date(datetime) do
    Calendar.strftime(datetime, "%B %d, %Y")
  end

  defp era_label("early_life"), do: "Early Life"
  defp era_label("mid_life"), do: "Mid Life"
  defp era_label("later_life"), do: "Later Life"
  defp era_label(era), do: era

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-2xl mx-auto" id="story-library">
        <div class="flex items-center justify-between mb-8">
          <h1 class="text-3xl font-bold" style="font-family: var(--tl-font-serif);">My Stories</h1>
          <.link
            navigate={~p"/interviews/new"}
            class="inline-flex items-center gap-2 px-4 py-2.5 bg-primary text-primary-content rounded-lg font-medium hover:opacity-90 transition-opacity"
          >
            <.icon name="hero-plus" class="size-5" /> New Interview
          </.link>
        </div>

        <%!-- Filter tabs --%>
        <div class="flex gap-2 mb-6" id="story-filters">
          <button
            :for={
              {label, value} <- [
                {"All", "all"},
                {"In Progress", "in_progress"},
                {"Completed", "completed"}
              ]
            }
            phx-click="filter"
            phx-value-status={value}
            class={[
              "px-4 py-2 rounded-full text-sm font-medium transition-colors",
              @filter == value && "bg-primary text-primary-content",
              @filter != value && "bg-base-200 text-base-content/70 hover:bg-base-300"
            ]}
            id={"filter-#{value}"}
          >
            {label}
          </button>
        </div>

        <%!-- Interview list --%>
        <%= if @interviews == [] do %>
          <div class="text-center py-16" id="empty-state">
            <.icon name="hero-book-open" class="size-16 text-base-content/20 mx-auto mb-4" />
            <h2
              class="text-xl font-semibold mb-2 text-base-content/70"
              style="font-family: var(--tl-font-serif);"
            >
              No stories yet
            </h2>
            <p class="text-base-content/50 mb-6 max-w-md mx-auto leading-relaxed">
              Every family has stories worth preserving. Start an interview to capture the memories and wisdom of someone you love.
            </p>
            <.link
              navigate={~p"/interviews/new"}
              class="inline-flex items-center gap-2 px-6 py-3 bg-primary text-primary-content rounded-lg font-medium hover:opacity-90 transition-opacity"
            >
              <.icon name="hero-microphone" class="size-5" /> Start Your First Interview
            </.link>
          </div>
        <% else %>
          <div class="space-y-4" id="interview-list">
            <.link
              :for={{interview, progress} <- @interviews}
              navigate={~p"/stories/#{interview}"}
              class="block p-5 rounded-xl border border-base-300/60 bg-base-100 hover:border-primary/30 hover:shadow-md transition-all tl-card"
              id={"interview-#{interview.id}"}
            >
              <div class="flex items-start justify-between mb-3">
                <div>
                  <h3 class="text-lg font-semibold">{interview.subject_name}</h3>
                  <p class="text-sm text-base-content/50">{format_date(interview.inserted_at)}</p>
                </div>
                <span class={[
                  "px-3 py-1 rounded-full text-xs font-medium",
                  interview.status == "completed" && "bg-success/10 text-success",
                  interview.status == "in_progress" && "bg-warning/10 text-warning"
                ]}>
                  {if interview.status == "completed", do: "Completed", else: "In Progress"}
                </span>
              </div>

              <%!-- Era tags --%>
              <div :if={interview.selected_eras != []} class="flex gap-1 mb-3">
                <span
                  :for={era <- interview.selected_eras}
                  class="px-2 py-0.5 bg-base-200 rounded text-xs text-base-content/60"
                >
                  {era_label(era)}
                </span>
              </div>

              <%!-- Progress --%>
              <div class="flex items-center gap-3">
                <div class="flex-1 bg-base-200 rounded-full h-2">
                  <div
                    class={[
                      "h-2 rounded-full transition-all",
                      interview.status == "completed" && "bg-success",
                      interview.status != "completed" && "bg-primary"
                    ]}
                    style={"width: #{progress_percent(progress)}%"}
                  >
                  </div>
                </div>
                <span class="text-sm text-base-content/50 whitespace-nowrap">
                  {progress.answered_questions}/{progress.total_questions} responses
                </span>
              </div>
            </.link>
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
