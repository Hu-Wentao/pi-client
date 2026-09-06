export type Locale = 'en' | 'zh-cn';

export type PrincipleIcon = 'code' | 'platforms' | 'roles' | 'open';

type Principle = {
  title: string;
  description: string;
  icon: PrincipleIcon;
};

type Role = {
  title: string;
  platforms: string;
  badge: string;
  description: string;
  publicDescription: string;
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
  projectLinksLabel: string;
  socialImageAlt: string;
  nav: {
    product: string;
    platforms: string;
    install: string;
    status: string;
    github: string;
  };
  hero: {
    eyebrow: string;
    title: string;
    description: string;
    badges: string[];
    primary: string;
    secondary: string;
    note: string;
    publicNote: string;
    platformLabel: string;
  };
  principles: {
    eyebrow: string;
    title: string;
    description: string;
    items: Principle[];
  };
  roles: {
    eyebrow: string;
    title: string;
    description: string;
    desktop: Role;
    connectOnly: Role;
    note: string;
    publicNote: string;
  };
  homebrew: {
    eyebrow: string;
    title: string;
    description: string;
    commandLabel: string;
    command: string;
    platform: string;
    note: string;
  };
  status: {
    eyebrow: string;
    title: string;
    description: string;
    items: string[];
    publicItems: string[];
    noticeTitle: string;
    noticeBody: string;
    publicNoticeBody: string;
  };
  closing: {
    title: string;
    description: string;
    source: string;
    contribute: string;
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
    metaTitle: 'Pi Client — Cross-platform Flutter client for pi',
    metaDescription:
      'An independent, open-source Flutter client for the pi coding agent across desktop, mobile, and web.',
    languageLabel: 'Language',
    languageHref: '/zh-cn/',
    languageName: '简体中文',
    homeLabel: 'Pi Client home',
    navigationLabel: 'Primary navigation',
    projectLinksLabel: 'Project links',
    socialImageAlt: 'Pi Client product mark with cross-platform product positioning',
    nav: {
      product: 'Product',
      platforms: 'Platforms',
      install: 'Install',
      status: 'Status',
      github: 'GitHub',
    },
    hero: {
      eyebrow: 'Independent cross-platform client',
      title: 'One Pi Client. Six platform targets.',
      description:
        'Pi Client is an independent, open-source Flutter client for the pi coding agent, built from one codebase for Android, iOS, macOS, Windows, Linux, and Web.',
      badges: ['Flutter', 'Six platform targets', 'Open source'],
      primary: 'Explore the source',
      secondary: 'Contribute',
      note: 'First-party Local Direct is implemented in source; supported public distribution is still under active development.',
      publicNote: 'The current macOS Preview is available through Homebrew; other platform distributions remain under active development.',
      platformLabel: 'Supported project targets',
    },
    principles: {
      eyebrow: 'Product foundation',
      title: 'A focused client with explicit platform boundaries.',
      description:
        'The repository separates verified source and contracts from runtime capabilities that are still being built.',
      items: [
        {
          icon: 'code',
          title: 'One Flutter codebase',
          description:
            'Shared product code and one version span six targets, while native configuration stays with each platform.',
        },
        {
          icon: 'platforms',
          title: 'Desktop, mobile, and web',
          description:
            'Android, iOS, macOS, Windows, Linux, and Web are maintained as targets of the same Pi Client product.',
        },
        {
          icon: 'roles',
          title: 'Clear execution roles',
          description:
            'Desktop targets are host-capable by contract. Android, iOS, and Web remain connect-only.',
        },
        {
          icon: 'open',
          title: 'Open development',
          description:
            'Architecture, source, issues, and contribution guidance stay visible in the public repository.',
        },
      ],
    },
    roles: {
      eyebrow: 'Platform roles',
      title: 'Capability follows the device boundary.',
      description:
        'Pi Client uses an application-wide platform contract instead of giving every target the same authority.',
      desktop: {
        title: 'Desktop clients',
        platforms: 'macOS · Windows · Linux',
        badge: 'Host-capable by contract',
        description:
          'Desktop source builds support first-party Local Direct and verified runtime Capsules. Supported public packages are still being qualified.',
        publicDescription:
          'The public macOS Preview is distributed through Homebrew with the first-party Runtime Capsule; Windows and Linux Preview packages remain in qualification.',
      },
      connectOnly: {
        title: 'Connect-only clients',
        platforms: 'Android · iOS · Web',
        badge: 'Connect-only',
        description:
          'Mobile and Web targets connect without embedding the Agent runtime or receiving host filesystem and tool-execution authority.',
        publicDescription:
          'Mobile and Web targets connect without embedding the Agent runtime or receiving host filesystem and tool-execution authority.',
      },
      note:
        'First-party host runtime Capsules are verified in source and candidate workflows, but no supported public package is currently promoted.',
      publicNote:
        'The public macOS Preview includes the first-party Host runtime Capsule; Android, iOS, and Web retain their connect-only boundary.',
    },
    homebrew: {
      eyebrow: 'macOS Preview',
      title: 'Install the current Preview with Homebrew.',
      description:
        'The official Pi Client Tap tracks the latest exact public macOS Preview. The command stays stable as the Tap advances.',
      commandLabel: 'Install with Homebrew',
      command: 'brew install --cask hu-wentao/tap/pi-client',
      platform: 'macOS 11 or newer',
      note:
        'This Preview is ad-hoc signed and not notarized. Homebrew preserves macOS quarantine; if Gatekeeper blocks the first launch, Control-click Pi Client.app in Finder, choose Open, and confirm. Do not disable Gatekeeper or remove quarantine metadata.',
    },
    status: {
      eyebrow: 'Current status',
      title: 'The independent product is in active development.',
      description:
        'The public repository already establishes the cross-platform project and its safety boundaries. Runtime delivery is tracked separately.',
      items: [
        'Flutter project directories are present for Android, iOS, macOS, Windows, Linux, and Web.',
        'Focused tests verify the desktop host-capable and mobile/Web connect-only role mapping.',
        'Shared analysis, tests, and cross-platform build automation are maintained in the repository.',
        'First-party Local Direct and runtime Capsules exist in source, but are not presented as a current public download.',
      ],
      publicItems: [
        'The current macOS Preview is published with a bundled first-party Pi Node Runtime Capsule.',
        'The Homebrew Tap points to the exact published Universal macOS asset and its SHA-256.',
        'Android, iOS, Web, Windows, and Linux retain their declared platform roles and Preview boundaries.',
        'Shared analysis, tests, and cross-platform release automation are maintained in the repository.',
      ],
      noticeTitle: 'Development status',
      noticeBody:
        'Pi Client is not promoting an installable build as the current product yet. Follow the repository for implementation progress and future releases.',
      publicNoticeBody:
        'The current macOS Preview is available through the official Homebrew Tap. It is ad-hoc signed and not notarized; release notes explain its trust and Gatekeeper behavior.',
    },
    closing: {
      title: 'Build the independent Pi Client with us.',
      description:
        'Review the source, follow project decisions, open an issue, or contribute a focused improvement.',
      source: 'View on GitHub',
      contribute: 'Read contributing guide',
    },
    footer: {
      description: 'An independent, open-source Flutter client for the pi coding agent.',
      readme: 'README',
      contributing: 'Contributing',
      license: 'MIT License',
      issues: 'Issues',
      attribution:
        'Pi Client is independently developed. Delivered source, verified contracts, and planned runtime work are presented separately.',
    },
  },
  'zh-cn': {
    locale: 'zh-cn',
    htmlLang: 'zh-CN',
    metaTitle: 'Pi Client — 面向 pi 的跨平台 Flutter 客户端',
    metaDescription:
      '面向 pi coding agent 的独立开放源代码 Flutter 客户端，覆盖桌面、移动端和 Web。',
    languageLabel: '语言',
    languageHref: '/',
    languageName: 'English',
    homeLabel: 'Pi Client 首页',
    navigationLabel: '主要导航',
    projectLinksLabel: '项目链接',
    socialImageAlt: 'Pi Client 产品标识与跨平台产品定位',
    nav: {
      product: '产品',
      platforms: '平台',
      install: '安装',
      status: '状态',
      github: 'GitHub',
    },
    hero: {
      eyebrow: '独立跨平台客户端',
      title: '一个 Pi Client，覆盖六个平台目标。',
      description:
        'Pi Client 是面向 pi coding agent 的独立开放源代码 Flutter 客户端，以一套代码覆盖 Android、iOS、macOS、Windows、Linux 和 Web。',
      badges: ['Flutter', '六个平台目标', '开放源代码'],
      primary: '查看源代码',
      secondary: '参与贡献',
      note: '第一方 Local Direct 已在源码中实现；受支持的公开分发仍在积极建设中。',
      publicNote: '当前 macOS Preview 已可通过 Homebrew 获取；其他平台的公开分发仍在积极建设中。',
      platformLabel: '项目支持的平台目标',
    },
    principles: {
      eyebrow: '产品基础',
      title: '聚焦客户端，并明确不同平台的能力边界。',
      description: '仓库将已经验证的源码和契约，与仍在建设的运行时能力清晰分开。',
      items: [
        {
          icon: 'code',
          title: '一套 Flutter 代码',
          description: '六个平台共享产品代码和版本，原生配置继续由各平台自身负责。',
        },
        {
          icon: 'platforms',
          title: '桌面、移动端与 Web',
          description:
            'Android、iOS、macOS、Windows、Linux 和 Web 都是同一个 Pi Client 产品的平台目标。',
        },
        {
          icon: 'roles',
          title: '清晰的执行角色',
          description: '桌面端在契约上具备 Host 能力；Android、iOS 和 Web 仅负责连接。',
        },
        {
          icon: 'open',
          title: '开放开发过程',
          description: '架构、源码、Issue 和贡献指南都保留在公开仓库中。',
        },
      ],
    },
    roles: {
      eyebrow: '平台角色',
      title: '能力边界由设备角色决定。',
      description: 'Pi Client 使用应用级平台契约，而不是让所有目标获得相同权限。',
      desktop: {
        title: '桌面客户端',
        platforms: 'macOS · Windows · Linux',
        badge: '契约定义为 Host-capable',
        description:
          '桌面源码构建已支持第一方 Local Direct 和经过验证的 Runtime Capsule；受支持的公开安装包仍在资格验证中。',
        publicDescription:
          '公开的 macOS Preview 通过 Homebrew 分发，并包含第一方 Runtime Capsule；Windows 和 Linux Preview 安装包仍在资格验证中。',
      },
      connectOnly: {
        title: '仅连接客户端',
        platforms: 'Android · iOS · Web',
        badge: 'Connect-only',
        description:
          '移动端和 Web 不嵌入 Agent 运行时，也不获取宿主文件系统或工具执行权限。',
        publicDescription:
          '移动端和 Web 不嵌入 Agent 运行时，也不获取宿主文件系统或工具执行权限。',
      },
      note: '第一方 Host Runtime Capsule 已在源码和候选流程中验证，但当前没有受支持的公开安装包入口。',
      publicNote: '公开的 macOS Preview 已包含第一方 Host Runtime Capsule；Android、iOS 和 Web 继续保持仅连接边界。',
    },
    homebrew: {
      eyebrow: 'macOS Preview',
      title: '通过 Homebrew 安装当前 Preview。',
      description: '官方 Pi Client Tap 会跟踪最新的、固定资产的 macOS Preview；Tap 更新时安装命令保持不变。',
      commandLabel: '使用 Homebrew 安装',
      command: 'brew install --cask hu-wentao/tap/pi-client',
      platform: 'macOS 11 或更高版本',
      note:
        '此 Preview 使用 ad-hoc 签名，尚未公证。Homebrew 会保留 macOS 隔离属性；如果 Gatekeeper 阻止首次启动，请在 Finder 中按住 Control 点击 Pi Client.app，选择“打开”并确认。不要关闭 Gatekeeper 或删除隔离属性。',
    },
    status: {
      eyebrow: '当前状态',
      title: '独立产品正在积极开发中。',
      description: '公开仓库已经建立跨平台工程与安全边界，运行时交付由独立进度负责。',
      items: [
        '仓库包含 Android、iOS、macOS、Windows、Linux 和 Web 的 Flutter 平台工程。',
        '聚焦测试验证桌面 Host-capable 与移动端/Web connect-only 的角色映射。',
        '共享分析、测试和跨平台构建自动化都在仓库中维护。',
        '第一方 Local Direct 与 Runtime Capsule 已存在于源码中，但不会被描述为当前公开下载。',
      ],
      publicItems: [
        '当前 macOS Preview 已发布，并包含第一方 Pi Node Runtime Capsule。',
        'Homebrew Tap 指向精确的 Universal macOS 资产及其 SHA-256。',
        'Android、iOS、Web、Windows 和 Linux 继续遵循各自的平台角色与 Preview 边界。',
        '共享分析、测试和跨平台发布自动化都在仓库中维护。',
      ],
      noticeTitle: '开发状态',
      noticeBody:
        'Pi Client 当前不把任何可安装构建作为正式产品入口。请通过公开仓库关注实现进度与后续发布。',
      publicNoticeBody:
        '当前 macOS Preview 已可通过官方 Homebrew Tap 获取。它使用 ad-hoc 签名且尚未公证；发布说明会解释信任与 Gatekeeper 行为。',
    },
    closing: {
      title: '一起构建独立的 Pi Client。',
      description: '查看源码、跟踪项目决策、提交 Issue，或贡献一个聚焦的改进。',
      source: '在 GitHub 查看',
      contribute: '阅读贡献指南',
    },
    footer: {
      description: '面向 pi coding agent 的独立开放源代码 Flutter 客户端。',
      readme: 'README',
      contributing: '参与贡献',
      license: 'MIT License',
      issues: 'Issues',
      attribution: 'Pi Client 为独立开发项目；已交付源码、验证契约和规划中的运行时工作会分别说明。',
    },
  },
};
