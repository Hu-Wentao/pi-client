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
  };
  status: {
    eyebrow: string;
    title: string;
    description: string;
    items: string[];
    noticeTitle: string;
    noticeBody: string;
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

// Release metadata remains machine-readable for immutable release verification.
// The independent product page intentionally does not render a download flow.
export const release = {
  version: '0.0.3',
  tag: 'v0.0.3',
  asset: 'Pi-Client-0.0.3-macOS-universal.zip',
  downloadUrl:
    'https://github.com/Hu-Wentao/pi-client/releases/download/v0.0.3/Pi-Client-0.0.3-macOS-universal.zip',
  releaseUrl: 'https://github.com/Hu-Wentao/pi-client/releases/tag/v0.0.3',
} as const;

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
      note: 'The first-party runtime and transport are under active development.',
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
          'Desktop targets can connect to an Agent host and are designed to support a first-party local host integration when that runtime is delivered.',
      },
      connectOnly: {
        title: 'Connect-only clients',
        platforms: 'Android · iOS · Web',
        badge: 'Connect-only',
        description:
          'Mobile and Web targets connect without embedding the Agent runtime or receiving host filesystem and tool-execution authority.',
      },
      note:
        'Host capability is a verified execution-role contract, not evidence that the host runtime ships in the current public product.',
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
        'The first-party runtime and transport are not presented as a current public download.',
      ],
      noticeTitle: 'Development status',
      noticeBody:
        'Pi Client is not promoting an installable build as the current product yet. Follow the repository for implementation progress and future releases.',
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
      note: '第一方运行时与传输能力正在积极开发中。',
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
          '桌面目标可以连接 Agent Host，并为未来交付的第一方本地 Host 集成保留能力边界。',
      },
      connectOnly: {
        title: '仅连接客户端',
        platforms: 'Android · iOS · Web',
        badge: 'Connect-only',
        description:
          '移动端和 Web 不嵌入 Agent 运行时，也不获取宿主文件系统或工具执行权限。',
      },
      note: 'Host 能力是已经验证的执行角色契约，不代表当前公开产品已经包含 Host 运行时。',
    },
    status: {
      eyebrow: '当前状态',
      title: '独立产品正在积极开发中。',
      description: '公开仓库已经建立跨平台工程与安全边界，运行时交付由独立进度负责。',
      items: [
        '仓库包含 Android、iOS、macOS、Windows、Linux 和 Web 的 Flutter 平台工程。',
        '聚焦测试验证桌面 Host-capable 与移动端/Web connect-only 的角色映射。',
        '共享分析、测试和跨平台构建自动化都在仓库中维护。',
        '第一方运行时与传输能力不会被描述为当前公开下载。',
      ],
      noticeTitle: '开发状态',
      noticeBody:
        'Pi Client 当前不把任何可安装构建作为正式产品入口。请通过公开仓库关注实现进度与后续发布。',
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
