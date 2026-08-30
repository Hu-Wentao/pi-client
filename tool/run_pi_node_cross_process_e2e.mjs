import { access } from 'node:fs/promises';
import { spawnSync } from 'node:child_process';
import { resolve } from 'node:path';
import process from 'node:process';

const repositoryRoot = resolve(import.meta.dirname, '..');
const protocolRoot = resolve(repositoryRoot, 'protocol');
const nodeRoot = resolve(repositoryRoot, 'node');
const buildOnly = process.argv.slice(2).includes('--build-only');

const bunVersion = capture('bun', ['--version'], repositoryRoot);
if (bunVersion !== '1.4.0') {
  throw new Error(`Cross-process E2E requires Bun 1.4.0, received ${bunVersion}.`);
}

run('bun', ['install', '--frozen-lockfile'], protocolRoot);
run('bun', ['run', 'build:package'], protocolRoot);
run('bun', ['install', '--frozen-lockfile'], nodeRoot);
run(process.execPath, ['./scripts/assert-runtime.mjs'], nodeRoot);
run('bun', ['run', 'build:raw'], nodeRoot);

for (const artifact of [
  resolve(protocolRoot, 'dist/src/index.js'),
  resolve(nodeRoot, 'dist/index.js'),
  resolve(nodeRoot, 'dist/stdio-main.js'),
]) {
  await access(artifact);
}

if (!buildOnly) {
  run(
    'fvm',
    ['flutter', 'test', 'test/pi_node_cross_process_e2e_test.dart'],
    repositoryRoot,
    {
      PI_CLIENT_E2E_NODE_EXECUTABLE: process.execPath,
    },
  );
}

function run(command, arguments_, cwd, environment = {}) {
  const result = spawnSync(command, arguments_, {
    cwd,
    env: { ...process.env, ...environment },
    stdio: 'inherit',
  });
  if (result.error) {
    throw result.error;
  }
  if (result.status !== 0) {
    throw new Error(`${command} exited with status ${result.status}.`);
  }
}

function capture(command, arguments_, cwd) {
  const result = spawnSync(command, arguments_, {
    cwd,
    env: process.env,
    encoding: 'utf8',
  });
  if (result.error) {
    throw result.error;
  }
  if (result.status !== 0) {
    throw new Error(`${command} exited with status ${result.status}.`);
  }
  return result.stdout.trim();
}
