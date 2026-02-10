defmodule TalesLife2.ContentTest do
  use TalesLife2.DataCase, async: true

  alias TalesLife2.Content

  import TalesLife2.ContentFixtures

  describe "list_questions/0" do
    test "returns all questions ordered by era, category, position" do
      q1 = question_fixture(%{era: "early_life", category: "childhood", position: 1})
      q2 = question_fixture(%{era: "mid_life", category: "career", position: 1})
      q3 = question_fixture(%{era: "early_life", category: "family", position: 1})

      questions = Content.list_questions()
      ids = Enum.map(questions, & &1.id)

      assert q1.id in ids
      assert q2.id in ids
      assert q3.id in ids
    end

    test "returns empty list when no questions exist" do
      assert Content.list_questions() == []
    end
  end

  describe "list_questions_by_era/1" do
    test "returns only questions for the given era" do
      q1 = question_fixture(%{era: "early_life", category: "childhood", position: 1})
      _q2 = question_fixture(%{era: "mid_life", category: "career", position: 1})

      questions = Content.list_questions_by_era("early_life")
      ids = Enum.map(questions, & &1.id)

      assert q1.id in ids
      assert length(questions) == 1
    end

    test "returns empty list for era with no questions" do
      assert Content.list_questions_by_era("later_life") == []
    end
  end

  describe "get_question!/1" do
    test "returns the question with given id" do
      question = question_fixture()
      assert Content.get_question!(question.id).id == question.id
    end

    test "raises when question does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Content.get_question!(0)
      end
    end
  end

  describe "list_eras/0" do
    test "returns distinct eras" do
      question_fixture(%{era: "early_life", position: 1})
      question_fixture(%{era: "mid_life", position: 2})
      question_fixture(%{era: "early_life", position: 3})

      eras = Content.list_eras()
      assert "early_life" in eras
      assert "mid_life" in eras
      assert length(eras) == 2
    end
  end

  describe "list_categories_for_era/1" do
    test "returns distinct categories for the given era" do
      question_fixture(%{era: "early_life", category: "childhood", position: 1})
      question_fixture(%{era: "early_life", category: "family", position: 2})
      question_fixture(%{era: "early_life", category: "childhood", position: 3})
      question_fixture(%{era: "mid_life", category: "career", position: 1})

      categories = Content.list_categories_for_era("early_life")
      assert "childhood" in categories
      assert "family" in categories
      refute "career" in categories
      assert length(categories) == 2
    end
  end
end
