#!/usr/bin/env node

const options = parseArguments(process.argv.slice(2));
const requirements =
  options.platform === "windows"
    ? [
        "WINDOWS_SIGNING_CERTIFICATE_BASE64",
        "WINDOWS_SIGNING_CERTIFICATE_PASSWORD",
      ]
    : ["LINUX_GPG_PRIVATE_KEY_BASE64", "LINUX_GPG_PASSPHRASE"];
const missing = requirements.filter(
  (name) => !(process.env[name] ?? "").trim(),
);
if (options.channel === "stable" && missing.length > 0) {
  throw new Error(
    `Stable ${options.platform} packaging requires signing credentials: ${missing.join(", ")}.`,
  );
}
process.stdout.write(
  `${JSON.stringify({
    platform: options.platform,
    channel: options.channel,
    signingRequired: options.channel === "stable",
    credentialsAvailable: missing.length === 0,
    missing,
  })}\n`,
);

function parseArguments(arguments_) {
  const values = new Map();
  for (let index = 0; index < arguments_.length; index += 1) {
    const argument = arguments_[index];
    if (!["--platform", "--channel"].includes(argument)) {
      throw new Error(`Unsupported signing-gate argument ${argument}.`);
    }
    const value = arguments_[++index];
    if (!value) throw new Error(`${argument} requires a value.`);
    values.set(argument, value);
  }
  const platform = values.get("--platform");
  const channel = values.get("--channel");
  if (!new Set(["windows", "linux"]).has(platform)) {
    throw new Error("--platform must be windows or linux.");
  }
  if (!new Set(["candidate", "stable"]).has(channel)) {
    throw new Error("--channel must be candidate or stable.");
  }
  return { platform, channel };
}
