const { FFmpeg } = FFmpegWASM;
const { fetchFile, toBlobURL } = FFmpegUtil;
const ALLOWED_FPS = new Set(["30","60","120","240"]);
const ALLOWED_CRF = new Set(["18","15","12","10"]);
const ALLOWED_RES = new Set(["1920x1080","3840x2160"]);
const MAX_BROWSER_BYTES = 180 * 1024 * 1024;
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
let selectedFile = null, ffmpeg = null, loaded = false, objectUrl = null;
function sanitizeFilename(name) {
  return String(name || "video").replace(/[/\\?%*:|"<>]/g, "_").replace(/\.\./g, "_").slice(0, 180) || "video";
}
function safeText(el, text) { el.textContent = text; }
browseBtn.addEventListener("click", (e) => { e.stopPropagation(); fileInput.click(); });
dropZone.addEventListener("click", () => fileInput.click());
dropZone.addEventListener("dragover", (e) => { e.preventDefault(); dropZone.classList.add("dragover"); });
dropZone.addEventListener("dragleave", () => dropZone.classList.remove("dragover"));
dropZone.addEventListener("drop", (e) => {
  e.preventDefault(); dropZone.classList.remove("dragover");
  if (e.dataTransfer.files.length) handleFile(e.dataTransfer.files[0]);
});
fileInput.addEventListener("change", () => { if (fileInput.files.length) handleFile(fileInput.files[0]); });
function handleFile(file) {
  if (!file || !file.type || !file.type.startsWith("video/")) { alert("Please select a video file."); return; }
  selectedFile = file;
  safeText(fileName, sanitizeFilename(file.name) + " (" + (file.size / 1024 / 1024).toFixed(1) + " MB)");
  startBtn.disabled = false;
  if (file.size > MAX_BROWSER_BYTES) alert("File large for browser. Prefer CLI or cloud GPU.");
}
async function loadFFmpeg() {
  if (loaded) return;
  safeText(status, "Loading FFmpeg core…"); progressBox.classList.remove("hidden");
  ffmpeg = new FFmpeg();
  ffmpeg.on("log", () => {});
  ffmpeg.on("progress", ({ progress }) => {
    const pct = Math.min(100, Math.max(0, Math.round(progress * 100)));
    progressBar.style.width = pct + "%"; safeText(status, "Encoding… " + pct + "%");
  });
  const baseURL = "https://cdn.jsdelivr.net/npm/@ffmpeg/core@0.12.6/dist/umd";
  await ffmpeg.load({
    coreURL: await toBlobURL(baseURL + "/ffmpeg-core.js", "text/javascript"),
    wasmURL: await toBlobURL(baseURL + "/ffmpeg-core.wasm", "application/wasm"),
  });
  loaded = true; safeText(status, "FFmpeg ready.");
}
startBtn.addEventListener("click", async () => {
  if (!selectedFile) return;
  const fps = document.getElementById("fps").value;
  const crf = document.getElementById("crf").value;
  const res = document.getElementById("res").value;
  if (!ALLOWED_FPS.has(fps) || !ALLOWED_CRF.has(crf) || !ALLOWED_RES.has(res)) {
    alert("Invalid settings."); return;
  }
  const parts = res.split("x"); const w = parts[0], h = parts[1];
  if (!/^\d+$/.test(w) || !/^\d+$/.test(h)) { alert("Invalid resolution."); return; }
  startBtn.disabled = true; result.classList.add("hidden"); progressBox.classList.remove("hidden"); progressBar.style.width = "0%";
  if (objectUrl) { URL.revokeObjectURL(objectUrl); objectUrl = null; }
  try {
    await loadFFmpeg();
    safeText(status, "Writing file…");
    await ffmpeg.writeFile("input.mp4", await fetchFile(selectedFile));
    let vf = "scale=" + w + ":" + h + ":flags=lanczos";
    if (parseInt(fps, 10) > 30) vf += ",minterpolate=fps=" + fps + ":mi_mode=dup";
    safeText(status, "Encoding…");
    await ffmpeg.exec(["-i","input.mp4","-vf",vf,"-c:v","libx264","-preset","medium","-crf",crf,"-c:a","aac","-b:a","192k","-movflags","+faststart","output.mp4"]);
    const data = await ffmpeg.readFile("output.mp4");
    const blob = new Blob([data.buffer], { type: "video/mp4" });
    objectUrl = URL.createObjectURL(blob);
    const stem = sanitizeFilename(selectedFile.name.replace(/\.[^.]+$/, ""));
    downloadLink.href = objectUrl;
    downloadLink.download = stem + "_Upscaled_" + w + "x" + h + "_" + fps + "fps.mp4";
    downloadLink.rel = "noopener";
    result.classList.remove("hidden");
    safeText(status, "Done!"); progressBar.style.width = "100%";
    try { await ffmpeg.deleteFile("input.mp4"); await ffmpeg.deleteFile("output.mp4"); } catch (_) {}
  } catch (err) {
    console.error(err);
    safeText(status, "Error: " + String(err && err.message ? err.message : err));
    alert("Processing failed. Use CLI or cloud GPU.");
  } finally { startBtn.disabled = false; }
});
