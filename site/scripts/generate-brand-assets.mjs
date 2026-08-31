import { copyFile, mkdir, readFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import sharp from 'sharp';

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const repositoryRoot = resolve(scriptDirectory, '../..');
const markSource = resolve(repositoryRoot, 'assets/brand/pi-client-mark.svg');
const socialCardSource = resolve(repositoryRoot, 'assets/brand/social-card.svg');
const publicAssets = resolve(repositoryRoot, 'site/public/assets');
const appIconDirectory = resolve(
  repositoryRoot,
  'macos/Runner/Assets.xcassets/AppIcon.appiconset',
);

await Promise.all([mkdir(publicAssets, { recursive: true }), mkdir(appIconDirectory, { recursive: true })]);
await copyFile(markSource, resolve(publicAssets, 'pi-client-mark.svg'));

const mark = await readFile(markSource);
const iconSizes = [16, 32, 64, 128, 256, 512, 1024];
await Promise.all(
  iconSizes.map((size) =>
    sharp(mark, { density: 384 })
      .resize(size, size, { fit: 'fill' })
      .png({ compressionLevel: 9, palette: false })
      .toFile(resolve(appIconDirectory, `app_icon_${size}.png`)),
  ),
);

await sharp(await readFile(socialCardSource), { density: 192 })
  .resize(1200, 630, { fit: 'fill' })
  .png({ compressionLevel: 9, palette: false })
  .toFile(resolve(publicAssets, 'social-card.png'));

console.log('Generated Pi Client favicon, macOS app icons, and social card.');
