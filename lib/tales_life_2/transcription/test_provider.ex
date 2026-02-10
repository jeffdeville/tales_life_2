defmodule TalesLife2.Transcription.TestProvider do
  @moduledoc """
  Test/mock provider for transcription. Returns predictable results
  for testing without calling external APIs.
  """

  @behaviour TalesLife2.Transcription.Provider

  @impl true
  def transcribe(<<"error">> <> _, _opts) do
    {:error, :test_error}
  end

  def transcribe(audio_binary, _opts) when is_binary(audio_binary) do
    {:ok, "This is um a test transcription you know with some filler words basically."}
  end
end
