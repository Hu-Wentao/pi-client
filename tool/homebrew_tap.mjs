#!/usr/bin/env node

import { lstat, mkdir, readFile, writeFile } from 'node:fs/promises';
import { dirname, resolve, sep } from 'node:path';
import { pathToFileURL } from 'node:url';
import { activeHomebrewCask } from './homebrew_cask.mjs';
import {
  homebrewTap,
  homebrewTapCaskPath,
  repositoryRoot,
} from './release_contract.mjs';

function destinationFor(tapRoot) {
  const root = resolve(tapRoot);
  const destination = resolve(root, homebrewTapCaskPath);
  if (destination !== root && !destination.startsWith(`${root}${sep}`)) {
    throw new Error(`Homebrew Cask destination escapes the Tap root: ${destination}.`);
  }
  return { root, destination };
}

async function readExisting(path) {
  try {
    const metadata = await lstat(path);
    if (metadata.isSymbolicLink() || !metadata.isFile()) {
      throw new Error(`Homebrew Cask path must be a regular file: ${path}.`);
    }
    return await readFile(path, 'utf8');
  } catch (error) {
    if (error.code === 'ENOENT') return null;
    throw error;
  }
}

export async function updateHomebrewTap({
  tapRoot,
  sha256,
  evidence,
  root = repositoryRoot,
  checkOnly = false,
}) {
  if (!tapRoot) throw new Error('tapRoot is required.');
  const { destination } = destinationFor(tapRoot);
  const expected = await activeHomebrewCask(sha256, evidence, root);
  const actual = await readExisting(destination);
  if (actual === expected) {
    return { changed: false, path: destination, tap: homebrewTap };
  }
  if (checkOnly) {
    throw new Error(`${destination} does not match the qualified Homebrew Cask.`);
  }
  await mkdir(dirname(destination), { recursive: true });
  await writeFile(destination, expected);
  return { changed: true, path: destination, tap: homebrewTap };
}

function optionValue(arguments_, name) {
  const index = arguments_.indexOf(name);
  if (index === -1) return undefined;
  const value = arguments_[index + 1];
  if (!value || value.startsWith('--')) throw new Error(`${name} requires a value.`);
  return value;
}

async function main() {
  const arguments_ = process.argv.slice(2);
  const tapRoot = optionValue(arguments_, '--tap-dir');
  const sha256 = optionValue(arguments_, '--sha256');
  const evidencePath = optionValue(arguments_, '--qualified-release');
  const root = optionValue(arguments_, '--root');
  if (!tapRoot || !sha256 || !evidencePath) {
    throw new Error(
      'Usage: homebrew_tap.mjs --tap-dir <path> --sha256 <digest> --qualified-release <json> [--root <path>] [--check-only]',
    );
  }
  const evidence = JSON.parse(await readFile(resolve(evidencePath), 'utf8'));
  const result = await updateHomebrewTap({
    tapRoot,
    sha256,
    evidence,
    root: root ? resolve(root) : repositoryRoot,
    checkOnly: arguments_.includes('--check-only'),
  });
  process.stdout.write(`${JSON.stringify(result)}\n`);
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  main().catch((error) => {
    console.error(error.message);
    process.exitCode = 1;
  });
}
