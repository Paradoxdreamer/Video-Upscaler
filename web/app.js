const { FFmpeg } = FFmpegWASM;
const { fetchFile, toBlobURL } = FFmpegUtil;

const dropZone = document.getElementById("dropZone");
const fileInput = document.getElementById("fileInput");
const browseBtn = document.getElementById("browseBtn");
const fileName = document.getElementById("fileName");
const startBtn = document.getElementById("startBtn");
const progressBox = document.getElementById("progressBox");
const progressBar = document.getElementById("progressBar");
const status = document.getElementById("status");
const result = document.getElementById("result");
const downloadLink = document.getElementById("downloadLink");

let selectedFile = null;
let ffmpeg = null;
let loaded = false;

browseBtn.addEventListener("click", (e) => {
  e.stopPropagation();
  fileInput.click();
});

dropZone.addEventListener("click", () => fileInput.click());

dropZone.addEventListener("dragover", (e) => {
  e.preventDefault();
  dropZone.classList.add("dragover");
});

dropZone.addEventListener("dragleave", () => {
  dropZone.classList.remove("dragover");
});

dropZone.addEventListener("drop", (e) => {
  e.preventDefault();
  dropZone.classList.remove("dragover");
  if (e.dataTransfer.files.length) {
    handleFile(e.dataTransfer.files[0]);
  }
});

fileInput.addEventListener("change", () => {
  if (fileInput.files.length) handleFile(fileInput.files[0]);
});

function handleFile(file) {
  if (!file.type.startsWith("video/")) {
    alert("Please select a video file.");
    return;
  }
  selectedFile = file;
  fileName.textContent = `${file.name} (${(file.size / 1024 / 1024).toFixed(1)} MB)`;
  startBtn.disabled = false;

  if (file.size > 180 * 1024 * 1024) {
    alert(
      "File is quite large for browser processing.\n" +
      "It may crash or be extremely slow.\n\n" +
      "Recommended: use the CLI on a powerful machine or rent a cloud GPU."
    );
  }
}

async function loadFFmpeg() {
  if (loaded) return;
  status.textContent = "Loading FFmpeg core (first time may take a moment)…";
  progressBox.classList.remove("hidden");

  ffmpeg = new FFmpeg();
  ffmpeg.on("log", ({ message }) => {});
  ffmpeg.on("progress", ({ progress }) => {
    const pct = Math.round(progress * 100);
    progressBar.style.width = pct + "%";
    status.textContent = `Encoding… ${pct}%`;
  });

  const baseURL = "https://cdn.jsdelivr.net/npm/@ffmpeg/core@0.12.6/dist/umd";
  await ffmpeg.load({
    coreURL: await toBlobURL(`${baseURL}/ffmpeg-core.js`, "text/javascript"),
    wasmURL: await toBlobURL(`${baseURL}/ffmpeg-core.wasm`, "application/wasm"),
  });

  loaded = true;
  status.textContent = "FFmpeg ready. Starting encode…";
}

startBtn.addEventListener("click", async () => {
  if (!selectedFile) return;

  startBtn.disabled = true;
  result.classList.add("hidden");
  progressBox.classList.remove("hidden");
  progressBar.style.width = "0%";

  try {
    await loadFFmpeg();

    const fps = document.getElementById("fps").value;
    const crf = document.getElementById("crf").value;
    const res = document.getElementById("res").value;
    const [w, h] = res.split("x");

    status.textContent = "Writing file into virtual FS…";
    await ffmpeg.writeFile("input.mp4", await fetchFile(selectedFile));

    let vf = `scale=${w}:${h}:flags=lanczos`;
    if (parseInt(fps) > 30) {
      vf += `,minterpolate=fps=${fps}:mi_mode=dup`;
    }

    status.textContent = "Encoding at peak quality… this will take time.";
    await ffmpeg.exec([
      "-i", "input.mp4",
      "-vf", vf,
      "-c:v", "libx264",
      "-preset", "medium",
      "-crf", crf,
      "-c:a", "aac",
      "-b:a", "192k",
      "-movflags", "+faststart",
      "output.mp4",
    ]);

    status.textContent = "Reading result…";
    const data = await ffmpeg.readFile("output.mp4");
    const blob = new Blob([data.buffer], { type: "video/mp4" });
    const url = URL.createObjectURL(blob);

    downloadLink.href = url;
    downloadLink.download = selectedFile.name.replace(/\.[^.]+$/, "") + `_Upscaled_${w}x${h}_${fps}fps.mp4`;
    result.classList.remove("hidden");
    status.textContent = "Done! Download your upscaled video.";
    progressBar.style.width = "100%";
  } catch (err) {
    console.error(err);
    status.textContent = "Error: " + (err.message || err);
    alert(
      "Processing failed.\n\n" +
      "Common causes: video too large for browser memory, or device too weak.\n\n" +
      "Solution: use the CLI version on a desktop/laptop or rent a cloud GPU (RunPod / Vast.ai)."
    );
  } finally {
    startBtn.disabled = false;
  }
});
