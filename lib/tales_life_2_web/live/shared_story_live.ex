defmodule TalesLife2Web.SharedStoryLive do
  use TalesLife2Web, :live_view

  alias TalesLife2.Sharing

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    case fetch_interview(token) do
      {:ok, interview} ->
        grouped_responses = group_responses_by_era_and_category(interview.responses)

        socket =
          socket
          |> assign(:page_title, "#{interview.subject_name}'s Stories")
          |> assign(:interview, interview)
          |> assign(:grouped_responses, grouped_responses)

        {:ok, socket}

      :error ->
        {:ok,
         socket
         |> put_flash(:error, "This shared story link is invalid or has been removed.")
         |> push_navigate(to: ~p"/")}
    end
  end

  defp fetch_interview(token) do
    {:ok, Sharing.get_interview_by_share_token!(token)}
  rescue
    Ecto.NoResultsError -> :error
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

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-2xl mx-auto" id="shared-story">
        <%!-- Story header --%>
        <div class="mb-8 pb-6 border-b border-base-300/60" id="shared-story-header">
          <p class="text-xs uppercase tracking-widest text-base-content/40 mb-2">
            Shared via TalesLife
          </p>
          <h1 class="text-3xl font-bold mb-1" style="font-family: var(--tl-font-serif);">
            {@interview.subject_name}
          </h1>
          <p class="text-base-content/50 text-sm">
            Interview recorded {format_date(@interview.inserted_at)}
          </p>
        </div>

        <%!-- Story content --%>
        <%= if @grouped_responses == [] do %>
          <div class="text-center py-12" id="shared-no-responses">
            <p class="text-base-content/50">This story doesn't have any responses yet.</p>
          </div>
        <% else %>
          <div class="space-y-10" id="shared-story-content">
            <section :for={{era, categories} <- @grouped_responses} id={"shared-era-#{era}"}>
              <div class="mb-6">
                <h2
                  class="text-2xl font-bold tracking-tight border-b-2 border-primary/20 pb-2"
                  style="font-family: var(--tl-font-serif);"
                >
                  {era_label(era)}
                </h2>
              </div>

              <div class="space-y-8">
                <div
                  :for={{category, responses} <- categories}
                  id={"shared-category-#{era}-#{category}"}
                >
                  <h3 class="text-lg font-semibold text-base-content/70 mb-4 uppercase tracking-wide text-sm">
                    {category_label(category)}
                  </h3>

                  <div class="space-y-6">
                    <article
                      :for={response <- responses}
                      class="pl-5 border-l-2 border-primary/30"
                      id={"shared-response-#{response.id}"}
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

        <%!-- CTA footer --%>
        <div class="mt-12 pt-8 border-t border-base-300/60 text-center" id="shared-cta">
          <p class="text-sm text-base-content/50 mb-3">
            Preserve your family's stories for generations to come.
          </p>
          <.link
            navigate={~p"/"}
            class="inline-flex items-center gap-2 px-5 py-2.5 bg-primary text-primary-content rounded-lg text-sm font-medium hover:opacity-90 transition-opacity"
            id="btn-create-own"
          >
            Start Your Own Interviews
          </.link>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
