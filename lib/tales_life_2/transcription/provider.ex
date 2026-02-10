defmodule TalesLife2.Transcription.Provider do
  @moduledoc """
  Behaviour for speech-to-text transcription providers.
  """

  @callback transcribe(audio_binary :: binary(), opts :: keyword()) ::
              {:ok, String.t()} | {:error, term()}
end
