import React, { useState, useRef } from "react";
import "./index.css"; // for the pulse keyframes

export default function QueryForm({ onSubmit }) {
  const [text, setText] = useState("");
  const [isRecording, setIsRecording] = useState(false);
  const [isTranscribing, setIsTranscribing] = useState(false);
  const mediaRecorderRef = useRef(null);
  const audioChunksRef = useRef([]);

  const handleSubmit = e => {
    e.preventDefault();
    if (text.trim()) onSubmit(text.trim());
  };

  const startRecording = async () => {
    setText("");
    setIsTranscribing(false);
    setIsRecording(true);

    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      const mr = new MediaRecorder(stream);
      mediaRecorderRef.current = mr;
      audioChunksRef.current = [];

      mr.ondataavailable = e => {
        audioChunksRef.current.push(e.data);
      };

      mr.onstop = async () => {
        setIsRecording(false);
        setIsTranscribing(true);

        const blob = new Blob(audioChunksRef.current, { type: "audio/wav" });
        const form = new FormData();
        form.append("file", blob, "query.wav");

        try {
          const res = await fetch("http://localhost:8000/whisper", {
            method: "POST",
            body: form
          });
          const { transcript } = await res.json();
          setText(transcript);
        } catch (err) {
          console.error("ASR error:", err);
        } finally {
          setIsTranscribing(false);
        }
      };

      mr.start();
    } catch (err) {
      console.error("Could not start recording:", err);
      setIsRecording(false);
    }
  };

  const stopRecording = () => {
    mediaRecorderRef.current?.stop();
  };

  return (
    <form onSubmit={handleSubmit} style={{ marginBottom: 20 }}>
      <input
        type="text"
        value={text}
        onChange={e => setText(e.target.value)}
        placeholder={
          isRecording
            ? "Listening…"
            : isTranscribing
            ? "Transcribing…"
            : "Type your query…"
        }
        style={{ width: "60%", padding: 8 }}
        disabled={isRecording || isTranscribing}
      />

      <button
        type="button"
        onClick={isRecording ? stopRecording : startRecording}
        style={{
          marginLeft: 8,
          padding: "8px",
          background: isRecording ? "var(--accent)" : "#eee",
          borderRadius: "50%",
          border: "none",
          cursor: "pointer",
          animation: isRecording ? "pulse 1.5s infinite" : "none"
        }}
        title={isRecording ? "Stop recording" : "Start recording"}
      >
        {isRecording ? "■" : "🎤"}
      </button>

      <button
        type="submit"
        style={{ marginLeft: 8, padding: "8px 16px" }}
        disabled={isRecording || isTranscribing}
      >
        Run
      </button>
    </form>
  );
}
