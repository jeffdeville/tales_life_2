defmodule TalesLife2Web.SharedStoryLiveTest do
  use TalesLife2Web.ConnCase, async: true

  import Phoenix.LiveViewTest
  import TalesLife2.AccountsFixtures
  import TalesLife2.ContentFixtures
  import TalesLife2.InterviewsFixtures

  alias TalesLife2.Sharing

  describe "SharedStoryLive" do
    setup do
      scope = user_scope_fixture()

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

      TalesLife2.Interviews.save_response(interview, %{
        question_id: q1.id,
        text_content: "I remember the garden in summer."
      })

      TalesLife2.Interviews.save_response(interview, %{
        question_id: q2.id,
        text_content: "I worked at the bakery."
      })

      {:ok, shared_link} = Sharing.create_shared_link(interview)

      %{interview: interview, shared_link: shared_link, scope: scope}
    end

    test "renders shared story without authentication", %{shared_link: shared_link} do
      conn = build_conn()
      {:ok, _view, html} = live(conn, ~p"/shared/#{shared_link.token}")

      assert html =~ "Grandma Rose"
      assert html =~ "Shared via TalesLife"
    end

    test "displays responses organized by era", %{shared_link: shared_link} do
      conn = build_conn()
      {:ok, view, html} = live(conn, ~p"/shared/#{shared_link.token}")

      assert html =~ "Early Life"
      assert html =~ "Mid Life"
      assert html =~ "I remember the garden in summer."
      assert html =~ "I worked at the bakery."
      assert has_element?(view, "#shared-era-early_life")
      assert has_element?(view, "#shared-era-mid_life")
    end

    test "shows CTA to create own interviews", %{shared_link: shared_link} do
      conn = build_conn()
      {:ok, view, html} = live(conn, ~p"/shared/#{shared_link.token}")

      assert html =~ "Start Your Own Interviews"
      assert has_element?(view, "#btn-create-own")
    end

    test "redirects with error for invalid token" do
      conn = build_conn()

      assert {:error, {:live_redirect, %{to: "/", flash: %{"error" => message}}}} =
               live(conn, ~p"/shared/invalid-token-here")

      assert message =~ "invalid or has been removed"
    end

    test "works for authenticated users too", %{shared_link: shared_link, scope: scope} do
      user = scope.user
      conn = build_conn() |> log_in_user(user)
      {:ok, _view, html} = live(conn, ~p"/shared/#{shared_link.token}")
      assert html =~ "Grandma Rose"
    end
  end
end
