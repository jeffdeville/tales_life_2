defmodule TalesLife2.Transcription.TextCleanup do
  @moduledoc """
  Post-processing pipeline for transcribed text.

  Removes filler words, cleans up backtracking patterns,
  and normalizes whitespace and punctuation.
  """

  @filler_words ~w(um uh uh-huh uhm hmm hm er ah eh)
  @filler_phrases [
    "you know",
    "i mean",
    "sort of",
    "kind of",
    "basically",
    "literally",
    "actually"
  ]

  @doc """
  Cleans transcribed text by removing filler words, backtracking,
  and normalizing whitespace and punctuation.
  """
  def clean(text) when is_binary(text) do
    text
    |> remove_backtracking()
    |> remove_filler_phrases()
    |> remove_filler_words()
    |> normalize_whitespace()
    |> normalize_punctuation()
    |> String.trim()
  end

  defp remove_backtracking(text) do
    # Pattern: "I went to the, I went to the store" -> "I went to the store"
    # Handles "word word, word word rest" where the repeated part is removed
    text
    |> String.replace(~r/(\b\w+(?:\s+\w+){0,4}),?\s+\1\b/i, "\\1")
    |> String.replace(~r/(\b\w+(?:\s+\w+){0,4})\s*--\s*\1\b/i, "\\1")
  end

  defp remove_filler_phrases(text) do
    Enum.reduce(@filler_phrases, text, fn phrase, acc ->
      pattern = ~r/\b#{Regex.escape(phrase)},?\s*/i
      String.replace(acc, pattern, "")
    end)
  end

  defp remove_filler_words(text) do
    Enum.reduce(@filler_words, text, fn word, acc ->
      pattern = ~r/\b#{Regex.escape(word)}\b,?\s*/i
      String.replace(acc, pattern, "")
    end)
  end

  defp normalize_whitespace(text) do
    text
    |> String.replace(~r/\s{2,}/, " ")
    |> String.replace(~r/\s+([.,!?;:])/, "\\1")
  end

  defp normalize_punctuation(text) do
    text
    |> String.replace(~r/([.!?])\s*([.!?])+/, "\\1")
    |> String.replace(~r/,\s*,+/, ",")
    |> String.replace(~r/^\s*[,.]/, "")
  end
end
