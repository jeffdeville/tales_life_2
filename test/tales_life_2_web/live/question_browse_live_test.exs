defmodule TalesLife2Web.QuestionBrowseLiveTest do
  use TalesLife2Web.ConnCase, async: true

  import Phoenix.LiveViewTest
  import TalesLife2.ContentFixtures

  describe "GET /questions (unauthenticated)" do
    test "redirects to login page", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/questions")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert flash["error"] == "You must log in to access this page."
    end
  end

  describe "GET /questions (authenticated)" do
    setup :register_and_log_in_user

    test "renders the page with heading", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/questions")
      assert html =~ "Interview Questions"
      assert html =~ "Explore questions organized by life era"
    end

    test "displays all three eras with question counts", %{conn: conn} do
      question_fixture(%{era: "early_life", category: "childhood"})
      question_fixture(%{era: "early_life", category: "family"})
      question_fixture(%{era: "mid_life", category: "career"})
      question_fixture(%{era: "later_life", category: "wisdom"})

      {:ok, _lv, html} = live(conn, ~p"/questions")

      assert html =~ "Early Life"
      assert html =~ "Mid Life"
      assert html =~ "Later Life and Reflections"
      assert html =~ "2 questions"
      assert html =~ "1 questions"
    end

    test "expanding an era shows its categories", %{conn: conn} do
      question_fixture(%{era: "early_life", category: "childhood", prompt_text: "Test question"})

      {:ok, lv, _html} = live(conn, ~p"/questions")

      refute has_element?(lv, "#category-btn-early_life-childhood")

      lv |> element("#era-btn-early_life") |> render_click()

      assert has_element?(lv, "#category-btn-early_life-childhood")
    end

    test "expanding a category shows its questions", %{conn: conn} do
      question_fixture(%{
        era: "early_life",
        category: "childhood",
        prompt_text: "What is your earliest memory?"
      })

      {:ok, lv, _html} = live(conn, ~p"/questions")

      lv |> element("#era-btn-early_life") |> render_click()
      html = lv |> element("#category-btn-early_life-childhood") |> render_click()

      assert html =~ "What is your earliest memory?"
    end

    test "shows interviewing tips when present", %{conn: conn} do
      question_fixture(%{
        era: "early_life",
        category: "childhood",
        prompt_text: "Test question",
        interviewing_tip: "Be patient and gentle."
      })

      {:ok, lv, _html} = live(conn, ~p"/questions")

      lv |> element("#era-btn-early_life") |> render_click()
      html = lv |> element("#category-btn-early_life-childhood") |> render_click()

      assert html =~ "Be patient and gentle."
    end

    test "collapsing an era hides categories", %{conn: conn} do
      question_fixture(%{era: "early_life", category: "childhood"})

      {:ok, lv, _html} = live(conn, ~p"/questions")

      lv |> element("#era-btn-early_life") |> render_click()
      assert has_element?(lv, "#category-btn-early_life-childhood")

      lv |> element("#era-btn-early_life") |> render_click()
      refute has_element?(lv, "#category-btn-early_life-childhood")
    end

    test "renders page with no questions gracefully", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/questions")
      assert html =~ "Interview Questions"
    end
  end
end
