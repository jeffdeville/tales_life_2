const AudioRecorder = {
  mounted() {
    this.recording = false
    this.mediaRecorder = null
    this.audioChunks = []
    this.stream = null

    this.el.addEventListener("click", () => {
      if (this.recording) {
        this.stopRecording()
      } else {
        this.startRecording()
      }
    })

    this.handleEvent("transcription_result", ({text}) => {
      this.el.dispatchEvent(new CustomEvent("transcription-result", {
        detail: {text},
        bubbles: true
      }))
    })

    this.handleEvent("transcription_error", ({error}) => {
      this.el.dispatchEvent(new CustomEvent("transcription-error", {
        detail: {error},
        bubbles: true
      }))
    })
  },

  startRecording() {
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      console.error("AudioRecorder: getUserMedia not supported")
      this.pushEvent("audio_error", {error: "Browser does not support audio recording"})
      return
    }

    navigator.mediaDevices.getUserMedia({audio: true})
      .then(stream => {
        this.stream = stream

        const mimeType = MediaRecorder.isTypeSupported("audio/webm;codecs=opus")
          ? "audio/webm;codecs=opus"
          : "audio/webm"

        this.mediaRecorder = new MediaRecorder(stream, {mimeType})
        this.audioChunks = []

        this.mediaRecorder.addEventListener("dataavailable", (event) => {
          if (event.data.size > 0) {
            this.audioChunks.push(event.data)
          }
        })

        this.mediaRecorder.addEventListener("stop", () => {
          const blob = new Blob(this.audioChunks, {type: mimeType})
          this.blobToBase64(blob).then(base64 => {
            this.pushEvent("audio_recorded", {audio: base64})
          })
          this.cleanupStream()
        })

        this.mediaRecorder.start()
        this.recording = true
        this.el.setAttribute("data-recording", "true")
      })
      .catch(error => {
        console.error("AudioRecorder: microphone access error", error)
        const message = error.name === "NotAllowedError"
          ? "Microphone permission denied"
          : "Could not access microphone"
        this.pushEvent("audio_error", {error: message})
      })
  },

  stopRecording() {
    if (this.mediaRecorder && this.mediaRecorder.state === "recording") {
      this.mediaRecorder.stop()
    }
    this.recording = false
    this.el.removeAttribute("data-recording")
  },

  cleanupStream() {
    if (this.stream) {
      this.stream.getTracks().forEach(track => track.stop())
      this.stream = null
    }
  },

  blobToBase64(blob) {
    return new Promise((resolve) => {
      const reader = new FileReader()
      reader.onloadend = () => {
        const base64 = reader.result.split(",")[1]
        resolve(base64)
      }
      reader.readAsDataURL(blob)
    })
  },

  destroyed() {
    this.stopRecording()
    this.cleanupStream()
  }
}

export default AudioRecorder
