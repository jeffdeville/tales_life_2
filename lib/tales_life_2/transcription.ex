defmodule TalesLife2.Transcription do
  @moduledoc """
  The Transcription context handles speech-to-text conversion
  and post-processing of transcribed text.
  """

  alias TalesLife2.Transcription.TextCleanup

  @doc """
  Transcribes audio binary to cleaned text.

  Uses the configured provider to convert audio to text, then
  applies text cleanup to remove filler words and backtracking.

  ## Options

    * `:skip_cleanup` - when `true`, returns the raw transcript
      without post-processing. Defaults to `false`.
    * `:provider` - override the configured provider module.

  ## Examples

      iex> Transcription.transcribe(audio_binary)
      {:ok, "cleaned transcription text"}

      iex> Transcription.transcribe(audio_binary, skip_cleanup: true)
      {:ok, "raw transcription text with um filler words"}

  """
  def transcribe(audio_binary, opts \\ []) do
    provider = Keyword.get(opts, :provider, provider())

    case provider.transcribe(audio_binary, opts) do
      {:ok, raw_text} ->
        if Keyword.get(opts, :skip_cleanup, false) do
          {:ok, raw_text}
        else
          {:ok, TextCleanup.clean(raw_text)}
        end

      {:error, _reason} = error ->
        error
    end
  end

  defp provider do
    Application.get_env(
      :tales_life_2,
      :transcription_provider,
      TalesLife2.Transcription.DeepgramProvider
    )
  end
end
