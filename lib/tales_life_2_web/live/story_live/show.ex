defmodule TalesLife2Web.StoryLive.Show do
  use TalesLife2Web, :live_view

  alias TalesLife2.Interviews
  alias TalesLife2.Sharing

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    interview = Interviews.get_interview_with_responses!(id)

    if interview.user_id != socket.assigns.current_scope.user.id do
      {:ok,
       socket
       |> put_flash(:error, "You don't have access to this story.")
       |> push_navigate(to: ~p"/stories")}
    else
      grouped_responses = group_responses_by_era_and_category(interview.responses)
      progress = Interviews.get_interview_progress(interview)

      socket =
        socket
        |> assign(:page_title, "#{interview.subject_name}'s Stories")
        |> assign(:interview, interview)
        |> assign(:grouped_responses, grouped_responses)
        |> assign(:progress, progress)
        |> assign(:share_url, nil)

      {:ok, socket}
    end
  end

  @impl true
  def handle_event("generate_share_link", _params, socket) do
    interview = socket.assigns.interview

    case Sharing.create_shared_link(interview) do
      {:ok, shared_link} ->
        share_url = url(~p"/shared/#{shared_link.token}")
        {:noreply, assign(socket, :share_url, share_url)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not generate share link.")}
    end
  end

  def handle_event("close_share_modal", _params, socket) do
    {:noreply, assign(socket, :share_url, nil)}
  end

  defp group_responses_by_era_and_category(responses) do
    era_order = %{"early_life" => 0, "mid_life" => 1, "later_life" => 2}

    responses
    |> Enum.sort_by(fn r ->
      {Map.get(era_order, r.question.era, 99), r.question.category, r.question.position}
    end)
    |> Enum.group_by(fn r -> r.question.era end)
    |> Enum.sort_by(fn {era, _} -> Map.get(era_order, era, 99) end)
    |> Enum.map(fn {era, responses} ->
      categories =
        responses
        |> Enum.group_by(fn r -> r.question.category end)
        |> Enum.sort_by(fn {_cat, rs} ->
          rs |> List.first() |> then(& &1.question.position)
        end)

      {era, categories}
    end)
  end

  defp era_label("early_life"), do: "Early Life"
  defp era_label("mid_life"), do: "Mid Life"
  defp era_label("later_life"), do: "Later Life"
  defp era_label(era), do: era

  defp category_label(category) do
    category
    |> String.replace("_", " ")
    |> String.split()
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  defp format_date(datetime) do
    Calendar.strftime(datetime, "%B %d, %Y")
  end

  defp progress_percent(%{total_questions: 0}), do: 0

  defp progress_percent(%{total_questions: total, answered_questions: answered}) do
    round(answered / total * 100)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-2xl mx-auto" id="story-show">
        <%!-- Back link --%>
        <.link
          navigate={~p"/stories"}
          class="inline-flex items-center gap-1 text-sm text-base-content/50 hover:text-base-content mb-6"
        >
          <.icon name="hero-arrow-left" class="size-4" /> Back to Stories
        </.link>

        <%!-- Story header --%>
        <div class="mb-8 pb-6 border-b border-base-300/60" id="story-header">
          <h1 class="text-3xl font-bold mb-1" style="font-family: var(--tl-font-serif);">
            {@interview.subject_name}
          </h1>
          <p class="text-base-content/50 text-sm mb-4">
            Interview started {format_date(@interview.inserted_at)}
          </p>

          <div class="flex items-center gap-4">
            <span class={[
              "px-3 py-1 rounded-full text-xs font-medium",
              @interview.status == "completed" && "bg-success/10 text-success",
              @interview.status == "in_progress" && "bg-warning/10 text-warning"
            ]}>
              {if @interview.status == "completed", do: "Completed", else: "In Progress"}
            </span>
            <span class="text-sm text-base-content/50">
              {@progress.answered_questions} of {@progress.total_questions} responses ({progress_percent(
                @progress
              )}%)
            </span>
          </div>

          <%!-- Action buttons --%>
          <div class="flex gap-3 mt-4" id="story-actions">
            <.link
              :if={@interview.status == "in_progress"}
              navigate={~p"/interviews/#{@interview}"}
              class="inline-flex items-center gap-2 px-4 py-2 bg-primary text-primary-content rounded-lg text-sm font-medium hover:opacity-90 transition-opacity"
              id="btn-continue"
            >
              <.icon name="hero-pencil" class="size-4" /> Continue Interview
            </.link>
            <button
              :if={@interview.status == "completed"}
              class="inline-flex items-center gap-2 px-4 py-2 bg-base-200 text-base-content rounded-lg text-sm font-medium hover:bg-base-300 transition-colors"
              id="btn-share"
              phx-click="generate_share_link"
            >
              <.icon name="hero-share" class="size-4" /> Share
            </button>
          </div>
        </div>

        <%!-- Share modal --%>
        <div
          :if={@share_url}
          class="fixed inset-0 z-50 flex items-center justify-center bg-black/50"
          id="share-modal"
          phx-click="close_share_modal"
        >
          <div
            class="bg-base-100 rounded-xl shadow-xl p-6 max-w-md w-full mx-4"
            phx-click-away="close_share_modal"
            id="share-modal-content"
          >
            <div class="flex items-center justify-between mb-4">
              <h2 class="text-lg font-bold" style="font-family: var(--tl-font-serif);">
                Share this story
              </h2>
              <button
                phx-click="close_share_modal"
                class="text-base-content/50 hover:text-base-content"
                id="btn-close-share"
              >
                <.icon name="hero-x-mark" class="size-5" />
              </button>
            </div>
            <p class="text-sm text-base-content/60 mb-4">
              Anyone with this link can read {@interview.subject_name}'s stories without signing in.
            </p>
            <div class="flex items-center gap-2">
              <input
                type="text"
                value={@share_url}
                readonly
                class="flex-1 px-3 py-2 border border-base-300 rounded-lg text-sm bg-base-200 select-all"
                id="share-url-input"
              />
              <button
                id="btn-copy-link"
                phx-hook="CopyToClipboard"
                data-clipboard-text={@share_url}
                class="px-4 py-2 bg-primary text-primary-content rounded-lg text-sm font-medium hover:opacity-90 transition-opacity whitespace-nowrap"
              >
                Copy Link
              </button>
            </div>
          </div>
        </div>

        <%!-- Story content --%>
        <%= if @grouped_responses == [] do %>
          <div class="text-center py-12" id="no-responses">
            <.icon name="hero-pencil-square" class="size-12 text-base-content/20 mx-auto mb-4" />
            <h2 class="text-lg font-semibold text-base-content/70 mb-2">No responses yet</h2>
            <p class="text-base-content/50 mb-4">
              This interview hasn't captured any stories yet. Continue the interview to start recording.
            </p>
            <.link
              navigate={~p"/interviews/#{@interview}"}
              class="inline-flex items-center gap-2 px-4 py-2 bg-primary text-primary-content rounded-lg text-sm font-medium hover:opacity-90 transition-opacity"
            >
              <.icon name="hero-microphone" class="size-4" /> Start Recording
            </.link>
          </div>
        <% else %>
          <div class="space-y-10" id="story-content">
            <section :for={{era, categories} <- @grouped_responses} id={"era-#{era}"}>
              <%!-- Era header --%>
              <div class="mb-6">
                <h2
                  class="text-2xl font-bold tracking-tight border-b-2 border-primary/20 pb-2"
                  style="font-family: var(--tl-font-serif);"
                >
                  {era_label(era)}
                </h2>
              </div>

              <div class="space-y-8">
                <div :for={{category, responses} <- categories} id={"category-#{era}-#{category}"}>
                  <%!-- Category header --%>
                  <h3 class="text-lg font-semibold text-base-content/70 mb-4 uppercase tracking-wide text-sm">
                    {category_label(category)}
                  </h3>

                  <%!-- Responses --%>
                  <div class="space-y-6">
                    <article
                      :for={response <- responses}
                      class="pl-5 border-l-2 border-primary/30"
                      id={"response-#{response.id}"}
                    >
                      <p class="text-sm font-medium text-base-content/60 italic mb-2">
                        {response.question.prompt_text}
                      </p>
                      <p class="text-base leading-relaxed whitespace-pre-wrap">
                        {response.text_content}
                      </p>
                    </article>
                  </div>
                </div>
              </div>
            </section>
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
