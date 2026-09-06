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
const commitPattern = /^[0-9a-f]{40}$/;

function macosArtifact(metadata) {
  if (!metadata.publicationEnabled) {
    throw new Error('Homebrew Cask generation is dormant while the active release profile is publication-disabled.');
  }
  const matches = metadata.artifacts.filter(({ id }) => id === 'macos-universal');
  if (matches.length !== 1) {
    throw new Error('A qualified Homebrew release must contain exactly one macos-universal artifact.');
  }
  const [artifact] = matches;
  if (
    artifact.platform !== 'macos' ||
    artifact.architecture !== 'universal' ||
    artifact.extension !== 'zip' ||
    artifact.hostRuntimeIncluded !== true ||
    artifact.file !== metadata.asset
  ) {
    throw new Error('The qualified macOS artifact does not satisfy the first-party Homebrew contract.');
  }
  return artifact;
}

function assertQualifiedRelease(metadata, sha256, evidence) {
  if (!sha256Pattern.test(sha256)) {
    throw new Error('Homebrew Cask SHA-256 must be exactly 64 lowercase hexadecimal characters.');
  }
  const expectedKeys = ['asset', 'commit', 'published', 'sha256', 'tag'];
  if (
    !evidence ||
    JSON.stringify(Object.keys(evidence).sort()) !== JSON.stringify(expectedKeys)
  ) {
    throw new Error(`Qualified Release evidence keys must be exactly: ${expectedKeys.join(', ')}.`);
  }
  if (
    evidence.published !== true ||
    evidence.tag !== metadata.tag ||
    evidence.asset !== metadata.asset ||
    evidence.sha256 !== sha256 ||
    !commitPattern.test(evidence.commit)
  ) {
    throw new Error('Qualified Release evidence does not bind the exact published tag, asset, digest, and commit.');
  }
}

export function renderHomebrewCask(metadata, sha256, evidence) {
  const artifact = macosArtifact(metadata);
  assertQualifiedRelease(metadata, sha256, evidence);
  const versionedFile = artifact.file.replace(metadata.version, '#{version}');
  const trustNotice = metadata.distribution === 'independent-public-preview'
    ? 'This public Preview is ad-hoc signed and not notarized. Homebrew preserves macOS quarantine metadata and never disables Gatekeeper.'
    : 'Follow the release notes for its signing and notarization status. Homebrew preserves macOS quarantine metadata and never disables Gatekeeper.';
  return `cask "${homebrewCask}" do
  version "${metadata.version}"
  sha256 "${sha256}"

  url "https://github.com/${repositorySlug}/releases/download/v#{version}/${versionedFile}"
  name "Pi Client"
  desc "Independent cross-platform Flutter client for the pi coding agent"
  homepage "https://github.com/${repositorySlug}"

  depends_on macos: :big_sur

  app "Pi Client.app"

  caveats <<~EOS
    This exact Pi Client release includes the first-party Pi Node runtime.
    ${trustNotice}
  EOS
end
`;
}

export async function activeHomebrewCask(sha256, evidence, root) {
  const metadata = await loadReleaseContract(root, { requirePublication: true });
  return renderHomebrewCask(metadata, sha256, evidence);
}

export async function verifyHomebrewCask(path, sha256, evidence, root) {
  const expected = await activeHomebrewCask(sha256, evidence, root);
  const actual = await readFile(resolve(path), 'utf8');
  if (actual !== expected) {
    throw new Error(`${path} does not exactly match the qualified Homebrew Cask contract.`);
  }
  return { path: resolve(path), installCommand: homebrewInstallCommand, tap: homebrewTap };
}

function parseArguments(argv) {
  const [command, ...rest] = argv;
  if (!['render', 'verify'].includes(command)) {
    throw new Error(
      'Usage: homebrew_cask.mjs <render|verify> --sha256 <digest> --qualified-release <json> [--output <path>|--file <path>]',
    );
  }
  const values = {};
  for (let index = 0; index < rest.length; index += 2) {
    const flag = rest[index];
    const value = rest[index + 1];
    if (
      !['--sha256', '--qualified-release', '--output', '--file', '--root'].includes(flag) ||
      value === undefined
    ) {
      throw new Error(`Invalid Homebrew Cask argument: ${flag ?? '<missing>'}.`);
    }
    if (values[flag]) throw new Error(`Duplicate Homebrew Cask argument: ${flag}.`);
    values[flag] = value;
  }
  if (!values['--sha256'] || !values['--qualified-release']) {
    throw new Error('--sha256 and --qualified-release are required.');
  }
  if (command === 'render' && values['--file']) throw new Error('render accepts --output, not --file.');
  if (command === 'verify' && (!values['--file'] || values['--output'])) {
    throw new Error('verify requires --file and does not accept --output.');
  }
  return { command, values };
}

async function main() {
  const { command, values } = parseArguments(process.argv.slice(2));
  const root = values['--root'] ? resolve(values['--root']) : undefined;
  const evidence = JSON.parse(await readFile(resolve(values['--qualified-release']), 'utf8'));
  if (command === 'render') {
    const source = await activeHomebrewCask(values['--sha256'], evidence, root);
    if (values['--output']) {
      await writeFile(resolve(values['--output']), source);
    } else {
      process.stdout.write(source);
    }
    return;
  }
  const result = await verifyHomebrewCask(
    values['--file'],
    values['--sha256'],
    evidence,
    root,
  );
  process.stdout.write(`${JSON.stringify(result)}\n`);
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  main().catch((error) => {
    console.error(error.message);
    process.exitCode = 1;
  });
}
