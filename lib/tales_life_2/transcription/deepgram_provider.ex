defmodule TalesLife2.Transcription.DeepgramProvider do
  @moduledoc """
  Deepgram speech-to-text provider implementation.
  """

  @behaviour TalesLife2.Transcription.Provider

  @impl true
  def transcribe(audio_binary, _opts) do
    api_key = Application.fetch_env!(:tales_life_2, :deepgram_api_key)

    case Req.post("https://api.deepgram.com/v1/listen",
           body: audio_binary,
           headers: [
             {"authorization", "Token #{api_key}"},
             {"content-type", "audio/webm"}
           ],
           params: [model: "nova-2", smart_format: true]
         ) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        extract_transcript(body)

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, "Deepgram API returned status #{status}: #{inspect(body)}"}

      {:error, reason} ->
        {:error, "Deepgram API request failed: #{inspect(reason)}"}
    end
  end

  defp extract_transcript(%{"results" => %{"channels" => [channel | _]}}) do
    case channel do
      %{"alternatives" => [%{"transcript" => transcript} | _]} when transcript != "" ->
        {:ok, transcript}

      _ ->
        {:error, :no_transcript}
    end
  end

  defp extract_transcript(_body) do
    {:error, :unexpected_response_format}
  end
end
