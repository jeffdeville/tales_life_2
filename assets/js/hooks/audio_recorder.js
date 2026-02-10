const MAX_RECORDING_SECONDS = 300 // 5 minutes

const AudioRecorder = {
  mounted() {
    this.recording = false
    this.mediaRecorder = null
    this.audioChunks = []
    this.stream = null
    this.timerInterval = null
    this.elapsedSeconds = 0
    this.analyser = null
    this.audioContext = null
    this.levelAnimationFrame = null

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
        this.pushEvent("recording_started", {})

        this.startTimer()
        this.startLevelMonitor(stream)
      })
      .catch(error => {
        console.error("AudioRecorder: microphone access error", error)
        const message = error.name === "NotAllowedError"
          ? "Microphone permission denied"
          : "Could not access microphone"
        this.pushEvent("audio_error", {error: message})
      })
  },

  stopRecording(autoStopped) {
    this.stopTimer()
    this.stopLevelMonitor()

    if (this.mediaRecorder && this.mediaRecorder.state === "recording") {
      this.mediaRecorder.stop()
    }
    this.recording = false
    this.el.removeAttribute("data-recording")
    this.el.removeAttribute("data-recording-time")

    if (autoStopped) {
      this.pushEvent("audio_error", {
        error: "Recording stopped — maximum duration of 5 minutes reached."
      })
    }
  },

  startTimer() {
    this.elapsedSeconds = 0
    this.updateTimerDisplay()

    this.timerInterval = setInterval(() => {
      this.elapsedSeconds++
      this.updateTimerDisplay()

      if (this.elapsedSeconds >= MAX_RECORDING_SECONDS) {
        this.stopRecording(true)
      }
    }, 1000)
  },

  stopTimer() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
      this.timerInterval = null
    }
    this.elapsedSeconds = 0

    const timerEl = this.el.closest("[data-recording-container]")
      ?.querySelector("[data-recording-timer]")
      || document.querySelector("[data-recording-timer]")
    if (timerEl) {
      timerEl.textContent = ""
    }
  },

  updateTimerDisplay() {
    const minutes = Math.floor(this.elapsedSeconds / 60)
    const seconds = this.elapsedSeconds % 60
    const formatted = `${minutes}:${String(seconds).padStart(2, "0")}`

    this.el.setAttribute("data-recording-time", this.elapsedSeconds)

    const timerEl = this.el.closest("[data-recording-container]")
      ?.querySelector("[data-recording-timer]")
      || document.querySelector("[data-recording-timer]")
    if (timerEl) {
      timerEl.textContent = formatted
    }
  },

  startLevelMonitor(stream) {
    try {
      this.audioContext = new (window.AudioContext || window.webkitAudioContext)()
      this.analyser = this.audioContext.createAnalyser()
      this.analyser.fftSize = 256

      const source = this.audioContext.createMediaStreamSource(stream)
      source.connect(this.analyser)

      const dataArray = new Uint8Array(this.analyser.frequencyBinCount)

      const updateLevel = () => {
        if (!this.recording) return

        this.analyser.getByteFrequencyData(dataArray)

        // Compute RMS-like average of frequency data
        let sum = 0
        for (let i = 0; i < dataArray.length; i++) {
          sum += dataArray[i]
        }
        const average = sum / dataArray.length
        // Scale 0-255 to 0-100
        const level = Math.round(Math.min(100, (average / 255) * 100 * 2.5))

        const levelEl = this.el.closest("[data-recording-container]")
          ?.querySelector("[data-audio-level]")
          || document.querySelector("[data-audio-level]")
        if (levelEl) {
          levelEl.setAttribute("data-audio-level", level)
          levelEl.style.setProperty("--audio-level", level)
        }

        this.levelAnimationFrame = requestAnimationFrame(updateLevel)
      }

      this.levelAnimationFrame = requestAnimationFrame(updateLevel)
    } catch (e) {
      // AnalyserNode not available — degrade gracefully
      console.warn("AudioRecorder: audio level monitoring not available", e)
    }
  },

  stopLevelMonitor() {
    if (this.levelAnimationFrame) {
      cancelAnimationFrame(this.levelAnimationFrame)
      this.levelAnimationFrame = null
    }
    if (this.audioContext) {
      this.audioContext.close().catch(() => {})
      this.audioContext = null
      this.analyser = null
    }

    const levelEl = this.el.closest("[data-recording-container]")
      ?.querySelector("[data-audio-level]")
      || document.querySelector("[data-audio-level]")
    if (levelEl) {
      levelEl.setAttribute("data-audio-level", "0")
      levelEl.style.setProperty("--audio-level", "0")
    }
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
