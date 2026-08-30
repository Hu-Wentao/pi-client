#!/usr/bin/env node
import { appendFile, readFile } from 'node:fs/promises';
import process from 'node:process';
import {
  assertCandidateExceedsRemoteStableTags,
  inspectRemoteCandidateTag,
  loadReleaseContract,
} from './release_contract.mjs';

function optionValue(name) {
  const index = process.argv.indexOf(name);
  if (index === -1) return undefined;
  const value = process.argv[index + 1];
  if (!value || value.startsWith('--')) throw new Error(`${name} requires a value.`);
  return value;
}

const outputPath = optionValue('--github-output');
const requireProfile = optionValue('--require-profile');
const remoteTagsPath = optionValue('--remote-tags-file');
const candidateCommit = optionValue('--candidate-commit');
if (Boolean(remoteTagsPath) !== Boolean(candidateCommit)) {
  throw new Error('--remote-tags-file and --candidate-commit must be provided together.');
}

const contract = await loadReleaseContract(undefined, { requireProfile });
const metadata = {
  version: contract.version,
  buildNumber: contract.buildNumber,
  tag: contract.tag,
  asset: contract.asset,
  checksumAsset: contract.checksumAsset,
  downloadUrl: contract.downloadUrl,
  artifactProfile: contract.artifactProfile,
  expectedAssetsJson: JSON.stringify(contract.expectedAssets),
  releaseTitle: contract.releaseTitle,
  releaseNotesPath: contract.releaseNotesPath,
};

if (remoteTagsPath) {
  const remoteTags = await readFile(remoteTagsPath, 'utf8');
  assertCandidateExceedsRemoteStableTags(contract.tag, remoteTags);
  metadata.remoteTagState = inspectRemoteCandidateTag(
    contract.tag,
    candidateCommit,
    remoteTags,
  ).state;
}

if (outputPath) {
  const lines = Object.entries(metadata).map(([key, value]) => {
    if (String(value).includes('\n')) throw new Error(`GitHub output ${key} must be a single line.`);
    return `${key}=${value}`;
  });
  await appendFile(outputPath, `${lines.join('\n')}\n`);
}

console.log(JSON.stringify(metadata, null, 2));
