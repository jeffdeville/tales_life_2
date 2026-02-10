defmodule TalesLife2Web.InterviewLive.Show do
  use TalesLife2Web, :live_view

  alias TalesLife2.Interviews
  alias TalesLife2.Transcription

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    interview = Interviews.get_interview!(id)

    if interview.user_id != socket.assigns.current_scope.user.id do
      {:ok,
       socket
       |> put_flash(:error, "You don't have access to this interview.")
       |> push_navigate(to: ~p"/")}
    else
      questions = Interviews.list_questions_for_interview(interview)
      interview = Interviews.get_interview_with_responses!(id)
      responses_map = build_responses_map(interview.responses)
      progress = Interviews.get_interview_progress(interview)

      socket =
        socket
        |> assign(:page_title, "Interview — #{interview.subject_name}")
        |> assign(:interview, interview)
        |> assign(:questions, questions)
        |> assign(:responses_map, responses_map)
        |> assign(:current_index, 0)
        |> assign(:progress, progress)
        |> assign(:auto_save_timer, nil)
        |> assign(:recording_state, :idle)
        |> assign_current_question_form(questions, responses_map, 0)

      {:ok, socket}
    end
  end

  @impl true
  def handle_event("navigate", %{"direction" => direction}, socket) do
    socket = maybe_save_current_response(socket)
    new_index = compute_new_index(socket, direction)
    questions = socket.assigns.questions
    responses_map = socket.assigns.responses_map

    socket =
      socket
      |> assign(:current_index, new_index)
      |> assign_current_question_form(questions, responses_map, new_index)

    {:noreply, socket}
  end

  def handle_event("update_response", %{"response" => %{"text_content" => text}}, socket) do
    question = current_question(socket)

    socket =
      socket
      |> update_local_response(question.id, text)
      |> schedule_auto_save()

    {:noreply, socket}
  end

  def handle_event("save_response", %{"response" => %{"text_content" => text}}, socket) do
    socket = save_response(socket, text)
    {:noreply, socket}
  end

  def handle_event("auto_save", _params, socket) do
    question = current_question(socket)
    text = Map.get(socket.assigns.responses_map, question.id, "")
    socket = if text != "", do: save_response(socket, text), else: socket
    {:noreply, assign(socket, :auto_save_timer, nil)}
  end

  def handle_event("recording_started", _params, socket) do
    {:noreply, assign(socket, :recording_state, :recording)}
  end

  def handle_event("audio_recorded", %{"audio" => base64_audio}, socket) do
    socket = assign(socket, :recording_state, :transcribing)

    task =
      Task.async(fn ->
        case Base.decode64(base64_audio) do
          {:ok, audio_binary} -> Transcription.transcribe(audio_binary)
          :error -> {:error, :invalid_audio}
        end
      end)

    {:noreply, assign(socket, :transcription_task, task)}
  end

  def handle_event("audio_error", %{"error" => error}, socket) do
    {:noreply,
     socket
     |> assign(:recording_state, :idle)
     |> put_flash(:error, error)}
  end

  def handle_event("complete_interview", _params, socket) do
    socket = maybe_save_current_response(socket)

    case Interviews.complete_interview(socket.assigns.interview) do
      {:ok, interview} ->
        {:noreply,
         socket
         |> assign(:interview, interview)
         |> put_flash(:info, "Interview completed! The stories have been saved.")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not complete the interview.")}
    end
  end

  @impl true
  def handle_info(:auto_save, socket) do
    question = current_question(socket)
    text = Map.get(socket.assigns.responses_map, question.id, "")
    socket = if text != "", do: save_response(socket, text), else: socket
    {:noreply, assign(socket, :auto_save_timer, nil)}
  end

  def handle_info({ref, result}, socket) when is_reference(ref) do
    Process.demonitor(ref, [:flush])

    case result do
      {:ok, text} ->
        question = current_question(socket)
        existing = Map.get(socket.assigns.responses_map, question.id, "")

        new_text =
          if existing == "",
            do: text,
            else: existing <> " " <> text

        socket =
          socket
          |> assign(:recording_state, :idle)
          |> update_local_response(question.id, new_text)
          |> assign_current_question_form(
            socket.assigns.questions,
            Map.put(socket.assigns.responses_map, question.id, new_text),
            socket.assigns.current_index
          )
          |> push_event("transcription_result", %{text: new_text})

        socket = save_response(socket, new_text)
        {:noreply, socket}

      {:error, reason} ->
        message =
          case reason do
            :invalid_audio -> "Invalid audio data"
            :test_error -> "Transcription failed"
            _ -> "Transcription failed. Please try again."
          end

        {:noreply,
         socket
         |> assign(:recording_state, :idle)
         |> push_event("transcription_error", %{error: message})
         |> put_flash(:error, message)}
    end
  end

  def handle_info({:DOWN, _ref, :process, _pid, _reason}, socket) do
    {:noreply,
     socket
     |> assign(:recording_state, :idle)
     |> put_flash(:error, "Transcription failed unexpectedly.")}
  end

  defp save_response(socket, text) do
    question = current_question(socket)
    interview = socket.assigns.interview

    text = String.trim(text)

    if text == "" do
      socket
    else
      case Interviews.save_response(interview, %{
             text_content: text,
             question_id: question.id
           }) do
        {:ok, _response} ->
          progress = Interviews.get_interview_progress(interview)

          socket
          |> update_local_response(question.id, text)
          |> assign(:progress, progress)

        {:error, _changeset} ->
          put_flash(socket, :error, "Could not save response.")
      end
    end
  end

  defp maybe_save_current_response(socket) do
    question = current_question(socket)
    text = Map.get(socket.assigns.responses_map, question.id, "")

    if text != "" do
      save_response(socket, text)
    else
      socket
    end
  end

  defp schedule_auto_save(socket) do
    if socket.assigns.auto_save_timer do
      Process.cancel_timer(socket.assigns.auto_save_timer)
    end

    timer = Process.send_after(self(), :auto_save, 2000)
    assign(socket, :auto_save_timer, timer)
  end

  defp compute_new_index(socket, direction) do
    current = socket.assigns.current_index
    max_index = length(socket.assigns.questions) - 1

    case direction do
      "next" -> min(current + 1, max_index)
      "previous" -> max(current - 1, 0)
      "skip" -> min(current + 1, max_index)
    end
  end

  defp current_question(socket) do
    Enum.at(socket.assigns.questions, socket.assigns.current_index)
  end

  defp build_responses_map(responses) do
    Map.new(responses, fn r -> {r.question_id, r.text_content} end)
  end

  defp update_local_response(socket, question_id, text) do
    responses_map = Map.put(socket.assigns.responses_map, question_id, text)
    assign(socket, :responses_map, responses_map)
  end

  defp assign_current_question_form(socket, questions, responses_map, index) do
    case Enum.at(questions, index) do
      nil ->
        assign(socket, :response_form, nil)

      question ->
        existing_text = Map.get(responses_map, question.id, "")

        form =
          %{"text_content" => existing_text}
          |> to_form(as: "response")

        assign(socket, :response_form, form)
    end
  end

  defp recording_button_classes(:idle),
    do: "bg-base-200 text-base-content/70 hover:bg-base-300"

  defp recording_button_classes(:recording),
    do: "bg-error/10 text-error border border-error/30"

  defp recording_button_classes(:transcribing),
    do: "bg-base-200 text-base-content/50 cursor-wait"

  defp recording_aria_label(:idle), do: "Start voice recording"
  defp recording_aria_label(:recording), do: "Stop voice recording"
  defp recording_aria_label(:transcribing), do: "Transcription in progress"

  defp era_label("early_life"), do: "Early Life"
  defp era_label("mid_life"), do: "Mid Life"
  defp era_label("later_life"), do: "Later Life"
  defp era_label(era), do: era

  defp progress_percent(%{total_questions: 0}), do: 0

  defp progress_percent(%{total_questions: total, answered_questions: answered}) do
    round(answered / total * 100)
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> assign(:question, Enum.at(assigns.questions, assigns.current_index))
      |> assign(:total, length(assigns.questions))

    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-2xl mx-auto" id="interview-show">
        <%!-- Header with subject name and progress --%>
        <div class="mb-8">
          <div class="flex items-center justify-between mb-3">
            <h1 class="text-xl font-bold" style="font-family: var(--tl-font-serif);">
              Interview with {@interview.subject_name}
            </h1>
            <span class="text-sm text-base-content/60" id="progress-text">
              {@progress.answered_questions} of {@progress.total_questions} answered
            </span>
          </div>

          <%!-- Progress bar --%>
          <div class="w-full bg-base-300/60 rounded-full h-2.5" id="progress-bar">
            <div
              class="bg-primary h-2.5 rounded-full transition-all duration-300"
              style={"width: #{progress_percent(@progress)}%"}
            >
            </div>
          </div>
        </div>

        <%= if @interview.status == "completed" do %>
          <div class="text-center py-12">
            <.icon name="hero-check-circle" class="size-16 text-success mx-auto mb-4" />
            <h2 class="text-2xl font-bold mb-2" style="font-family: var(--tl-font-serif);">
              Interview Complete
            </h2>
            <p class="text-base-content/70 mb-6 leading-relaxed">
              You've captured {@progress.answered_questions} responses.
              These stories are now saved.
            </p>
            <.button navigate={~p"/stories"}>View My Stories</.button>
          </div>
        <% else %>
          <%= if @question do %>
            <%!-- Era and category indicator --%>
            <div class="flex items-center gap-2 mb-4 text-sm text-base-content/50" id="question-meta">
              <span class="px-2 py-0.5 bg-base-200 rounded-md">{era_label(@question.era)}</span>
              <span>&middot;</span>
              <span class="capitalize">{@question.category}</span>
              <span class="ml-auto">
                Question {@current_index + 1} of {@total}
              </span>
            </div>

            <%!-- Question display --%>
            <div
              class="mb-6 bg-base-100 rounded-xl p-6 border border-base-300/50 shadow-sm"
              id={"question-#{@question.id}"}
            >
              <p
                class="text-2xl leading-relaxed font-medium mb-2"
                style="font-family: var(--tl-font-serif);"
              >
                {@question.prompt_text}
              </p>
              <p :if={@question.interviewing_tip} class="text-sm text-base-content/50 italic mt-3">
                <.icon name="hero-light-bulb" class="size-4 inline mr-1" />
                {@question.interviewing_tip}
              </p>
            </div>

            <%!-- Response area --%>
            <.form
              for={@response_form}
              id="response-form"
              phx-change="update_response"
              phx-submit="save_response"
            >
              <.input
                field={@response_form[:text_content]}
                type="textarea"
                placeholder="Take your time — there are no wrong answers..."
                rows="6"
                class="w-full textarea textarea-bordered text-base leading-relaxed"
                phx-debounce="500"
              />

              <div class="flex items-center justify-between mt-2" data-recording-container>
                <p class="text-xs text-base-content/40">
                  Responses are saved automatically as you type.
                </p>

                <div class="inline-flex items-center gap-2">
                  <span
                    :if={@recording_state == :recording}
                    data-audio-level
                    class="tl-audio-level inline-block w-2 h-6 rounded-full bg-error/30"
                  >
                  </span>
                  <span
                    :if={@recording_state == :recording}
                    data-recording-timer
                    id="recording-timer"
                    class="text-xs tabular-nums text-error font-medium"
                  >
                    0:00
                  </span>

                  <button
                    type="button"
                    id="record-button"
                    phx-hook="AudioRecorder"
                    aria-label={recording_aria_label(@recording_state)}
                    disabled={@recording_state == :transcribing}
                    class={[
                      "tl-record-btn inline-flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium transition-all",
                      recording_button_classes(@recording_state)
                    ]}
                  >
                    <span
                      :if={@recording_state == :idle}
                      class="inline-flex items-center gap-2"
                    >
                      <.icon name="hero-microphone" class="size-5" />
                      <span>Record</span>
                    </span>
                    <span
                      :if={@recording_state == :recording}
                      class="inline-flex items-center gap-2"
                    >
                      <span class="tl-recording-dot"></span>
                      <span>Stop</span>
                    </span>
                    <span
                      :if={@recording_state == :transcribing}
                      class="inline-flex items-center gap-2"
                    >
                      <span class="tl-spinner"></span>
                      <span>Transcribing…</span>
                    </span>
                  </button>
                </div>
              </div>
            </.form>

            <%!-- Navigation --%>
            <div class="flex items-center justify-between mt-6" id="question-nav">
              <button
                phx-click="navigate"
                phx-value-direction="previous"
                disabled={@current_index == 0}
                class={[
                  "btn btn-ghost rounded-lg",
                  @current_index == 0 && "btn-disabled"
                ]}
                id="btn-previous"
              >
                <.icon name="hero-arrow-left" class="size-4" /> Previous
              </button>

              <button
                phx-click="navigate"
                phx-value-direction="skip"
                disabled={@current_index >= @total - 1}
                class={[
                  "btn btn-ghost text-base-content/60 rounded-lg",
                  @current_index >= @total - 1 && "btn-disabled"
                ]}
                id="btn-skip"
              >
                Skip
              </button>

              <%= if @current_index >= @total - 1 do %>
                <button
                  phx-click="complete_interview"
                  class="btn btn-primary rounded-lg"
                  id="btn-complete"
                  data-confirm="Are you sure you want to finish this interview? You can always come back to add more."
                >
                  Finish Interview
                </button>
              <% else %>
                <button
                  phx-click="navigate"
                  phx-value-direction="next"
                  class="btn btn-primary rounded-lg"
                  id="btn-next"
                >
                  Next <.icon name="hero-arrow-right" class="size-4" />
                </button>
              <% end %>
            </div>

            <%!-- Encouraging micro-copy --%>
            <div
              class="text-center mt-10 text-sm text-base-content/40 italic"
              style="font-family: var(--tl-font-serif);"
            >
              <p>Every story matters. Take your time.</p>
            </div>
          <% else %>
            <div class="text-center py-12">
              <p class="text-base-content/70">No questions available for this interview.</p>
            </div>
          <% end %>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
