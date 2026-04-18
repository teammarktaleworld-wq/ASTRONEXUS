import fs from "fs";
import path from "path";
import { spawn } from "child_process";

const managedChildren = [];
let cleanupRegistered = false;

const isEnabled = (value, defaultValue = true) => {
  if (value === undefined || value === null || value === "") {
    return defaultValue;
  }
  return String(value).toLowerCase() !== "false";
};

const streamLogs = (child, label) => {
  child.stdout?.on("data", (chunk) => {
    process.stdout.write(`[${label}] ${chunk}`);
  });
  child.stderr?.on("data", (chunk) => {
    process.stderr.write(`[${label}] ${chunk}`);
  });
};

const spawnManagedProcess = ({ name, command, args, cwd, env }) => {
  if (!fs.existsSync(cwd)) {
    console.warn(`[unified] Skipping ${name}: directory not found -> ${cwd}`);
    return null;
  }

  const child = spawn(command, args, {
    cwd,
    env: { ...process.env, ...env },
    stdio: ["ignore", "pipe", "pipe"],
    windowsHide: true,
  });

  child.on("exit", (code, signal) => {
    console.log(`[unified] ${name} exited (code=${code}, signal=${signal})`);
  });

  child.on("error", (error) => {
    console.error(`[unified] ${name} failed to start:`, error.message);
  });

  streamLogs(child, name);
  managedChildren.push(child);
  console.log(`[unified] Started ${name} (pid=${child.pid})`);
  return child;
};

const stopManagedChildren = () => {
  for (const child of managedChildren) {
    if (!child || child.killed) {
      continue;
    }
    try {
      child.kill("SIGTERM");
    } catch (error) {
      console.error("[unified] Failed to stop child process:", error.message);
    }
  }
};

const resolvePythonCommand = (chartDir) => {
  if (process.env.PYTHON_BIN) {
    return process.env.PYTHON_BIN;
  }

  const winVenv = path.join(chartDir, ".venv", "Scripts", "python.exe");
  const unixVenv = path.join(chartDir, ".venv", "bin", "python");

  if (fs.existsSync(winVenv)) {
    return winVenv;
  }
  if (fs.existsSync(unixVenv)) {
    return unixVenv;
  }
  return process.platform === "win32" ? "python" : "python3";
};

const registerCleanup = () => {
  if (cleanupRegistered) {
    return;
  }
  cleanupRegistered = true;

  const safeShutdown = () => {
    stopManagedChildren();
  };

  process.on("SIGINT", safeShutdown);
  process.on("SIGTERM", safeShutdown);
  process.on("exit", safeShutdown);
};

export const startUnifiedInternalServices = ({ backendDir }) => {
  const autoStart = isEnabled(process.env.UNIFIED_AUTOSTART, true);
  if (!autoStart) {
    console.log("[unified] UNIFIED_AUTOSTART=false -> skipping internal services");
    return;
  }

  const rootDir = path.resolve(backendDir, "..");

  const birthChartPort = Number(process.env.BIRTH_CHART_PORT || 8010);
  const horoscopePort = Number(process.env.HOROSCOPE_PORT || 4000);
  const matiPort = Number(process.env.MATI_PORT || 3000);

  process.env.BIRTH_CHART_SERVICE_URL =
    process.env.BIRTH_CHART_SERVICE_URL || `http://127.0.0.1:${birthChartPort}`;
  process.env.HOROSCOPE_SERVICE_URL =
    process.env.HOROSCOPE_SERVICE_URL || `http://127.0.0.1:${horoscopePort}`;
  process.env.MATI_CHAT_SERVICE_URL =
    process.env.MATI_CHAT_SERVICE_URL || `http://127.0.0.1:${matiPort}`;

  registerCleanup();

  const birthChartDir = path.join(rootDir, "Python", "birth_chart", "astro-nexus-backend");
  const horoscopeDir = path.join(rootDir, "Python", "horoscope", "astronexus-horoscope");
  const matiDir = path.join(rootDir, "Python", "mati", "astro-bot");

  if (isEnabled(process.env.UNIFIED_START_BIRTH_CHART, true)) {
    const pythonCommand = resolvePythonCommand(birthChartDir);
    spawnManagedProcess({
      name: "birth-chart-service",
      command: pythonCommand,
      args: ["-m", "uvicorn", "main:app", "--host", "127.0.0.1", "--port", String(birthChartPort)],
      cwd: birthChartDir,
    });
  }

  if (isEnabled(process.env.UNIFIED_START_HOROSCOPE, true)) {
    spawnManagedProcess({
      name: "horoscope-service",
      command: "node",
      args: ["src/server.js"],
      cwd: horoscopeDir,
      env: { PORT: String(horoscopePort) },
    });
  }

  if (isEnabled(process.env.UNIFIED_START_MATI, true)) {
    spawnManagedProcess({
      name: "mati-service",
      command: "node",
      args: ["src/server.js"],
      cwd: matiDir,
      env: { PORT: String(matiPort) },
    });
  }
};
