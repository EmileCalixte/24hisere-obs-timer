import fs from "fs";
import path from "path";

const requiredEnvVars = [
  "RACE_START_DATE",
  "RACE_END_DATE",
  "CHRONO_OUTPUT_FILE",
  "TIME_OUTPUT_FILE",
  "DEBUG",
];
const missingEnvVars = requiredEnvVars.filter((key) => !process.env[key]);
if (missingEnvVars.length > 0) {
  throw new Error(`Missing environment variables: ${missingEnvVars.join(", ")}`);
}

const { RACE_START_DATE, RACE_END_DATE, CHRONO_OUTPUT_FILE, TIME_OUTPUT_FILE, DEBUG } = process.env;

const debug = !!DEBUG && DEBUG !== "0" && DEBUG !== "false";

const raceStart = new Date(RACE_START_DATE);
const raceEnd = new Date(RACE_END_DATE);
const maxChronoDuration = raceEnd - raceStart;

function debugLog(log) {
  if (!debug) {
    return;
  }

  console.log(log);
}

function ensureFile(filePath) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  if (!fs.existsSync(filePath)) {
    debugLog(`File ${filePath} does not exist. Creating it`);
    fs.writeFileSync(filePath, "");
  }
}

function toHHMMSS(ms) {
  const totalSeconds = Math.floor(ms / 1000);
  const h = Math.floor(totalSeconds / 3600);
  const m = Math.floor((totalSeconds % 3600) / 60);
  const s = totalSeconds % 60;
  return `${String(h).padStart(2, "0")}:${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`;
}

function currentTime() {
  const now = new Date();
  const h = String(now.getHours()).padStart(2, "0");
  const m = String(now.getMinutes()).padStart(2, "0");
  const s = String(now.getSeconds()).padStart(2, "0");
  return `${h}:${m}:${s}`;
}

function chronoValue() {
  const now = new Date();
  if (now < raceStart) return "00:00:00";
  if (now >= raceEnd) return toHHMMSS(maxChronoDuration);
  return toHHMMSS(now - raceStart);
}

ensureFile(TIME_OUTPUT_FILE);
ensureFile(CHRONO_OUTPUT_FILE);

function tick() {
  debugLog("TICK");
  fs.writeFileSync(TIME_OUTPUT_FILE, currentTime());
  fs.writeFileSync(CHRONO_OUTPUT_FILE, chronoValue());
  const msUntilNextSecond = 1000 - (Date.now() % 1000);
  setTimeout(tick, msUntilNextSecond);
  debugLog(`Next tick in ${msUntilNextSecond} ms`);
}

tick();
