defmodule TalesLife2.SharingTest do
  use TalesLife2.DataCase, async: true

  alias TalesLife2.Sharing

  import TalesLife2.AccountsFixtures
  import TalesLife2.ContentFixtures
  import TalesLife2.InterviewsFixtures

  describe "create_shared_link/1" do
    test "creates a shared link with a random token" do
      scope = user_scope_fixture()
      interview = interview_fixture(scope)

      assert {:ok, shared_link} = Sharing.create_shared_link(interview)
      assert shared_link.token != nil
      assert String.length(shared_link.token) > 0
      assert shared_link.interview_id == interview.id
    end

    test "generates unique tokens for different links" do
      scope = user_scope_fixture()
      interview1 = interview_fixture(scope)
      interview2 = interview_fixture(scope)

      {:ok, link1} = Sharing.create_shared_link(interview1)
      {:ok, link2} = Sharing.create_shared_link(interview2)

      assert link1.token != link2.token
    end
  end

  describe "get_interview_by_share_token!/1" do
    test "returns the interview with responses preloaded" do
      scope = user_scope_fixture()
      interview = interview_fixture(scope)
      question = question_fixture()

      TalesLife2.Interviews.save_response(interview, %{
        text_content: "A cherished memory.",
        question_id: question.id
      })

      {:ok, shared_link} = Sharing.create_shared_link(interview)

      loaded = Sharing.get_interview_by_share_token!(shared_link.token)
      assert loaded.id == interview.id
      assert length(loaded.responses) == 1
      assert hd(loaded.responses).question.id == question.id
    end

    test "raises when token does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Sharing.get_interview_by_share_token!("nonexistent_token")
      end
    end
  end
end
