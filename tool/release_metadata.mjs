import { appendFile, readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import process from 'node:process';

const repositoryRoot = resolve(import.meta.dirname, '..');
const pubspec = await readFile(resolve(repositoryRoot, 'pubspec.yaml'), 'utf8');
const versionMatch = pubspec.match(/^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$/m);
if (!versionMatch) {
  throw new Error('pubspec.yaml must contain a MAJOR.MINOR.PATCH+BUILD version.');
}

const [, version, buildNumber] = versionMatch;
const tag = `v${version}`;
const asset = `Pi-Client-${version}-macOS-universal.zip`;
const checksumAsset = `${asset}.sha256`;
const downloadUrl = `https://github.com/Hu-Wentao/pi-client/releases/download/${tag}/${asset}`;
const expected = {
  version: '0.0.2',
  buildNumber: '2',
  tag: 'v0.0.2',
  asset: 'Pi-Client-0.0.2-macOS-universal.zip',
};

for (const [field, expectedValue] of Object.entries(expected)) {
  const actualValue = { version, buildNumber, tag, asset }[field];
  if (actualValue !== expectedValue) {
    throw new Error(`Expected ${field}=${expectedValue}, received ${actualValue}.`);
  }
}

const sitePackage = JSON.parse(
  await readFile(resolve(repositoryRoot, 'site/package.json'), 'utf8'),
);
if (sitePackage.version !== version) {
  throw new Error(
    `Expected site/package.json version=${version}, received ${sitePackage.version}.`,
  );
}

const siteCopy = await readFile(
  resolve(repositoryRoot, 'site/src/content/copy.ts'),
  'utf8',
);
for (const value of [version, tag, asset, downloadUrl]) {
  if (!siteCopy.includes(value)) {
    throw new Error(`Landing-page release metadata is missing ${value}.`);
  }
}

const metadata = {
  version,
  buildNumber,
  tag,
  asset,
  checksumAsset,
  downloadUrl,
};

const outputArgument = process.argv.indexOf('--github-output');
if (outputArgument !== -1) {
  const outputPath = process.argv[outputArgument + 1];
  if (!outputPath) throw new Error('--github-output requires a path.');
  await appendFile(
    outputPath,
    `${Object.entries(metadata)
      .map(([key, value]) => `${key}=${value}`)
      .join('\n')}\n`,
  );
}

console.log(JSON.stringify(metadata, null, 2));
