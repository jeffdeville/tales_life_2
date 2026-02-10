defmodule TalesLife2Web.InterviewLive.New do
  use TalesLife2Web, :live_view

  alias TalesLife2.Content
  alias TalesLife2.Interviews
  alias TalesLife2.Interviews.Interview

  @impl true
  def mount(_params, _session, socket) do
    eras = Content.list_eras()
    changeset = Interview.changeset(%Interview{}, %{})

    socket =
      socket
      |> assign(:page_title, "Start an Interview")
      |> assign(:eras, eras)
      |> assign(:form, to_form(changeset))

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"interview" => params}, socket) do
    changeset =
      %Interview{}
      |> Interview.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"interview" => params}, socket) do
    scope = socket.assigns.current_scope

    case Interviews.create_interview(scope, params) do
      {:ok, interview} ->
        {:noreply,
         socket
         |> put_flash(:info, "Interview started! Let's begin.")
         |> push_navigate(to: ~p"/interviews/#{interview}")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp era_label("early_life"), do: "Early Life"
  defp era_label("mid_life"), do: "Mid Life"
  defp era_label("later_life"), do: "Later Life"
  defp era_label(era), do: era

  defp era_description("early_life"), do: "Childhood, family origins, and growing up"
  defp era_description("mid_life"), do: "Career, relationships, and life lessons"
  defp era_description("later_life"), do: "Reflections, wisdom, and legacy"
  defp era_description(_), do: ""

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-xl mx-auto">
        <div class="text-center mb-8">
          <h1 class="text-3xl font-bold mb-2">Start a New Interview</h1>
          <p class="text-base-content/70">
            Capture someone's life story, one question at a time.
            There are no wrong answers — every memory matters.
          </p>
        </div>

        <.form for={@form} id="new-interview-form" phx-change="validate" phx-submit="save">
          <div class="mb-6">
            <.input
              field={@form[:subject_name]}
              type="text"
              label="Who are you interviewing?"
              placeholder="e.g., Grandma Rose, Uncle Jim"
              required
            />
            <p class="text-sm text-base-content/50 mt-1">
              Enter the name of the person whose story you're capturing.
            </p>
          </div>

          <div class="mb-6">
            <span class="label mb-2">Which life eras would you like to explore?</span>
            <p class="text-sm text-base-content/50 mb-3">
              Select one or more eras, or leave all unchecked to include every question.
            </p>
            <div class="space-y-3">
              <label
                :for={era <- @eras}
                class="flex items-start gap-3 p-3 rounded-lg border border-base-300 cursor-pointer hover:bg-base-200/50 transition-colors"
              >
                <input
                  type="checkbox"
                  name="interview[selected_eras][]"
                  value={era}
                  checked={era in (@form[:selected_eras].value || [])}
                  class="checkbox checkbox-sm mt-0.5"
                />
                <div>
                  <span class="font-medium">{era_label(era)}</span>
                  <p class="text-sm text-base-content/60">{era_description(era)}</p>
                </div>
              </label>
            </div>
          </div>

          <div class="bg-base-200/50 rounded-lg p-4 mb-6">
            <p class="text-sm text-base-content/70">
              <.icon name="hero-light-bulb" class="size-4 inline mr-1" />
              <strong>Tip:</strong> Find a quiet, comfortable place. Let the conversation flow
              naturally — you can skip any question and come back to it later.
            </p>
          </div>

          <div class="flex justify-end">
            <.button type="submit" variant="primary" phx-disable-with="Starting...">
              Begin Interview
            </.button>
          </div>
        </.form>
      </div>
    </Layouts.app>
    """
  end
end
