defmodule TalesLife2Web.InterviewLiveTest do
  use TalesLife2Web.ConnCase, async: true

  import Phoenix.LiveViewTest
  import TalesLife2.AccountsFixtures
  import TalesLife2.ContentFixtures
  import TalesLife2.InterviewsFixtures

  setup :register_and_log_in_user

  describe "InterviewLive.New" do
    test "renders new interview form", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/interviews/new")
      assert html =~ "Start a New Interview"
      assert html =~ "Who are you interviewing?"
      assert has_element?(view, "#new-interview-form")
    end

    test "validates form on change", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/interviews/new")

      result =
        view
        |> form("#new-interview-form", interview: %{subject_name: ""})
        |> render_change()

      assert result =~ "can&#39;t be blank"
    end

    test "creates interview and redirects", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/interviews/new")

      view
      |> form("#new-interview-form", interview: %{subject_name: "Grandma Rose"})
      |> render_submit()

      assert {path, _flash} = assert_redirect(view)
      assert path =~ ~r"/interviews/\d+"
    end

    test "shows era checkboxes when eras exist", %{conn: conn} do
      question_fixture(%{era: "early_life"})
      question_fixture(%{era: "mid_life"})

      {:ok, _view, html} = live(conn, ~p"/interviews/new")
      assert html =~ "Early Life"
      assert html =~ "Mid Life"
    end

    test "redirects to login when not authenticated" do
      conn = build_conn()
      assert {:error, redirect} = live(conn, ~p"/interviews/new")
      assert {:redirect, %{to: path}} = redirect
      assert path =~ "/users/log-in"
    end
  end

  describe "InterviewLive.Show" do
    setup %{scope: scope} do
      q1 =
        question_fixture(%{
          era: "early_life",
          category: "childhood",
          position: 1,
          prompt_text: "What is your earliest memory?"
        })

      q2 =
        question_fixture(%{
          era: "early_life",
          category: "childhood",
          position: 2,
          prompt_text: "Where did you grow up?"
        })

      q3 =
        question_fixture(%{
          era: "mid_life",
          category: "career",
          position: 1,
          prompt_text: "What was your first job?"
        })

      interview = interview_fixture(scope, %{subject_name: "Grandma Rose"})

      %{interview: interview, questions: [q1, q2, q3]}
    end

    test "renders interview page with first question", %{conn: conn, interview: interview} do
      {:ok, _view, html} = live(conn, ~p"/interviews/#{interview}")
      assert html =~ "Interview with Grandma Rose"
      assert html =~ "What is your earliest memory?"
      assert html =~ "Question 1 of 3"
    end

    test "shows progress bar", %{conn: conn, interview: interview} do
      {:ok, view, _html} = live(conn, ~p"/interviews/#{interview}")
      assert has_element?(view, "#progress-bar")
      assert has_element?(view, "#progress-text")
    end

    test "navigates to next question", %{conn: conn, interview: interview} do
      {:ok, view, _html} = live(conn, ~p"/interviews/#{interview}")

      html = view |> element("#btn-next") |> render_click()

      assert html =~ "Where did you grow up?"
      assert html =~ "Question 2 of 3"
    end

    test "navigates to previous question", %{conn: conn, interview: interview} do
      {:ok, view, _html} = live(conn, ~p"/interviews/#{interview}")

      # Go to question 2
      view |> element("#btn-next") |> render_click()
      # Go back to question 1
      html = view |> element("#btn-previous") |> render_click()

      assert html =~ "What is your earliest memory?"
      assert html =~ "Question 1 of 3"
    end

    test "skips current question", %{conn: conn, interview: interview} do
      {:ok, view, _html} = live(conn, ~p"/interviews/#{interview}")

      html = view |> element("#btn-skip") |> render_click()

      assert html =~ "Where did you grow up?"
    end

    test "saves response via form submit", %{conn: conn, interview: interview} do
      {:ok, view, _html} = live(conn, ~p"/interviews/#{interview}")

      view
      |> form("#response-form", response: %{text_content: "I remember the garden."})
      |> render_submit()

      # Verify progress updated
      assert render(view) =~ "1 of 3 answered"
    end

    test "previous button is disabled on first question", %{conn: conn, interview: interview} do
      {:ok, view, _html} = live(conn, ~p"/interviews/#{interview}")
      assert has_element?(view, "#btn-previous[disabled]")
    end

    test "shows finish button on last question", %{conn: conn, interview: interview} do
      {:ok, view, _html} = live(conn, ~p"/interviews/#{interview}")

      # Navigate to last question
      view |> element("#btn-next") |> render_click()
      view |> element("#btn-next") |> render_click()

      assert has_element?(view, "#btn-complete")
    end

    test "completes the interview", %{conn: conn, interview: interview} do
      {:ok, view, _html} = live(conn, ~p"/interviews/#{interview}")

      # Navigate to last question
      view |> element("#btn-next") |> render_click()
      view |> element("#btn-next") |> render_click()

      html = view |> element("#btn-complete") |> render_click()

      assert html =~ "Interview Complete"
    end

    test "shows era and category labels", %{conn: conn, interview: interview} do
      {:ok, view, _html} = live(conn, ~p"/interviews/#{interview}")
      assert has_element?(view, "#question-meta")
      html = render(view)
      assert html =~ "Early Life"
      assert html =~ "childhood"
    end

    test "shows interviewing tip when present", %{conn: conn, interview: interview} do
      {:ok, _view, html} = live(conn, ~p"/interviews/#{interview}")
      assert html =~ "Be patient and gentle."
    end

    test "denies access to other user's interview", %{conn: conn} do
      other_scope = user_scope_fixture()
      other_interview = interview_fixture(other_scope)

      assert {:error, {:live_redirect, %{to: "/", flash: %{"error" => message}}}} =
               live(conn, ~p"/interviews/#{other_interview}")

      assert message =~ "You don't have access to this interview."
    end

    test "filters questions by selected eras", %{conn: conn, scope: scope} do
      interview =
        interview_fixture(scope, %{
          subject_name: "Test Subject",
          selected_eras: ["early_life"]
        })

      {:ok, _view, html} = live(conn, ~p"/interviews/#{interview}")
      assert html =~ "Question 1 of 2"
      refute html =~ "What was your first job?"
    end

    test "preserves responses when navigating", %{conn: conn, interview: interview} do
      {:ok, view, _html} = live(conn, ~p"/interviews/#{interview}")

      # Submit a response on question 1
      view
      |> form("#response-form", response: %{text_content: "I remember the garden."})
      |> render_submit()

      # Go to question 2 and back
      view |> element("#btn-next") |> render_click()
      view |> element("#btn-previous") |> render_click()

      html = render(view)
      assert html =~ "I remember the garden."
    end

    test "redirects to login when not authenticated" do
      conn = build_conn()
      assert {:error, redirect} = live(conn, ~p"/interviews/1")
      assert {:redirect, %{to: path}} = redirect
      assert path =~ "/users/log-in"
    end

    test "shows record button", %{conn: conn, interview: interview} do
      {:ok, view, _html} = live(conn, ~p"/interviews/#{interview}")
      assert has_element?(view, "#record-btn")
      assert has_element?(view, "#record-btn[aria-label='Start voice recording']")
    end

    test "toggle_recording updates recording state", %{conn: conn, interview: interview} do
      {:ok, view, _html} = live(conn, ~p"/interviews/#{interview}")

      html = view |> element("#record-btn") |> render_click()
      assert html =~ "Stop voice recording"
    end

    test "audio_recorded event triggers transcription and updates textarea", %{
      conn: conn,
      interview: interview
    } do
      {:ok, view, _html} = live(conn, ~p"/interviews/#{interview}")

      audio_base64 = Base.encode64("some audio data")
      render_click(view, "audio_recorded", %{"audio" => audio_base64})

      # Wait for async task to complete
      # The TestProvider returns a predictable transcript
      assert_push_event(view, "transcription_result", %{text: text})
      assert text =~ "test transcription"
    end

    test "audio_recorded appends to existing text", %{conn: conn, interview: interview} do
      {:ok, view, _html} = live(conn, ~p"/interviews/#{interview}")

      # First, type some text
      view
      |> form("#response-form", response: %{text_content: "Existing text."})
      |> render_change()

      audio_base64 = Base.encode64("some audio data")
      render_click(view, "audio_recorded", %{"audio" => audio_base64})

      assert_push_event(view, "transcription_result", %{text: text})
      assert text =~ "Existing text."
      assert text =~ "test transcription"
    end

    test "audio_recorded handles transcription error", %{conn: conn, interview: interview} do
      {:ok, view, _html} = live(conn, ~p"/interviews/#{interview}")

      # TestProvider returns error for audio starting with "error"
      audio_base64 = Base.encode64("error_audio")
      render_click(view, "audio_recorded", %{"audio" => audio_base64})

      assert_push_event(view, "transcription_error", %{error: _})
      assert render(view) =~ "Transcription failed"
    end

    test "audio_error event shows flash error", %{conn: conn, interview: interview} do
      {:ok, view, _html} = live(conn, ~p"/interviews/#{interview}")

      render_click(view, "audio_error", %{"error" => "Microphone permission denied"})

      assert render(view) =~ "Microphone permission denied"
    end

    test "transcribed text is auto-saved", %{conn: conn, interview: interview} do
      {:ok, view, _html} = live(conn, ~p"/interviews/#{interview}")

      audio_base64 = Base.encode64("some audio data")
      render_click(view, "audio_recorded", %{"audio" => audio_base64})

      # Wait for transcription
      assert_push_event(view, "transcription_result", %{text: _text})

      # Trigger auto-save by sending the timer message
      send(view.pid, :auto_save)

      # Verify progress updated (response was saved)
      html = render(view)
      assert html =~ "1 of 3 answered"
    end
  end
end
