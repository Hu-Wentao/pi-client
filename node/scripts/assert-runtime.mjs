const minimumNodeVersion = [22, 19, 0];

function parseVersion(version) {
  const match = /^(?:v)?(\d+)\.(\d+)\.(\d+)(?:[-+].*)?$/.exec(version);
  if (!match) {
    throw new Error(`Cannot parse Node.js version: ${version}`);
  }

  return match.slice(1, 4).map(Number);
}

function compareVersions(left, right) {
  for (let index = 0; index < 3; index += 1) {
    const difference = left[index] - right[index];
    if (difference !== 0) {
      return difference;
    }
  }
  return 0;
}

const currentNodeVersion = parseVersion(process.versions.node);
if (compareVersions(currentNodeVersion, minimumNodeVersion) < 0) {
  console.error(
    `Pi Node requires Node.js >=${minimumNodeVersion.join(".")}; found ${process.versions.node}.`,
  );
  process.exit(1);
}

console.log(`Node.js ${process.versions.node} satisfies >=${minimumNodeVersion.join(".")}.`);
