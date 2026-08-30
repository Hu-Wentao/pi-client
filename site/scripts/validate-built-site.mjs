import { access, readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const siteRoot = resolve(fileURLToPath(new URL('..', import.meta.url)));
const dist = resolve(siteRoot, 'dist');
const expectedDownload =
  'https://github.com/Hu-Wentao/pi-client/releases/download/v0.0.2/Pi-Client-0.0.2-macOS-universal.zip';
const pages = [
  {
    path: resolve(dist, 'index.html'),
    lang: 'en',
    canonical: 'https://hu-wentao.github.io/pi-client/',
  },
  {
    path: resolve(dist, 'zh-cn/index.html'),
    lang: 'zh-CN',
    canonical: 'https://hu-wentao.github.io/pi-client/zh-cn/',
  },
];

for (const page of pages) {
  const html = await readFile(page.path, 'utf8');
  const assertions = [
    [`lang=\"${page.lang}\"`, `html language ${page.lang}`],
    [`href=\"${page.canonical}\"`, `canonical ${page.canonical}`],
    [expectedDownload, 'exact release download'],
    ['/pi-client/assets/pi-client-mark.svg', 'base-aware product mark'],
    ['/pi-client/assets/workspace-preview.png', 'base-aware screenshot'],
    ['hreflang=\"en\"', 'English hreflang'],
    ['hreflang=\"zh-CN\"', 'Chinese hreflang'],
  ];
  for (const [needle, label] of assertions) {
    if (!html.includes(needle)) {
      throw new Error(`${page.path} is missing ${label}.`);
    }
  }
  if (/<script(?:\s|>)/i.test(html)) {
    throw new Error(`${page.path} unexpectedly contains client JavaScript.`);
  }
}

await Promise.all([
  access(resolve(dist, 'assets/pi-client-mark.svg')),
  access(resolve(dist, 'assets/workspace-preview.png')),
  access(resolve(dist, 'assets/social-card.png')),
]);

console.log('Validated bilingual routes, metadata, release CTA, assets, and zero client JavaScript.');
