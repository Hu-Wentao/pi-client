export type Locale = 'en' | 'zh-cn';

type Feature = {
  title: string;
  description: string;
  icon: 'sessions' | 'prompt' | 'stream' | 'stop';
};

type Step = {
  number: string;
  title: string;
  description: string;
};

export type LandingCopy = {
  locale: Locale;
  htmlLang: string;
  metaTitle: string;
  metaDescription: string;
  languageLabel: string;
  languageHref: string;
  languageName: string;
  homeLabel: string;
  navigationLabel: string;
  releaseDetailsLabel: string;
  projectLinksLabel: string;
  socialImageAlt: string;
  nav: {
    features: string;
    workflow: string;
    security: string;
    github: string;
  };
  hero: {
    eyebrow: string;
    title: string;
    description: string;
    badges: string[];
    download: string;
    source: string;
    releaseNote: string;
  };
  screenshotAlt: string;
  screenshotCaption: string;
  warning: {
    title: string;
    body: string;
  };
  features: {
    eyebrow: string;
    title: string;
    description: string;
    items: Feature[];
  };
  workflow: {
    eyebrow: string;
    title: string;
    description: string;
    client: string;
    bridge: string;
    runtime: string;
    transitional: string;
  };
  start: {
    eyebrow: string;
    title: string;
    description: string;
    steps: Step[];
    fullGuide: string;
  };
  security: {
    eyebrow: string;
    title: string;
    description: string;
    points: string[];
  };
  limitations: {
    title: string;
    points: string[];
  };
  closing: {
    title: string;
    description: string;
    download: string;
    issues: string;
  };
  footer: {
    description: string;
    readme: string;
    contributing: string;
    license: string;
    issues: string;
    attribution: string;
  };
};

export const release = {
  version: '0.0.2',
  tag: 'v0.0.2',
  asset: 'Pi-Client-0.0.2-macOS-universal.zip',
  downloadUrl:
    'https://github.com/Hu-Wentao/pi-client/releases/download/v0.0.2/Pi-Client-0.0.2-macOS-universal.zip',
  releaseUrl: 'https://github.com/Hu-Wentao/pi-client/releases/tag/v0.0.2',
} as const;

export const copy: Record<Locale, LandingCopy> = {
  en: {
    locale: 'en',
    htmlLang: 'en',
    metaTitle: 'Pi Client — Native macOS workspace for pi',
    metaDescription:
      'Browse pi sessions, send prompts, and follow live agent output in an early native macOS client.',
    languageLabel: 'Language',
    languageHref: '/zh-cn/',
    languageName: '简体中文',
    homeLabel: 'Pi Client home',
    navigationLabel: 'Primary navigation',
    releaseDetailsLabel: 'Release details',
    projectLinksLabel: 'Project links',
    socialImageAlt: 'Pi Client product mark and native macOS workspace',
    nav: {
      features: 'Features',
      workflow: 'How it works',
      security: 'Security',
      github: 'GitHub',
    },
    hero: {
      eyebrow: 'Native workspace for pi',
      title: 'Stay focused on the session, not the terminal plumbing.',
      description:
        'Pi Client brings session browsing, prompts, live output, and run control into an early native macOS workspace.',
      badges: ['macOS 11+', 'Universal app', 'Version 0.0.2'],
      download: 'Download unsigned preview',
      source: 'View on GitHub',
      releaseNote: 'Universal ZIP for Apple silicon and Intel Macs',
    },
    screenshotAlt:
      'Pi Client window showing synthetic sessions and a sanitized coding-agent conversation.',
    screenshotCaption:
      'A real Flutter render with synthetic project paths, sessions, prompts, and agent output.',
    warning: {
      title: 'This download is an unsigned preview.',
      body:
        'The app is not signed with an Apple Developer ID and is not notarized. macOS Gatekeeper will warn before opening it. Install it only if you trust this repository. A signed, notarized DMG is not available yet.',
    },
    features: {
      eyebrow: 'Current capabilities',
      title: 'The essential session loop in one window.',
      description:
        'The preview focuses on the actions already supported by the current macOS MVP.',
      items: [
        {
          icon: 'sessions',
          title: 'Browse sessions',
          description:
            'Refresh session summaries, open a conversation, and read visible message history.',
        },
        {
          icon: 'prompt',
          title: 'Create and continue work',
          description:
            'Create a session for an absolute project path and send the next prompt.',
        },
        {
          icon: 'stream',
          title: 'Follow live output',
          description:
            'Watch assistant updates arrive through the selected session event stream.',
        },
        {
          icon: 'stop',
          title: 'Stop an active run',
          description:
            'Interrupt the current agent run without leaving the desktop workspace.',
        },
      ],
    },
    workflow: {
      eyebrow: 'How it works today',
      title: 'A native client over a transitional compatibility bridge.',
      description:
        'The current preview uses pi-web 0.8.11 for session and runtime access. Pi Client does not read pi session files directly.',
      client: 'Pi Client',
      bridge: 'pi-web 0.8.11',
      runtime: 'pi runtime',
      transitional:
        'Pi-web compatibility is an early bridge, not Pi Client’s long-term product identity. A future versioned, Pi SDK-based transport remains planned; this release does not include WebAssembly support.',
    },
    start: {
      eyebrow: 'Get started',
      title: 'Run the preview with your existing pi setup.',
      description:
        'You need macOS 11 or newer, pi-web 0.8.11, and a working pi model-provider configuration.',
      steps: [
        {
          number: '01',
          title: 'Start pi-web',
          description: 'Run `npx @agegr/pi-web@0.8.11 --no-open` and keep it available.',
        },
        {
          number: '02',
          title: 'Download Pi Client',
          description:
            'Download the Universal ZIP, extract `Pi Client.app`, and review the unsigned-preview warning.',
        },
        {
          number: '03',
          title: 'Connect and work',
          description:
            'Open the app, enter the pi-web URL and optional password, then select Connect.',
        },
      ],
      fullGuide: 'Read the complete setup guide',
    },
    security: {
      eyebrow: 'Security boundary',
      title: 'Keep the agent endpoint private.',
      description:
        'Pi-web can expose an agent with the host process’s project and tool permissions. Treat the endpoint as privileged infrastructure.',
      points: [
        'Keep pi-web on loopback unless remote access is intentional.',
        'For remote access, use HTTPS through a trusted reverse proxy or a VPN.',
        'Use a strong PI_WEB_PASSWORD, but do not rely on Basic Authentication to encrypt traffic.',
        'Pi Client keeps the password in memory and excludes it from workspace state, URLs, and payload logs.',
      ],
    },
    limitations: {
      title: 'Preview limitations',
      points: [
        'macOS only; no browser or WebAssembly client is included.',
        'Unsigned and unnotarized; Gatekeeper warnings are expected.',
        'Compatible with observed pi-web 0.8.11 behavior, which is not a declared stable API.',
        'No model, provider, skill, plugin, file, Git, or worktree management.',
        'No session rename, deletion, export, branching, rich Markdown, or media rendering.',
      ],
    },
    closing: {
      title: 'Try the macOS preview or follow the project in public.',
      description:
        'Pi Client is open source and early. Use GitHub Issues for bugs, compatibility reports, and feature requests.',
      download: 'Download version 0.0.2',
      issues: 'Open GitHub Issues',
    },
    footer: {
      description: 'An independent open-source client for the pi coding agent.',
      readme: 'README',
      contributing: 'Contributing',
      license: 'MIT License',
      issues: 'Issues',
      attribution:
        'Current compatibility is based on observable pi-web 0.8.11 behavior. Pi Client is not an official pi or pi-web product.',
    },
  },
  'zh-cn': {
    locale: 'zh-cn',
    htmlLang: 'zh-CN',
    metaTitle: 'Pi Client — 面向 pi 的原生 macOS 工作区',
    metaDescription:
      '在早期原生 macOS 客户端中浏览 pi 会话、发送提示词并查看实时 Agent 输出。',
    languageLabel: '语言',
    languageHref: '/',
    languageName: 'English',
    homeLabel: 'Pi Client 首页',
    navigationLabel: '主要导航',
    releaseDetailsLabel: '发布信息',
    projectLinksLabel: '项目链接',
    socialImageAlt: 'Pi Client 产品标识和原生 macOS 工作区',
    nav: {
      features: '功能',
      workflow: '工作方式',
      security: '安全',
      github: 'GitHub',
    },
    hero: {
      eyebrow: '面向 pi 的原生工作区',
      title: '专注于会话，而不是终端连接细节。',
      description:
        'Pi Client 将会话浏览、提示词、实时输出和运行控制集中到一个早期原生 macOS 工作区中。',
      badges: ['macOS 11+', 'Universal 应用', '版本 0.0.2'],
      download: '下载未签名预览版',
      source: '在 GitHub 查看',
      releaseNote: '同时支持 Apple 芯片和 Intel Mac 的 Universal ZIP',
    },
    screenshotAlt: 'Pi Client 窗口，其中显示合成会话和经过脱敏的编码 Agent 对话。',
    screenshotCaption: '真实 Flutter 渲染；项目路径、会话、提示词和 Agent 输出均为合成数据。',
    warning: {
      title: '此下载是未签名预览版。',
      body:
        '应用没有 Apple Developer ID 签名，也没有经过公证。macOS Gatekeeper 会在打开前发出警告。仅在你信任此仓库时安装。当前尚未提供已签名、已公证的 DMG。',
    },
    features: {
      eyebrow: '当前能力',
      title: '在一个窗口中完成核心会话循环。',
      description: '预览版聚焦于当前 macOS MVP 已支持的操作。',
      items: [
        {
          icon: 'sessions',
          title: '浏览会话',
          description: '刷新会话摘要、打开对话并阅读可见消息历史。',
        },
        {
          icon: 'prompt',
          title: '创建并继续工作',
          description: '为绝对项目路径创建会话，并发送下一条提示词。',
        },
        {
          icon: 'stream',
          title: '查看实时输出',
          description: '通过所选会话的事件流查看 Assistant 持续更新。',
        },
        {
          icon: 'stop',
          title: '停止运行',
          description: '无需离开桌面工作区即可中断当前 Agent 运行。',
        },
      ],
    },
    workflow: {
      eyebrow: '当前工作方式',
      title: '通过过渡兼容桥接工作的原生客户端。',
      description:
        '当前预览版使用 pi-web 0.8.11 访问会话和运行时。Pi Client 不会直接读取 pi 会话文件。',
      client: 'Pi Client',
      bridge: 'pi-web 0.8.11',
      runtime: 'pi runtime',
      transitional:
        'Pi-web 兼容层只是早期桥接，并非 Pi Client 的长期产品身份。未来版本化、基于 Pi SDK 的传输仍处于规划阶段；本次发布不包含 WebAssembly 支持。'
    },
    start: {
      eyebrow: '开始使用',
      title: '通过现有 pi 环境运行预览版。',
      description:
        '你需要 macOS 11 或更高版本、pi-web 0.8.11，以及可用的 pi 模型 Provider 配置。',
      steps: [
        {
          number: '01',
          title: '启动 pi-web',
          description: '运行 `npx @agegr/pi-web@0.8.11 --no-open` 并保持服务可用。',
        },
        {
          number: '02',
          title: '下载 Pi Client',
          description: '下载 Universal ZIP，解压 `Pi Client.app`，并阅读未签名预览版警告。',
        },
        {
          number: '03',
          title: '连接并开始工作',
          description: '打开应用，输入 pi-web 地址和可选密码，然后选择 Connect。',
        },
      ],
      fullGuide: '阅读完整设置指南',
    },
    security: {
      eyebrow: '安全边界',
      title: '保持 Agent 端点私有。',
      description:
        'Pi-web 可以暴露具有宿主进程项目与工具权限的 Agent。请将该端点视为特权基础设施。',
      points: [
        '除非明确需要远程访问，否则让 pi-web 仅监听回环地址。',
        '远程访问时，通过可信反向代理使用 HTTPS，或使用 VPN。',
        '设置高强度 PI_WEB_PASSWORD，但不要依赖 Basic Authentication 加密流量。',
        'Pi Client 仅在内存中保留密码，并将其排除在工作区状态、URL 和 Payload 日志之外。',
      ],
    },
    limitations: {
      title: '预览版限制',
      points: [
        '仅支持 macOS；不包含浏览器或 WebAssembly 客户端。',
        '未签名且未公证；出现 Gatekeeper 警告属于预期行为。',
        '兼容观测到的 pi-web 0.8.11 行为；该行为并非已声明的稳定 API。',
        '不提供模型、Provider、Skill、插件、文件、Git 或 worktree 管理。',
        '不提供会话重命名、删除、导出、分支、富 Markdown 或媒体渲染。',
      ],
    },
    closing: {
      title: '试用 macOS 预览版，或在公开仓库关注项目。',
      description: 'Pi Client 是早期开放源代码项目。请通过 GitHub Issues 报告缺陷、兼容问题和功能建议。',
      download: '下载 0.0.2 版本',
      issues: '打开 GitHub Issues',
    },
    footer: {
      description: '面向 pi coding agent 的独立开放源代码客户端。',
      readme: 'README',
      contributing: '参与贡献',
      license: 'MIT License',
      issues: 'Issues',
      attribution:
        '当前兼容性基于对 pi-web 0.8.11 行为的观测。Pi Client 不是 pi 或 pi-web 的官方产品。',
    },
  },
};
