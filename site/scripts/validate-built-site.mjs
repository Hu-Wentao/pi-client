import { access, readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import {
  homebrewInstallCommand,
  loadReleaseContract,
} from '../../tool/release_contract.mjs';

const siteRoot = resolve(fileURLToPath(new URL('..', import.meta.url)));
const dist = resolve(siteRoot, 'dist');
const activeRelease = await loadReleaseContract();
const pages = [
  {
    path: resolve(dist, 'index.html'),
    lang: 'en',
    canonical: 'https://pi.wyattcoder.top/',
    identity: 'Independent cross-platform client',
    development: 'active development',
  },
  {
    path: resolve(dist, 'zh-cn/index.html'),
    lang: 'zh-CN',
    canonical: 'https://pi.wyattcoder.top/zh-cn/',
    identity: '独立跨平台客户端',
    development: '积极开发',
  },
];

for (const page of pages) {
  const html = await readFile(page.path, 'utf8');
  const assertions = [
    [`lang="${page.lang}"`, `html language ${page.lang}`],
    [`href="${page.canonical}"`, `canonical ${page.canonical}`],
    [page.identity, 'independent product identity'],
    [page.development, 'active-development status'],
    ['https://github.com/Hu-Wentao/pi-client', 'GitHub project link'],
    ['/assets/pi-client-mark.svg', 'root-relative product mark'],
    ['/assets/social-card.png', 'root-relative social card'],
    ['hreflang="en"', 'English hreflang'],
    ['hreflang="zh-CN"', 'Chinese hreflang'],
    ['<!--email_off-->', 'email-obfuscation exclusion'],
    ...['Android', 'iOS', 'macOS', 'Windows', 'Linux', 'Web'].map((platform) => [
      platform,
      `${platform} platform target`,
    ]),
  ];
  for (const [needle, label] of assertions) {
    if (!html.includes(needle)) {
      throw new Error(`${page.path} is missing ${label}.`);
    }
  }

  const forbidden = [
    [activeRelease.downloadUrl, 'current Preview download'],
    [activeRelease.tag, 'current Preview version'],
    [homebrewInstallCommand, 'Homebrew installation flow'],
    ['pi-web', 'legacy runtime name'],
    ['@agegr', 'legacy package owner'],
    ['pi_web', 'legacy credential or identifier'],
    ['v0.0.2', 'archived release version'],
    ['workspace-preview', 'retired workspace screenshot'],
  ];
  const lowerHtml = html.toLowerCase();
  for (const [needle, label] of forbidden) {
    if (lowerHtml.includes(needle.toLowerCase())) {
      throw new Error(`${page.path} must not expose ${label}.`);
    }
  }

  if (/(?:href|src)="\/pi-client\//.test(html)) {
    throw new Error(`${page.path} unexpectedly contains the retired /pi-client/ base path.`);
  }
  if (/<script(?:\s|>)/i.test(html)) {
    throw new Error(`${page.path} unexpectedly contains client JavaScript.`);
  }
}

await Promise.all([
  access(resolve(dist, 'assets/pi-client-mark.svg')),
  access(resolve(dist, 'assets/social-card.png')),
]);

console.log(
  'Validated bilingual independent-product routes, metadata, platform facts, legacy-content exclusion, assets, and zero client JavaScript.',
);
