defmodule TalesLife2.TranscriptionTest do
  use ExUnit.Case, async: true

  alias TalesLife2.Transcription
  alias TalesLife2.Transcription.TextCleanup
  alias TalesLife2.Transcription.TestProvider

  describe "transcribe/2" do
    test "returns cleaned text with test provider" do
      assert {:ok, text} = Transcription.transcribe("audio data", provider: TestProvider)
      refute text =~ "um"
      refute text =~ "you know"
      refute text =~ "basically"
      assert text =~ "test transcription"
    end

    test "returns raw text when skip_cleanup is true" do
      assert {:ok, text} =
               Transcription.transcribe("audio data", provider: TestProvider, skip_cleanup: true)

      assert text =~ "um"
      assert text =~ "you know"
      assert text =~ "basically"
    end

    test "returns error from provider" do
      assert {:error, :test_error} =
               Transcription.transcribe("error_audio", provider: TestProvider)
    end

    test "uses configured provider by default" do
      # In test env, the configured provider is TestProvider
      assert {:ok, _text} = Transcription.transcribe("audio data")
    end
  end

  describe "TextCleanup.clean/1" do
    test "removes common filler words" do
      assert TextCleanup.clean("I um went to the uh store") == "I went to the store"
    end

    test "removes filler phrases" do
      assert TextCleanup.clean("I you know went to basically the store") == "I went to the store"
    end

    test "removes multiple filler words" do
      assert TextCleanup.clean("So um I uh went er there") == "So I went there"
    end

    test "handles filler words with commas" do
      assert TextCleanup.clean("Well, um, I think so") == "Well, I think so"
    end

    test "handles backtracking patterns" do
      assert TextCleanup.clean("I went to the, I went to the store") == "I went to the store"
    end

    test "handles backtracking with dashes" do
      assert TextCleanup.clean("I went to -- I went to the store") == "I went to the store"
    end

    test "normalizes multiple spaces" do
      assert TextCleanup.clean("I  went   to  the  store") == "I went to the store"
    end

    test "normalizes punctuation spacing" do
      assert TextCleanup.clean("I went to the store .") == "I went to the store."
    end

    test "handles empty string" do
      assert TextCleanup.clean("") == ""
    end

    test "handles string with only filler words" do
      result = TextCleanup.clean("um uh er")
      assert result == ""
    end

    test "preserves meaningful text" do
      input = "I really enjoyed my time growing up in that small town."
      assert TextCleanup.clean(input) == input
    end

    test "case insensitive filler removal" do
      assert TextCleanup.clean("I Um went to the Uh store") == "I went to the store"
    end
  end

  describe "TestProvider" do
    test "returns transcript for normal input" do
      assert {:ok, text} = TestProvider.transcribe("any audio", [])
      assert is_binary(text)
    end

    test "returns error for error-prefixed input" do
      assert {:error, :test_error} = TestProvider.transcribe("error_data", [])
    end
  end
end
