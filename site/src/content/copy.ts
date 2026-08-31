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
  statusDetailsLabel: string;
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
    primaryAction: string;
    source: string;
    statusNote: string;
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
    architectureNote: string;
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
    source: string;
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

export const copy: Record<Locale, LandingCopy> = {
  en: {
    locale: 'en',
    htmlLang: 'en',
    metaTitle: 'Pi Client — Independent cross-platform client for pi',
    metaDescription:
      'Explore the independent Pi Client source, first-party Pi Node architecture, and current development status.',
    languageLabel: 'Language',
    languageHref: '/zh-cn/',
    languageName: '简体中文',
    homeLabel: 'Pi Client home',
    navigationLabel: 'Primary navigation',
    statusDetailsLabel: 'Source status',
    projectLinksLabel: 'Project links',
    socialImageAlt: 'Pi Client product mark and independent Flutter workspace',
    nav: {
      features: 'Features',
      workflow: 'How it works',
      security: 'Security',
      github: 'GitHub',
    },
    hero: {
      eyebrow: 'Independent workspace for pi',
      title: 'Stay focused on the session, not the terminal plumbing.',
      description:
        'Pi Client brings session browsing, prompts, live output, and run control into an independent Flutter workspace. Current source targets six platforms, with Local Direct hosting on desktop.',
      badges: ['Six-platform source', 'Desktop Local Direct', 'First-party Pi Node'],
      primaryAction: 'View source repository',
      source: 'Read setup guide',
      statusNote: 'Current source is under development and is not a supported public release.',
    },
    screenshotAlt:
      'Pi Client window showing synthetic sessions and a sanitized coding-agent conversation.',
    screenshotCaption:
      'A real Flutter render with synthetic project paths, sessions, prompts, and agent output.',
    warning: {
      title: 'No supported public release is available.',
      body:
        'The repository contains development source, not a supported binary release. Build it locally only if you are prepared to use development tooling and evaluate the current source yourself.',
    },
    features: {
      eyebrow: 'Current capabilities',
      title: 'The essential session loop in one window.',
      description:
        'The current source implements the core session loop through project-owned APIs and runtime boundaries.',
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
      title: 'A native client with a first-party runtime boundary.',
      description:
        'Desktop Pi Client uses Local Direct and the project-owned protocol to reach the first-party Pi Node.',
      client: 'Pi Client',
      bridge: 'Project-owned protocol',
      runtime: 'Pi Node runtime Capsule',
      architectureNote:
        'Release packages must bundle and verify the runtime Capsule. Source development uses explicitly configured local process paths; Web and mobile remain connect-only.',
    },
    start: {
      eyebrow: 'Get started',
      title: 'Build the current source for development.',
      description:
        'You need macOS 11 or newer, FVM, Bun, the native macOS toolchain, and a working pi model-provider configuration.',
      steps: [
        {
          number: '01',
          title: 'Clone and inspect the source',
          description: 'Clone the repository, then review its README and contributing guidance.',
        },
        {
          number: '02',
          title: 'Install all development dependencies',
          description: 'Install the Flutter, Protocol, and Pi Node dependencies with the pinned toolchains.',
        },
        {
          number: '03',
          title: 'Run the documented development command',
          description:
            'Use the README command that supplies explicit local Pi Node process paths; ordinary source builds do not contain a runtime Capsule.',
        },
      ],
      fullGuide: 'Read the complete setup guide',
    },
    security: {
      eyebrow: 'Security boundary',
      title: 'Keep execution local and explicit.',
      description:
        'Local Direct connects desktop Pi Client to Pi Node, which runs with the host process’s project and tool permissions.',
      points: [
        'Packaged desktop applications must verify the runtime Capsule before Pi Node starts.',
        'Local Direct does not require a separately installed network gateway.',
        'The project-owned protocol defines the complete client-to-node boundary.',
        'Pi Client excludes credentials, provider data, prompts, and tool data from transport logs.',
      ],
    },
    limitations: {
      title: 'Current source limitations',
      points: [
        'No supported public binary release is available.',
        'The project-owned protocol remains pre-1.0 and may change during development.',
        'Mobile and Web remote transport is not implemented.',
        'Provider-backed production recovery and complete desktop packaging are not yet accepted.',
        'The remaining project-owned requirements for 1.0 are incomplete.',
      ],
    },
    closing: {
      title: 'Explore the source and follow development in public.',
      description:
        'Pi Client is open source and early. No supported public release is currently available; use GitHub Issues for bugs and development feedback.',
      source: 'View source repository',
      issues: 'Open GitHub Issues',
    },
    footer: {
      description: 'An independent open-source client for the pi coding agent.',
      readme: 'README',
      contributing: 'Contributing',
      license: 'MIT License',
      issues: 'Issues',
      attribution:
        'Pi Client ships its first-party Pi Node through a project-owned protocol and is an independent open-source project.',
    },
  },
  'zh-cn': {
    locale: 'zh-cn',
    htmlLang: 'zh-CN',
    metaTitle: 'Pi Client — 面向 pi 的独立跨平台客户端',
    metaDescription:
      '了解独立 Pi Client 源代码、第一方 Pi Node 架构和当前开发状态。',
    languageLabel: '语言',
    languageHref: '/',
    languageName: 'English',
    homeLabel: 'Pi Client 首页',
    navigationLabel: '主要导航',
    statusDetailsLabel: '源代码状态',
    projectLinksLabel: '项目链接',
    socialImageAlt: 'Pi Client 产品标识和独立 Flutter 工作区',
    nav: {
      features: '功能',
      workflow: '工作方式',
      security: '安全',
      github: 'GitHub',
    },
    hero: {
      eyebrow: '面向 pi 的独立工作区',
      title: '专注于会话，而不是终端连接细节。',
      description:
        'Pi Client 将会话浏览、提示词、实时输出和运行控制集中到独立 Flutter 工作区。当前源代码面向六个平台，桌面端通过 Local Direct 承载运行时。',
      badges: ['六平台源代码', '桌面 Local Direct', '第一方 Pi Node'],
      primaryAction: '查看源代码仓库',
      source: '阅读设置指南',
      statusNote: '当前源代码仍在开发中，不是受支持的公开发布版本。',
    },
    screenshotAlt: 'Pi Client 窗口，其中显示合成会话和经过脱敏的编码 Agent 对话。',
    screenshotCaption: '真实 Flutter 渲染；项目路径、会话、提示词和 Agent 输出均为合成数据。',
    warning: {
      title: '当前没有受支持的公开发布版本。',
      body:
        '仓库提供的是开发中源代码，而不是受支持的二进制发布版本。仅在你能够使用开发工具并自行评估当前源代码时进行本地构建。',
    },
    features: {
      eyebrow: '当前能力',
      title: '在一个窗口中完成核心会话循环。',
      description: '当前源代码通过项目自有 API 和运行时边界实现核心会话循环。',
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
      title: '采用第一方运行时边界的原生客户端。',
      description:
        '桌面 Pi Client 通过 Local Direct 和项目自有协议连接第一方 Pi Node。',
      client: 'Pi Client',
      bridge: '项目自有协议',
      runtime: 'Pi Node 运行时 Capsule',
      architectureNote:
        '发布包必须内置并验证运行时 Capsule；源码开发使用显式配置的本地进程路径。Web 和移动端仍仅支持连接。',
    },
    start: {
      eyebrow: '开始使用',
      title: '从当前源代码进行开发构建。',
      description:
        '你需要 macOS 11 或更高版本、FVM、Bun、macOS 原生工具链以及可用的 pi 模型 Provider 配置。',
      steps: [
        {
          number: '01',
          title: '克隆并检查源代码',
          description: '克隆仓库，然后阅读 README 和贡献指南。',
        },
        {
          number: '02',
          title: '安装全部开发依赖',
          description: '使用锁定的工具链安装 Flutter、Protocol 和 Pi Node 依赖。',
        },
        {
          number: '03',
          title: '运行文档中的开发命令',
          description: '使用 README 中显式提供本地 Pi Node 进程路径的命令；普通源码构建不包含运行时 Capsule。',
        },
      ],
      fullGuide: '阅读完整设置指南',
    },
    security: {
      eyebrow: '安全边界',
      title: '保持本地执行边界明确。',
      description:
        'Local Direct 将桌面 Pi Client 连接到 Pi Node；Pi Node 具有宿主进程的项目与工具权限。',
      points: [
        '打包后的桌面应用必须在 Pi Node 启动前验证运行时 Capsule。',
        'Local Direct 不需要单独安装网络网关。',
        '项目自有协议定义完整的客户端到节点边界。',
        'Pi Client 不会将凭据、Provider 数据、提示词或工具数据写入传输日志。',
      ],
    },
    limitations: {
      title: '当前源代码限制',
      points: [
        '当前没有受支持的公开二进制发布版本。',
        '项目自有协议仍处于 1.0 之前，可能在开发期间发生变化。',
        '移动端和 Web 远程传输尚未实现。',
        'Provider 支持的生产恢复流程和完整桌面打包尚未通过验收。',
        '其余项目自有 1.0 需求仍未完成。',
      ],
    },
    closing: {
      title: '浏览源代码并公开关注开发进展。',
      description: 'Pi Client 是早期开放源代码项目，当前没有受支持的公开发布版本。请通过 GitHub Issues 报告缺陷和开发反馈。',
      source: '查看源代码仓库',
      issues: '打开 GitHub Issues',
    },
    footer: {
      description: '面向 pi coding agent 的独立开放源代码客户端。',
      readme: 'README',
      contributing: '参与贡献',
      license: 'MIT License',
      issues: 'Issues',
      attribution:
        'Pi Client 通过项目自有协议交付第一方 Pi Node，是独立的开放源代码项目。'
    },
  },
};
