import { lstat, readdir, realpath } from 'node:fs/promises';
import { basename, relative, resolve, sep } from 'node:path';

const [, , input] = process.argv;
if (!input) {
  console.error('Usage: node assert-no-runtime-capsule.mjs <artifact-root>');
  process.exit(64);
}

const reservedSegments = new Set([
  'pinode',
  'pi-node',
  'pi_node',
  'node.exe',
  'capsule-manifest.json',
  'stdio-main.js',
  'pi-node-runtime-capsule',
]);
const root = resolve(input);
const canonicalRoot = await realpath(root);
const violations = [];

function isInsideRoot(path) {
  const offset = relative(canonicalRoot, path);
  return offset === '' || (!offset.startsWith(`..${sep}`) && offset !== '..' && !offset.includes(':'));
}

async function visit(directory) {
  for (const entry of await readdir(directory, { withFileTypes: true })) {
    const path = resolve(directory, entry.name);
    const normalized = basename(path).toLowerCase();
    for (const reserved of reservedSegments) {
      if (normalized === reserved || normalized.includes(reserved)) {
        violations.push(relative(root, path));
      }
    }
    const info = await lstat(path);
    if (info.isSymbolicLink()) {
      const target = await realpath(path);
      if (!isInsideRoot(target)) violations.push(`${relative(root, path)} -> ${target}`);
      continue;
    }
    if (info.isDirectory()) await visit(path);
  }
}

await visit(root);
if (violations.length > 0) {
  console.error(`Unexpected runtime Capsule content found under ${root}:`);
  for (const violation of [...new Set(violations)].sort()) console.error(`- ${violation}`);
  process.exit(1);
}
console.log(`Confirmed no runtime Capsule under ${root}.`);
