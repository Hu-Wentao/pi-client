import { access, readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const siteRoot = resolve(fileURLToPath(new URL('..', import.meta.url)));
const dist = resolve(siteRoot, 'dist');
const repositoryUrl = 'https://github.com/Hu-Wentao/pi-client';
const pages = [
  {
    path: resolve(dist, 'index.html'),
    lang: 'en',
    canonical: 'https://wyattcoder.top/pi-client/',
    currentCopy: [
      'Current source is under development and is not a supported public release.',
      'View source repository',
      'Local Direct',
      'Protobuf · Pi Protocol',
      'Project-owned protocol',
      'Pi Node runtime Capsule',
      'first-party Pi Node',
      'Run the documented development command',
      'ordinary source builds do not contain a runtime Capsule',
    ],
  },
  {
    path: resolve(dist, 'zh-cn/index.html'),
    lang: 'zh-CN',
    canonical: 'https://wyattcoder.top/pi-client/zh-cn/',
    currentCopy: [
      '当前源代码仍在开发中，不是受支持的公开发布版本。',
      '查看源代码仓库',
      'Local Direct',
      'Protobuf · Pi Protocol',
      '项目自有协议',
      'Pi Node 运行时 Capsule',
      'first-party Pi Node',
      '运行文档中的开发命令',
      '普通源码构建不包含运行时 Capsule',
    ],
  },
];

const obsoleteFragments = [
  '/releases/download/',
  '0.0.2',
  '0.1.0',
  ['pi', 'web'].join('-'),
  ['pi', 'web'].join('_'),
  ['PI', 'WEB'].join('_'),
  'npx @agegr/',
  'optional password',
  '可选密码',
  'Basic Authentication',
  'Download unsigned preview',
  'Download the current preview',
  '下载未签名预览版',
  '下载当前预览版',
];

for (const page of pages) {
  const html = await readFile(page.path, 'utf8');
  const assertions = [
    [`lang=\"${page.lang}\"`, `html language ${page.lang}`],
    [`href=\"${page.canonical}\"`, `canonical ${page.canonical}`],
    [`href=\"${repositoryUrl}\"`, 'source repository CTA'],
    ['/pi-client/assets/pi-client-mark.svg', 'base-aware product mark'],
    ['/pi-client/assets/workspace-preview.webp', 'base-aware screenshot'],
    ['hreflang=\"en\"', 'English hreflang'],
    ['hreflang=\"zh-CN\"', 'Chinese hreflang'],
    ['<!--email_off-->', 'Cloudflare email-obfuscation exclusion'],
    ...page.currentCopy.map((needle) => [needle, `current source architecture wording: ${needle}`]),
  ];
  for (const [needle, label] of assertions) {
    if (!html.includes(needle)) {
      throw new Error(`${page.path} is missing ${label}.`);
    }
  }
  for (const obsolete of obsoleteFragments) {
    if (html.toLowerCase().includes(obsolete.toLowerCase())) {
      throw new Error(`${page.path} contains obsolete release, setup, or architecture wording: ${obsolete}.`);
    }
  }
  const visibleText = html.replace(/<[^>]+>/g, ' ');
  for (const obsoleteArchitecture of [/\bHTTP\b/i, /\bSSE\b/i, /\btransitional\b/i]) {
    if (obsoleteArchitecture.test(visibleText)) {
      throw new Error(
        `${page.path} contains obsolete visible architecture wording: ${obsoleteArchitecture}.`,
      );
    }
  }
  if (/<script(?:\s|>)/i.test(html)) {
    throw new Error(`${page.path} unexpectedly contains client JavaScript.`);
  }
}

await Promise.all([
  access(resolve(dist, 'assets/pi-client-mark.svg')),
  access(resolve(dist, 'assets/workspace-preview.webp')),
  access(resolve(dist, 'assets/social-card.png')),
]);

console.log(
  'Validated bilingual source-only status and CTAs, first-party Local Direct protocol architecture, assets, obsolete-term absence, and zero client JavaScript.',
);
