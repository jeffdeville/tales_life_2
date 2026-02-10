defmodule TalesLife2Web.StoryLiveTest do
  use TalesLife2Web.ConnCase, async: true

  import Phoenix.LiveViewTest
  import TalesLife2.AccountsFixtures
  import TalesLife2.ContentFixtures
  import TalesLife2.InterviewsFixtures

  setup :register_and_log_in_user

  describe "StoryLibraryLive" do
    test "renders empty state when no interviews exist", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/stories")
      assert html =~ "My Stories"
      assert has_element?(view, "#empty-state")
      assert html =~ "No stories yet"
      assert html =~ "Start Your First Interview"
    end

    test "lists user interviews", %{conn: conn, scope: scope} do
      interview_fixture(scope, %{subject_name: "Grandma Rose"})
      interview_fixture(scope, %{subject_name: "Uncle Bob"})

      {:ok, view, html} = live(conn, ~p"/stories")
      assert html =~ "Grandma Rose"
      assert html =~ "Uncle Bob"
      refute has_element?(view, "#empty-state")
    end

    test "shows interview status", %{conn: conn, scope: scope} do
      interview = interview_fixture(scope, %{subject_name: "Grandma Rose"})
      {:ok, _interview} = TalesLife2.Interviews.complete_interview(interview)

      {:ok, _view, html} = live(conn, ~p"/stories")
      assert html =~ "Completed"
    end

    test "filters by status", %{conn: conn, scope: scope} do
      interview_fixture(scope, %{subject_name: "In Progress Person"})
      completed = interview_fixture(scope, %{subject_name: "Done Person"})
      {:ok, _interview} = TalesLife2.Interviews.complete_interview(completed)

      {:ok, view, _html} = live(conn, ~p"/stories")

      # Filter to completed only
      html =
        view
        |> element("#filter-completed")
        |> render_click()

      assert html =~ "Done Person"
      refute html =~ "In Progress Person"

      # Filter to in_progress only
      html =
        view
        |> element("#filter-in_progress")
        |> render_click()

      assert html =~ "In Progress Person"
      refute html =~ "Done Person"

      # Show all
      html =
        view
        |> element("#filter-all")
        |> render_click()

      assert html =~ "In Progress Person"
      assert html =~ "Done Person"
    end

    test "does not show other users' interviews", %{conn: conn} do
      other_scope = user_scope_fixture()
      interview_fixture(other_scope, %{subject_name: "Secret Person"})

      {:ok, _view, html} = live(conn, ~p"/stories")
      refute html =~ "Secret Person"
    end

    test "links to individual story", %{conn: conn, scope: scope} do
      interview = interview_fixture(scope, %{subject_name: "Grandma Rose"})

      {:ok, view, _html} = live(conn, ~p"/stories")
      assert has_element?(view, "#interview-#{interview.id}")
    end

    test "redirects to login when not authenticated" do
      conn = build_conn()
      assert {:error, redirect} = live(conn, ~p"/stories")
      assert {:redirect, %{to: path}} = redirect
      assert path =~ "/users/log-in"
    end
  end

  describe "StoryLive.Show" do
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
          era: "mid_life",
          category: "career",
          position: 1,
          prompt_text: "What was your first job?"
        })

      interview = interview_fixture(scope, %{subject_name: "Grandma Rose"})

      %{interview: interview, questions: [q1, q2]}
    end

    test "renders story page with interview details", %{conn: conn, interview: interview} do
      {:ok, _view, html} = live(conn, ~p"/stories/#{interview}")
      assert html =~ "Grandma Rose"
      assert html =~ "Back to Stories"
    end

    test "shows no responses state when interview has no responses", %{
      conn: conn,
      interview: interview
    } do
      {:ok, view, _html} = live(conn, ~p"/stories/#{interview}")
      assert has_element?(view, "#no-responses")
    end

    test "displays responses organized by era and category", %{
      conn: conn,
      interview: interview,
      questions: [q1, q2]
    } do
      TalesLife2.Interviews.save_response(interview, %{
        question_id: q1.id,
        text_content: "I remember the garden in summer."
      })

      TalesLife2.Interviews.save_response(interview, %{
        question_id: q2.id,
        text_content: "I worked at the bakery."
      })

      {:ok, view, html} = live(conn, ~p"/stories/#{interview}")

      assert html =~ "Early Life"
      assert html =~ "Mid Life"
      assert html =~ "I remember the garden in summer."
      assert html =~ "I worked at the bakery."
      assert has_element?(view, "#era-early_life")
      assert has_element?(view, "#era-mid_life")
    end

    test "shows continue button for in-progress interviews", %{conn: conn, interview: interview} do
      {:ok, view, _html} = live(conn, ~p"/stories/#{interview}")
      assert has_element?(view, "#btn-continue")
    end

    test "shows share button for completed interviews", %{conn: conn, interview: interview} do
      {:ok, _interview} = TalesLife2.Interviews.complete_interview(interview)

      {:ok, view, _html} = live(conn, ~p"/stories/#{interview}")
      assert has_element?(view, "#btn-share")
      refute has_element?(view, "#btn-continue")
    end

    test "denies access to other user's story", %{conn: conn} do
      other_scope = user_scope_fixture()
      other_interview = interview_fixture(other_scope)

      assert {:error, {:live_redirect, %{to: "/stories", flash: %{"error" => message}}}} =
               live(conn, ~p"/stories/#{other_interview}")

      assert message =~ "You don't have access to this story."
    end

    test "redirects to login when not authenticated" do
      conn = build_conn()
      assert {:error, redirect} = live(conn, ~p"/stories/1")
      assert {:redirect, %{to: path}} = redirect
      assert path =~ "/users/log-in"
    end

    test "shows story header with status and progress", %{conn: conn, interview: interview} do
      {:ok, view, html} = live(conn, ~p"/stories/#{interview}")
      assert has_element?(view, "#story-header")
      assert html =~ "In Progress"
    end
  end
end
