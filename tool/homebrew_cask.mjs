#!/usr/bin/env node

import { readFile, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import {
  homebrewCask,
  homebrewInstallCommand,
  homebrewTap,
  loadReleaseContract,
  repositorySlug,
} from './release_contract.mjs';

const sha256Pattern = /^[0-9a-f]{64}$/;

function macosArtifact(metadata) {
  if (metadata.artifactProfile === 'macos-preview-v1') {
    throw new Error('The immutable v0.0.2 legacy Preview must not be published as the Homebrew Cask.');
  }
  const matches = metadata.artifacts.filter(({ id }) => id === 'macos-universal');
  if (matches.length !== 1) {
    throw new Error('The active release must contain exactly one macos-universal artifact.');
  }
  const [artifact] = matches;
  if (
    artifact.platform !== 'macos' ||
    artifact.architecture !== 'universal' ||
    artifact.extension !== 'zip' ||
    artifact.signing !== 'unsigned' ||
    artifact.installability !== 'unsigned-preview' ||
    artifact.file !== metadata.asset
  ) {
    throw new Error('The active macOS artifact does not satisfy the unsigned Homebrew Preview contract.');
  }
  return artifact;
}

export function renderHomebrewCask(metadata, sha256) {
  const artifact = macosArtifact(metadata);
  if (!sha256Pattern.test(sha256)) {
    throw new Error('Homebrew Cask SHA-256 must be exactly 64 lowercase hexadecimal characters.');
  }
  const versionedFile = artifact.file.replace(metadata.version, '#{version}');
  return `cask "${homebrewCask}" do
  version "${metadata.version}"
  sha256 "${sha256}"

  url "https://github.com/${repositorySlug}/releases/download/v#{version}/${versionedFile}"
  name "Pi Client"
  desc "Cross-platform Flutter client for the pi coding agent"
  homepage "https://github.com/${repositorySlug}"

  depends_on macos: :big_sur

  app "Pi Client.app"

  caveats <<~EOS
    Pi Client #{version} is an unsigned, unnotarized Preview. Homebrew preserves
    macOS quarantine metadata, so Gatekeeper will reject a normal first launch.

    In Finder, Control-click /Applications/Pi Client.app, select Open, then
    confirm Open. Do not remove quarantine metadata or disable Gatekeeper.

    This Preview still uses the transitional pi-web compatibility boundary.
    The first-party Pi host runtime and transport remain under development.
  EOS
end
`;
}

export async function activeHomebrewCask(sha256, root) {
  const metadata = await loadReleaseContract(root);
  return renderHomebrewCask(metadata, sha256);
}

export async function verifyHomebrewCask(path, sha256, root) {
  const expected = await activeHomebrewCask(sha256, root);
  const actual = await readFile(resolve(path), 'utf8');
  if (actual !== expected) {
    throw new Error(`${path} does not exactly match the active Homebrew Cask contract.`);
  }
  return { path: resolve(path), installCommand: homebrewInstallCommand, tap: homebrewTap };
}

function parseArguments(argv) {
  const [command, ...rest] = argv;
  if (!['render', 'verify'].includes(command)) {
    throw new Error('Usage: homebrew_cask.mjs <render|verify> --sha256 <digest> [--output <path>|--file <path>]');
  }
  const values = {};
  for (let index = 0; index < rest.length; index += 2) {
    const flag = rest[index];
    const value = rest[index + 1];
    if (!['--sha256', '--output', '--file', '--root'].includes(flag) || value === undefined) {
      throw new Error(`Invalid Homebrew Cask argument: ${flag ?? '<missing>'}.`);
    }
    if (values[flag]) throw new Error(`Duplicate Homebrew Cask argument: ${flag}.`);
    values[flag] = value;
  }
  if (!values['--sha256']) throw new Error('--sha256 is required.');
  if (command === 'render' && values['--file']) throw new Error('render accepts --output, not --file.');
  if (command === 'verify' && (!values['--file'] || values['--output'])) {
    throw new Error('verify requires --file and does not accept --output.');
  }
  return { command, values };
}

async function main() {
  const { command, values } = parseArguments(process.argv.slice(2));
  const root = values['--root'] ? resolve(values['--root']) : undefined;
  if (command === 'render') {
    const source = await activeHomebrewCask(values['--sha256'], root);
    if (values['--output']) {
      await writeFile(resolve(values['--output']), source);
    } else {
      process.stdout.write(source);
    }
    return;
  }
  const result = await verifyHomebrewCask(values['--file'], values['--sha256'], root);
  process.stdout.write(`${JSON.stringify(result)}\n`);
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  main().catch((error) => {
    console.error(error.message);
    process.exitCode = 1;
  });
}
