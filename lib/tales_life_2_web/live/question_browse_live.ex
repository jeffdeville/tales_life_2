defmodule TalesLife2Web.QuestionBrowseLive do
  use TalesLife2Web, :live_view

  alias TalesLife2.Content

  @era_metadata %{
    "early_life" => %{
      title: "Early Life",
      description:
        "Childhood memories, family stories, school days, and the experiences that shaped who you became.",
      icon: "hero-sun",
      bg_class: "bg-amber-50",
      border_class: "border-amber-200/70",
      accent_class: "text-amber-900",
      badge_class: "bg-amber-100 text-amber-800"
    },
    "mid_life" => %{
      title: "Mid Life",
      description:
        "Career journeys, love and relationships, parenting, challenges overcome, and life's turning points.",
      icon: "hero-heart",
      bg_class: "bg-rose-50",
      border_class: "border-rose-200/70",
      accent_class: "text-rose-900",
      badge_class: "bg-rose-100 text-rose-800"
    },
    "later_life" => %{
      title: "Later Life and Reflections",
      description:
        "Hard-won wisdom, life reflections, legacy and meaning, advice for future generations.",
      icon: "hero-star",
      bg_class: "bg-stone-50",
      border_class: "border-stone-300/70",
      accent_class: "text-stone-800",
      badge_class: "bg-stone-100 text-stone-700"
    }
  }

  @era_order ["early_life", "mid_life", "later_life"]

  @impl true
  def mount(_params, _session, socket) do
    eras = Content.list_eras()

    era_data =
      Enum.map(@era_order, fn era_key ->
        if era_key in eras do
          questions = Content.list_questions_by_era(era_key)
          categories = questions |> Enum.group_by(& &1.category)
          meta = Map.get(@era_metadata, era_key)

          %{
            key: era_key,
            meta: meta,
            question_count: length(questions),
            categories: categories
          }
        end
      end)
      |> Enum.reject(&is_nil/1)

    {:ok,
     assign(socket,
       page_title: "Browse Questions",
       era_data: era_data,
       expanded_era: nil,
       expanded_category: nil
     )}
  end

  @impl true
  def handle_event("toggle_era", %{"era" => era}, socket) do
    new_era = if socket.assigns.expanded_era == era, do: nil, else: era

    {:noreply,
     assign(socket,
       expanded_era: new_era,
       expanded_category: nil
     )}
  end

  @impl true
  def handle_event("toggle_category", %{"category" => category}, socket) do
    new_category = if socket.assigns.expanded_category == category, do: nil, else: category
    {:noreply, assign(socket, expanded_category: new_category)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="space-y-6">
        <div class="text-center mb-8">
          <h1
            class="text-3xl font-bold tracking-tight sm:text-4xl"
            style="font-family: var(--tl-font-serif);"
          >
            Interview Questions
          </h1>
          <p class="mt-3 text-lg text-base-content/70 leading-relaxed">
            Explore questions organized by life era to guide meaningful conversations.
          </p>
        </div>

        <div class="space-y-4" id="era-list">
          <div :for={era <- @era_data} id={"era-#{era.key}"}>
            <button
              id={"era-btn-#{era.key}"}
              phx-click="toggle_era"
              phx-value-era={era.key}
              class={[
                "w-full text-left rounded-xl border-2 p-5 sm:p-6 transition-all duration-200 cursor-pointer",
                "hover:shadow-md",
                era.meta.border_class,
                era.meta.bg_class
              ]}
            >
              <div class="flex items-start justify-between gap-4">
                <div class="flex items-start gap-3 sm:gap-4 min-w-0">
                  <div class={["shrink-0 mt-1", era.meta.accent_class]}>
                    <.icon name={era.meta.icon} class="size-7 sm:size-8" />
                  </div>
                  <div class="min-w-0">
                    <h2 class={["text-xl sm:text-2xl font-semibold", era.meta.accent_class]}>
                      {era.meta.title}
                    </h2>
                    <p class="mt-1 text-base text-base-content/60 leading-relaxed">
                      {era.meta.description}
                    </p>
                  </div>
                </div>
                <div class="flex items-center gap-3 shrink-0">
                  <span class={[
                    "inline-flex items-center rounded-full px-3 py-1 text-sm font-medium",
                    era.meta.badge_class
                  ]}>
                    {era.question_count} questions
                  </span>
                  <span class={[
                    "hero-chevron-down size-5 transition-transform duration-200",
                    era.meta.accent_class,
                    @expanded_era == era.key && "rotate-180"
                  ]} />
                </div>
              </div>
            </button>

            <div
              :if={@expanded_era == era.key}
              id={"era-content-#{era.key}"}
              class="mt-2 space-y-2 pl-2 sm:pl-4"
            >
              <div
                :for={{category, questions} <- era.categories}
                id={"category-#{era.key}-#{category}"}
              >
                <button
                  id={"category-btn-#{era.key}-#{category}"}
                  phx-click="toggle_category"
                  phx-value-category={"#{era.key}:#{category}"}
                  class={[
                    "w-full text-left rounded-lg border p-4 transition-all duration-200 cursor-pointer",
                    "hover:shadow-sm",
                    era.meta.border_class,
                    "bg-base-100"
                  ]}
                >
                  <div class="flex items-center justify-between">
                    <div class="flex items-center gap-2">
                      <h3 class={["text-lg font-medium", era.meta.accent_class]}>
                        {format_category(category)}
                      </h3>
                      <span class="text-sm text-base-content/50">
                        ({length(questions)})
                      </span>
                    </div>
                    <span class={[
                      "hero-chevron-down size-4 transition-transform duration-200 text-base-content/40",
                      @expanded_category == "#{era.key}:#{category}" && "rotate-180"
                    ]} />
                  </div>
                </button>

                <ul
                  :if={@expanded_category == "#{era.key}:#{category}"}
                  id={"questions-#{era.key}-#{category}"}
                  class="mt-1 space-y-1 pl-4"
                >
                  <li
                    :for={question <- questions}
                    id={"question-#{question.id}"}
                    class="rounded-lg border border-base-200 bg-base-100 p-4"
                  >
                    <p class="text-base leading-relaxed">
                      {question.prompt_text}
                    </p>
                    <p
                      :if={question.interviewing_tip}
                      class="mt-2 text-sm text-base-content/60 italic"
                    >
                      <.icon
                        name="hero-light-bulb"
                        class="size-4 inline-block mr-1 align-text-bottom"
                      />
                      {question.interviewing_tip}
                    </p>
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp format_category(category) do
    category
    |> String.replace("_", " ")
    |> String.split(" ")
    |> Enum.map_join(" ", &String.capitalize/1)
  end
end
