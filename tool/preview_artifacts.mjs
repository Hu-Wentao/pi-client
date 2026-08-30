#!/usr/bin/env node
import { createHash } from 'node:crypto';
import {
  copyFile,
  lstat,
  mkdir,
  readFile,
  readdir,
  realpath,
  rm,
  stat,
  writeFile,
} from 'node:fs/promises';
import { basename, relative, resolve, sep } from 'node:path';
import process from 'node:process';
import {
  applicationArtifacts,
  assertArtifactProfileVersion,
  getArtifactProfile,
  loadReleaseContract,
  releaseAssets,
  requiredFlutterVersion,
} from './release_contract.mjs';

const manifestName = 'artifact-manifest.json';
const sumsName = 'SHA256SUMS';
const stageEvidenceSuffix = '.stage-evidence.json';
const workflowPlatforms = Object.freeze([
  'android',
  'ios',
  'linux',
  'macos',
  'web',
  'windows',
]);
const reservedHostRuntimeBasenames = Object.freeze([
  'pi-client-agent-host',
  'pi_client_agent_host',
  'piclientagenthost',
  'pi-sdk-host',
  'pi_sdk_host',
]);

export const hostRuntimeVerification = Object.freeze({
  method: 'recursive-package-filename-boundary-scan',
  result: 'passed',
  evidenceBoundary: 'filenames-and-contained-symlink-targets-only',
});

function assertCommit(commit) {
  if (!/^[0-9a-f]{40}$/.test(commit ?? '')) {
    throw new Error('Commit must be an exact lowercase 40-character hexadecimal Git commit.');
  }
}

async function sha256(path) {
  return createHash('sha256').update(await readFile(path)).digest('hex');
}

function isReservedHostRuntimeBasename(name) {
  const normalized = name.toLowerCase();
  return reservedHostRuntimeBasenames.some(
    (reserved) => normalized === reserved || normalized.startsWith(`${reserved}.`),
  );
}

function isWithinRoot(root, path) {
  return path === root || path.startsWith(`${root}${sep}`);
}

function assertAllowedBasename(path) {
  if (isReservedHostRuntimeBasename(basename(path))) {
    throw new Error(`Reserved future host runtime basename is forbidden: ${path}.`);
  }
}

export async function scanPackageContents(contentsRoot) {
  const root = resolve(contentsRoot);
  const rootInfo = await lstat(root);
  if (rootInfo.isSymbolicLink() || !rootInfo.isDirectory()) {
    throw new Error(`Expected a non-symlink contents directory: ${root}.`);
  }
  assertAllowedBasename(root);
  const canonicalRoot = await realpath(root);
  let descendants = 0;
  async function visit(directory) {
    for (const entry of (await readdir(directory, { withFileTypes: true })).sort((a, b) =>
      a.name.localeCompare(b.name),
    )) {
      const path = resolve(directory, entry.name);
      const info = await lstat(path);
      assertAllowedBasename(path);
      descendants += 1;
      if (info.isSymbolicLink()) {
        let target;
        try {
          target = await realpath(path);
        } catch (error) {
          throw new Error(`Package symlink must resolve successfully: ${path}.`, { cause: error });
        }
        if (!isWithinRoot(canonicalRoot, target)) {
          throw new Error(`Package symlink escapes the contents root: ${path} -> ${target}.`);
        }
      } else if (info.isDirectory()) {
        await visit(path);
      } else if (!info.isFile()) {
        throw new Error(`Unsupported filesystem entry: ${path}.`);
      }
    }
  }
  await visit(root);
  if (descendants === 0) {
    throw new Error('Contents root must contain at least one package entry.');
  }
  return hostRuntimeVerification;
}

async function walkFiles(root) {
  const rootInfo = await lstat(root);
  if (rootInfo.isSymbolicLink()) throw new Error(`Symlink input is forbidden: ${root}.`);
  if (!rootInfo.isDirectory()) throw new Error(`Expected a directory: ${root}.`);
  const files = [];
  async function visit(directory) {
    for (const entry of (await readdir(directory, { withFileTypes: true })).sort((a, b) =>
      a.name.localeCompare(b.name),
    )) {
      const path = resolve(directory, entry.name);
      const info = await lstat(path);
      if (info.isSymbolicLink()) throw new Error(`Symlink input is forbidden: ${path}.`);
      if (info.isDirectory()) await visit(path);
      else if (info.isFile()) files.push(path);
      else throw new Error(`Unsupported filesystem entry: ${path}.`);
    }
  }
  await visit(root);
  return files;
}

function selectProfile(contract, profileId) {
  const profile = getArtifactProfile(profileId ?? contract.artifactProfile);
  assertArtifactProfileVersion(profile, contract.version, contract.buildNumber);
  return {
    profile,
    artifacts: applicationArtifacts(contract.version, profile),
  };
}

function ensureSeparateDirectories(inputDir, outputDir) {
  const input = resolve(inputDir);
  const output = resolve(outputDir);
  if (
    output === input ||
    output.startsWith(`${input}${sep}`) ||
    input.startsWith(`${output}${sep}`)
  ) {
    throw new Error('Input and output directories must not contain one another.');
  }
}

function stageEvidenceName(artifactFile) {
  return `${artifactFile}${stageEvidenceSuffix}`;
}

function stageEvidenceFor(artifact) {
  return {
    schemaVersion: 1,
    target: artifact.id,
    file: artifact.file,
    hostRuntimeIncluded: false,
    hostRuntimeVerification,
  };
}

async function assertPathAbsent(path) {
  try {
    await lstat(path);
    throw new Error(`Stage destination already exists: ${path}.`);
  } catch (error) {
    if (error.code !== 'ENOENT') throw error;
  }
}

export async function stageArtifact({
  root,
  profileId,
  targetId,
  inputPath,
  contentsRoot,
  outputDir,
}) {
  const contract = await loadReleaseContract(root);
  const { profile, artifacts } = selectProfile(contract, profileId);
  const artifact = artifacts.find(({ id }) => id === targetId);
  if (!artifact) throw new Error(`Target ${targetId} is not in profile ${profile.id}.`);
  const inputInfo = await lstat(inputPath);
  if (inputInfo.isSymbolicLink() || !inputInfo.isFile()) {
    throw new Error('Stage input must be one regular, non-symlink file.');
  }
  if (inputInfo.size === 0) throw new Error('Stage input must not be empty.');
  const verification = await scanPackageContents(contentsRoot);
  await mkdir(outputDir, { recursive: true });
  const destination = resolve(outputDir, artifact.file);
  const evidencePath = resolve(outputDir, stageEvidenceName(artifact.file));
  await assertPathAbsent(destination);
  await assertPathAbsent(evidencePath);
  await copyFile(inputPath, destination);
  await writeFile(
    evidencePath,
    `${JSON.stringify({ ...stageEvidenceFor(artifact), hostRuntimeVerification: verification }, null, 2)}\n`,
  );
  return {
    ...artifact,
    path: destination,
    evidencePath,
    hostRuntimeVerification: verification,
  };
}

function expectedStageNames(expectedArtifacts) {
  return new Set(
    expectedArtifacts.flatMap((artifact) => [artifact.file, stageEvidenceName(artifact.file)]),
  );
}

async function parseStageEvidence(path, expectedArtifact) {
  const source = await readFile(path, 'utf8');
  if (!source.endsWith('\n')) throw new Error(`Stage evidence ${basename(path)} must end in a newline.`);
  const evidence = JSON.parse(source);
  const expectedKeys = [
    'file',
    'hostRuntimeIncluded',
    'hostRuntimeVerification',
    'schemaVersion',
    'target',
  ];
  if (JSON.stringify(Object.keys(evidence).sort()) !== JSON.stringify(expectedKeys)) {
    throw new Error(`Stage evidence ${basename(path)} has unexpected or missing fields.`);
  }
  if (
    evidence.schemaVersion !== 1 ||
    evidence.target !== expectedArtifact.id ||
    evidence.file !== expectedArtifact.file ||
    evidence.hostRuntimeIncluded !== false ||
    JSON.stringify(evidence.hostRuntimeVerification) !== JSON.stringify(hostRuntimeVerification)
  ) {
    throw new Error(`Stage evidence ${basename(path)} does not match its artifact.`);
  }
  return evidence.hostRuntimeVerification;
}

async function collectFlatInputs(inputDir, expectedArtifacts) {
  const expectedNames = expectedStageNames(expectedArtifacts);
  const foundPaths = new Map();
  for (const path of await walkFiles(inputDir)) {
    const info = await stat(path);
    if (info.size === 0) {
      throw new Error(`Zero-byte staged file is forbidden: ${relative(inputDir, path)}.`);
    }
    const name = basename(path);
    if (!expectedNames.has(name)) {
      throw new Error(`Unexpected staged artifact: ${relative(inputDir, path)}.`);
    }
    if (foundPaths.has(name)) throw new Error(`Duplicate staged artifact: ${name}.`);
    foundPaths.set(name, path);
  }
  const missing = [...expectedNames].filter((name) => !foundPaths.has(name));
  if (missing.length > 0) throw new Error(`Missing staged artifacts: ${missing.join(', ')}.`);
  return foundPaths;
}

async function collectWorkflowInputs(inputDir, expectedArtifacts, commit) {
  assertCommit(commit);
  const rootEntries = await readdir(inputDir, { withFileTypes: true });
  const expectedDirectories = workflowPlatforms.map(
    (platform) => `preview-${platform}-${commit}`,
  );
  const actualDirectories = [];
  for (const entry of rootEntries) {
    const path = resolve(inputDir, entry.name);
    const info = await lstat(path);
    if (info.isSymbolicLink()) throw new Error(`Symlink input is forbidden: ${path}.`);
    if (!info.isDirectory()) {
      throw new Error(`Workflow source root may contain only platform directories: ${entry.name}.`);
    }
    actualDirectories.push(entry.name);
  }
  if (
    JSON.stringify(actualDirectories.sort()) !== JSON.stringify([...expectedDirectories].sort())
  ) {
    throw new Error(
      `Workflow source layout must contain exactly: ${expectedDirectories.sort().join(', ')}.`,
    );
  }

  const expectedByName = new Map(expectedArtifacts.map((artifact) => [artifact.file, artifact]));
  const expectedNames = expectedStageNames(expectedArtifacts);
  const foundPaths = new Map();
  for (const platform of workflowPlatforms) {
    const directory = resolve(inputDir, `preview-${platform}-${commit}`);
    for (const path of await walkFiles(directory)) {
      const relativePath = relative(directory, path);
      if (relativePath.includes('/') || relativePath.includes('\\')) {
        throw new Error(`Workflow staged files must be at their platform root: ${relativePath}.`);
      }
      const info = await stat(path);
      if (info.size === 0) throw new Error(`Zero-byte staged file is forbidden: ${relativePath}.`);
      const name = basename(path);
      if (!expectedNames.has(name)) throw new Error(`Unexpected staged artifact: ${name}.`);
      if (foundPaths.has(name)) throw new Error(`Duplicate staged artifact: ${name}.`);
      const applicationName = name.endsWith(stageEvidenceSuffix)
        ? name.slice(0, -stageEvidenceSuffix.length)
        : name;
      const expectedArtifact = expectedByName.get(applicationName);
      if (!expectedArtifact || expectedArtifact.platform !== platform) {
        throw new Error(`Staged artifact ${name} came from the wrong platform source ${platform}.`);
      }
      foundPaths.set(name, path);
    }
  }
  const missing = [...expectedNames].filter((name) => !foundPaths.has(name));
  if (missing.length > 0) throw new Error(`Missing staged artifacts: ${missing.join(', ')}.`);
  return foundPaths;
}

async function collectApplicationInputs({
  inputDir,
  expectedArtifacts,
  sourceLayout,
  commit,
}) {
  if (!['flat', 'workflow'].includes(sourceLayout)) {
    throw new Error(`Unknown source layout: ${sourceLayout}.`);
  }
  const foundPaths =
    sourceLayout === 'workflow'
      ? await collectWorkflowInputs(inputDir, expectedArtifacts, commit)
      : await collectFlatInputs(inputDir, expectedArtifacts);
  const inputs = new Map();
  for (const artifact of expectedArtifacts) {
    const verification = await parseStageEvidence(
      foundPaths.get(stageEvidenceName(artifact.file)),
      artifact,
    );
    inputs.set(artifact.file, {
      path: foundPaths.get(artifact.file),
      hostRuntimeVerification: verification,
    });
  }
  return inputs;
}

function manifestFor({ contract, profile, artifacts, commit, flutterVersion }) {
  return {
    schemaVersion: 1,
    product: 'Pi Client',
    distribution: 'unsigned-preview',
    version: contract.version,
    buildNumber: contract.buildNumber,
    tag: contract.tag,
    artifactProfile: profile.id,
    commit,
    flutterVersion,
    artifacts,
  };
}

export async function assembleArtifacts({
  root,
  profileId,
  inputDir,
  outputDir,
  commit,
  flutterVersion = requiredFlutterVersion,
  sourceLayout = 'flat',
}) {
  assertCommit(commit);
  if (flutterVersion !== requiredFlutterVersion) {
    throw new Error(`Flutter version must be ${requiredFlutterVersion}.`);
  }
  ensureSeparateDirectories(inputDir, outputDir);
  const contract = await loadReleaseContract(root);
  const { profile, artifacts: expectedArtifacts } = selectProfile(contract, profileId);
  if (profile.immutableLegacy) {
    throw new Error(`${profile.id} is an immutable legacy release and cannot be reassembled.`);
  }
  const inputs = await collectApplicationInputs({
    inputDir,
    expectedArtifacts,
    sourceLayout,
    commit,
  });
  await rm(outputDir, { recursive: true, force: true });
  await mkdir(outputDir, { recursive: true });

  const manifestArtifacts = [];
  for (const artifact of [...expectedArtifacts].sort((a, b) =>
    a.file.localeCompare(b.file),
  )) {
    const input = inputs.get(artifact.file);
    const destination = resolve(outputDir, artifact.file);
    await copyFile(input.path, destination);
    const info = await stat(destination);
    manifestArtifacts.push({
      target: artifact.id,
      platform: artifact.platform,
      architecture: artifact.architecture,
      executionRole: artifact.executionRole,
      signing: artifact.signing,
      installability: artifact.installability,
      runtimeBaseline: artifact.runtimeBaseline,
      hostRuntimeIncluded: artifact.hostRuntimeIncluded,
      hostRuntimeVerification: input.hostRuntimeVerification,
      file: artifact.file,
      bytes: info.size,
      sha256: await sha256(destination),
    });
  }

  const manifest = manifestFor({
    contract,
    profile,
    artifacts: manifestArtifacts,
    commit,
    flutterVersion,
  });
  const manifestPath = resolve(outputDir, manifestName);
  await writeFile(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
  const checksumEntries = [
    ...manifestArtifacts.map(({ file, sha256: digest }) => ({ file, digest })),
    { file: manifestName, digest: await sha256(manifestPath) },
  ].sort((a, b) => a.file.localeCompare(b.file));
  await writeFile(
    resolve(outputDir, sumsName),
    checksumEntries.map(({ digest, file }) => `${digest}  ${file}\n`).join(''),
  );
  const primary = manifestArtifacts.find(({ target }) => target === profile.primaryTarget);
  await writeFile(
    resolve(outputDir, `${primary.file}.sha256`),
    `${primary.sha256}  ${primary.file}\n`,
  );
  await verifyArtifacts({
    root,
    profileId: profile.id,
    directory: outputDir,
    commit,
    flutterVersion,
  });
  return manifest;
}

function parseChecksumFile(source, label) {
  const entries = new Map();
  for (const line of source.split('\n')) {
    if (line === '') continue;
    const match = line.match(/^([0-9a-f]{64})  ([^/\\]+)$/);
    if (!match) throw new Error(`${label} contains an invalid checksum line.`);
    if (entries.has(match[2])) throw new Error(`${label} contains duplicate entry ${match[2]}.`);
    entries.set(match[2], match[1]);
  }
  return entries;
}

export async function verifyArtifacts({
  root,
  profileId,
  directory,
  commit,
  flutterVersion = requiredFlutterVersion,
}) {
  assertCommit(commit);
  const contract = await loadReleaseContract(root);
  if (flutterVersion !== contract.flutterVersion) {
    throw new Error(`Flutter version must match the release contract: ${contract.flutterVersion}.`);
  }
  const { profile, artifacts: expectedArtifacts } = selectProfile(contract, profileId);
  if (profile.immutableLegacy) {
    throw new Error(`${profile.id} is an immutable legacy release and has no assembled manifest.`);
  }
  const expectedFiles = releaseAssets(contract.version, profile).sort();
  const paths = await walkFiles(directory);
  const actualFiles = paths.map((path) => relative(directory, path));
  if (actualFiles.some((name) => name.includes('/') || name.includes('\\'))) {
    throw new Error('Assembled release files must be at the release directory root.');
  }
  if (JSON.stringify(actualFiles.sort()) !== JSON.stringify(expectedFiles)) {
    throw new Error(`Release file set mismatch. Expected ${expectedFiles.join(', ')}.`);
  }
  for (const path of paths) {
    if ((await stat(path)).size === 0) {
      throw new Error(`Zero-byte release file is forbidden: ${basename(path)}.`);
    }
  }

  const manifestSource = await readFile(resolve(directory, manifestName), 'utf8');
  if (!manifestSource.endsWith('\n')) {
    throw new Error('artifact-manifest.json must end with one newline.');
  }
  const manifest = JSON.parse(manifestSource);
  const expectedKeys = [
    'artifactProfile',
    'artifacts',
    'buildNumber',
    'commit',
    'distribution',
    'flutterVersion',
    'product',
    'schemaVersion',
    'tag',
    'version',
  ];
  if (JSON.stringify(Object.keys(manifest).sort()) !== JSON.stringify(expectedKeys)) {
    throw new Error('artifact-manifest.json contains unexpected or missing top-level fields.');
  }
  if (
    manifest.schemaVersion !== 1 ||
    manifest.product !== 'Pi Client' ||
    manifest.distribution !== 'unsigned-preview' ||
    manifest.version !== contract.version ||
    manifest.buildNumber !== contract.buildNumber ||
    manifest.tag !== contract.tag ||
    manifest.artifactProfile !== profile.id ||
    manifest.commit !== commit ||
    manifest.flutterVersion !== flutterVersion
  ) {
    throw new Error('artifact-manifest.json identity does not match the release contract.');
  }

  const expectedByFile = new Map(expectedArtifacts.map((artifact) => [artifact.file, artifact]));
  if (!Array.isArray(manifest.artifacts) || manifest.artifacts.length !== expectedArtifacts.length) {
    throw new Error('artifact-manifest.json artifact count is invalid.');
  }
  const sortedManifest = [...manifest.artifacts].sort((a, b) =>
    a.file.localeCompare(b.file),
  );
  if (JSON.stringify(manifest.artifacts) !== JSON.stringify(sortedManifest)) {
    throw new Error('artifact-manifest.json artifacts must be sorted by file name.');
  }
  for (const entry of manifest.artifacts) {
    const expected = expectedByFile.get(entry.file);
    if (!expected) throw new Error(`Unexpected manifest artifact ${entry.file}.`);
    const expectedEntryKeys = [
      'architecture',
      'bytes',
      'executionRole',
      'file',
      'hostRuntimeIncluded',
      'hostRuntimeVerification',
      'installability',
      'platform',
      'runtimeBaseline',
      'sha256',
      'signing',
      'target',
    ];
    if (JSON.stringify(Object.keys(entry).sort()) !== JSON.stringify(expectedEntryKeys)) {
      throw new Error(`Manifest entry ${entry.file} contains unexpected or missing fields.`);
    }
    for (const [key, value] of Object.entries({
      target: expected.id,
      platform: expected.platform,
      architecture: expected.architecture,
      executionRole: expected.executionRole,
      signing: expected.signing,
      installability: expected.installability,
      runtimeBaseline: expected.runtimeBaseline,
      hostRuntimeIncluded: false,
    })) {
      if (entry[key] !== value) throw new Error(`Manifest entry ${entry.file} has invalid ${key}.`);
    }
    if (
      JSON.stringify(entry.hostRuntimeVerification) !==
      JSON.stringify(hostRuntimeVerification)
    ) {
      throw new Error(`Manifest entry ${entry.file} has invalid hostRuntimeVerification.`);
    }
    const path = resolve(directory, entry.file);
    const info = await stat(path);
    if (entry.bytes !== info.size || entry.sha256 !== (await sha256(path))) {
      throw new Error(`Manifest digest or size mismatch for ${entry.file}.`);
    }
  }

  const sums = parseChecksumFile(
    await readFile(resolve(directory, sumsName), 'utf8'),
    sumsName,
  );
  const sumFiles = [...expectedByFile.keys(), manifestName].sort();
  if (JSON.stringify([...sums.keys()].sort()) !== JSON.stringify(sumFiles)) {
    throw new Error('SHA256SUMS file set is invalid.');
  }
  for (const file of sumFiles) {
    if (sums.get(file) !== (await sha256(resolve(directory, file)))) {
      throw new Error(`SHA256SUMS digest mismatch for ${file}.`);
    }
  }
  const primary = expectedArtifacts.find(({ id }) => id === profile.primaryTarget);
  const primarySums = parseChecksumFile(
    await readFile(resolve(directory, `${primary.file}.sha256`), 'utf8'),
    `${primary.file}.sha256`,
  );
  if (
    primarySums.size !== 1 ||
    primarySums.get(primary.file) !== (await sha256(resolve(directory, primary.file)))
  ) {
    throw new Error('Primary macOS checksum is invalid.');
  }
  return manifest;
}

function optionValue(args, name, required = true) {
  const index = args.indexOf(name);
  if (index === -1) {
    if (required) throw new Error(`${name} is required.`);
    return undefined;
  }
  const value = args[index + 1];
  if (!value || value.startsWith('--')) throw new Error(`${name} requires a value.`);
  return value;
}

async function main() {
  const [command, ...args] = process.argv.slice(2);
  const root = optionValue(args, '--root', false);
  const profileId = optionValue(args, '--profile');
  if (command === 'stage') {
    const result = await stageArtifact({
      root,
      profileId,
      targetId: optionValue(args, '--target'),
      inputPath: optionValue(args, '--input'),
      contentsRoot: optionValue(args, '--contents-root'),
      outputDir: optionValue(args, '--output-dir'),
    });
    console.log(JSON.stringify(result, null, 2));
    return;
  }
  if (command === 'assemble') {
    const manifest = await assembleArtifacts({
      root,
      profileId,
      inputDir: optionValue(args, '--input-dir'),
      outputDir: optionValue(args, '--output-dir'),
      commit: optionValue(args, '--commit'),
      flutterVersion: optionValue(args, '--flutter-version'),
      sourceLayout: optionValue(args, '--source-layout', false) ?? 'flat',
    });
    console.log(JSON.stringify(manifest, null, 2));
    return;
  }
  if (command === 'verify') {
    const manifest = await verifyArtifacts({
      root,
      profileId,
      directory: optionValue(args, '--directory'),
      commit: optionValue(args, '--commit'),
      flutterVersion: optionValue(args, '--flutter-version'),
    });
    console.log(JSON.stringify(manifest, null, 2));
    return;
  }
  throw new Error('Usage: preview_artifacts.mjs <stage|assemble|verify> [options].');
}

if (process.argv[1] && resolve(process.argv[1]) === resolve(import.meta.filename)) {
  await main();
}
