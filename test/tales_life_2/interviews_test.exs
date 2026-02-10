defmodule TalesLife2.InterviewsTest do
  use TalesLife2.DataCase, async: true

  alias TalesLife2.Interviews

  import TalesLife2.AccountsFixtures
  import TalesLife2.ContentFixtures
  import TalesLife2.InterviewsFixtures

  describe "create_interview/2" do
    test "creates an interview for the user" do
      scope = user_scope_fixture()

      assert {:ok, interview} =
               Interviews.create_interview(scope, %{subject_name: "Grandma Rose"})

      assert interview.subject_name == "Grandma Rose"
      assert interview.status == "in_progress"
      assert interview.user_id == scope.user.id
    end

    test "returns error changeset with invalid data" do
      scope = user_scope_fixture()
      assert {:error, changeset} = Interviews.create_interview(scope, %{subject_name: ""})
      assert %{subject_name: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "get_interview!/1" do
    test "returns the interview" do
      scope = user_scope_fixture()
      interview = interview_fixture(scope)
      assert Interviews.get_interview!(interview.id).id == interview.id
    end

    test "raises when not found" do
      assert_raise Ecto.NoResultsError, fn ->
        Interviews.get_interview!(0)
      end
    end
  end

  describe "list_interviews_for_user/1" do
    test "returns interviews for the user's scope" do
      scope = user_scope_fixture()
      interview = interview_fixture(scope)

      other_scope = user_scope_fixture()
      _other_interview = interview_fixture(other_scope)

      interviews = Interviews.list_interviews_for_user(scope)
      assert length(interviews) == 1
      assert hd(interviews).id == interview.id
    end
  end

  describe "list_completed_interviews_for_user/1" do
    test "returns only completed interviews" do
      scope = user_scope_fixture()
      in_progress = interview_fixture(scope)
      completed = interview_fixture(scope)
      {:ok, completed} = Interviews.complete_interview(completed)

      interviews = Interviews.list_completed_interviews_for_user(scope)
      ids = Enum.map(interviews, & &1.id)

      assert completed.id in ids
      refute in_progress.id in ids
    end
  end

  describe "get_interview_with_responses!/1" do
    test "returns the interview with preloaded responses and questions" do
      scope = user_scope_fixture()
      interview = interview_fixture(scope)
      question = question_fixture()

      {:ok, _response} =
        Interviews.save_response(interview, %{
          text_content: "I remember the garden.",
          question_id: question.id
        })

      loaded = Interviews.get_interview_with_responses!(interview.id)
      assert length(loaded.responses) == 1
      assert hd(loaded.responses).question.id == question.id
    end
  end

  describe "save_response/2" do
    test "creates a new response" do
      scope = user_scope_fixture()
      interview = interview_fixture(scope)
      question = question_fixture()

      assert {:ok, response} =
               Interviews.save_response(interview, %{
                 text_content: "I remember sunny days.",
                 question_id: question.id
               })

      assert response.text_content == "I remember sunny days."
      assert response.interview_id == interview.id
      assert response.question_id == question.id
    end

    test "updates an existing response for the same question" do
      scope = user_scope_fixture()
      interview = interview_fixture(scope)
      question = question_fixture()

      {:ok, first} =
        Interviews.save_response(interview, %{
          text_content: "First answer",
          question_id: question.id
        })

      {:ok, updated} =
        Interviews.save_response(interview, %{
          text_content: "Updated answer",
          question_id: question.id
        })

      assert updated.id == first.id
      assert updated.text_content == "Updated answer"
    end

    test "returns error with missing text_content" do
      scope = user_scope_fixture()
      interview = interview_fixture(scope)
      question = question_fixture()

      assert {:error, changeset} =
               Interviews.save_response(interview, %{
                 text_content: "",
                 question_id: question.id
               })

      assert %{text_content: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "complete_interview/1" do
    test "marks interview as completed" do
      scope = user_scope_fixture()
      interview = interview_fixture(scope)

      assert {:ok, completed} = Interviews.complete_interview(interview)
      assert completed.status == "completed"
    end
  end

  describe "get_interview_progress/1" do
    test "returns progress with counts" do
      scope = user_scope_fixture()
      interview = interview_fixture(scope)
      q1 = question_fixture(%{position: 1})
      q2 = question_fixture(%{position: 2})
      _q3 = question_fixture(%{position: 3})

      Interviews.save_response(interview, %{text_content: "Answer 1", question_id: q1.id})
      Interviews.save_response(interview, %{text_content: "Answer 2", question_id: q2.id})

      progress = Interviews.get_interview_progress(interview)
      assert progress.answered_questions == 2
      assert progress.total_questions == 3
    end
  end
end
