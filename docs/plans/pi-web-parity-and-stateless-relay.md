---
mdq:
  version: 2
  dialect: gfm
  actors: {read: mixed, write: machine}
  records:
    boundary:
      source: heading
      levels: [2]
      pattern: '^(?P<id>PLAN-PI-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$'
    key:
      source: heading
      pattern: '^(?P<id>PLAN-PI-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$'
      group: id
  fields:
    title: {source: heading, group: title}
    status: {source: label, labels: [Status, 状态]}
    review_level: {source: label, labels: [Review level, 评审级别]}
    target: {source: label, labels: [Target, 目标]}
    raw: {source: body}
  queries:
    plan_by_id:
      when: {pattern: '^PLAN-PI-[0-9]{3}$'}
      match: {source: key, operator: eq}
      select: [title, status, review_level, target]
      expect: {max_record_lines: 700, max_record_bytes: 131072, structured: true, min_confidence: 1.0}
    plans_by_status:
      match: {source: field, field: status, operator: eq}
      select: [title, review_level, target]
      expect: {max_total_bytes: 262144, structured: true, min_confidence: 1.0}
  maintenance: {query_contract: {mode: locked}}
---
# Pi Client 实施计划

默认评审级别：L3。用户本次直接指定的产品目标与数据约束为 L9；已由仓库和固定上游确认的事实为 L6；尚未实施的架构、协议和阶段安排为 L3。

## PLAN-PI-001 - pi-web 功能对标与无持久化公网中转

- Status: Planned
- Review level: L9（产品目标与数据约束）/ L3（技术方案）
- Target: Flutter 客户端对标固定版本 pi-web，并通过 Passkey 与中心化中转服务安全访问用户自己的 Pi
- 当前项目基线：`pi-client` `0.0.1+1`，`main` commit `c896070b857ca0fb0387945e2ae52c35e5b140cd`
- 对标基线：`agegr/pi-web` commit `28bab3c25f5f6770c9b0b745ebbfec1c27f7b948`，package `0.8.11`，MIT
- 计划状态说明：本文描述未来目标，不改变 `docs/baseline.md` 中当前已生效的 MVP 事实，也不把尚未实现的中转、Passkey 或完整对标能力描述为当前能力。

### 1. 目标

本计划同时交付两条产品能力：

1. **pi-web 功能对标**：Flutter 客户端以固定版本 pi-web 的可观察行为为产品基线，逐项实现会话、消息、文件、Git、worktree、模型、技能、插件、子代理、扩展 UI、设置和响应式交互。
2. **远程访问**：用户既可在本机或局域网直连自己的 pi-web，也可通过中心化服务从公网访问自己的 Pi。
3. **Passkey 鉴权**：公网模式不使用中心账户密码，使用 Passkey 完成用户到自己 Pi 节点的认证。
4. **中心服务无用户数据持久化**：中心服务不建立用户账户库，不持久化 Passkey 凭证、Pi 会话、消息、提示、文件、模型配置、API Key 或其他用户业务数据，仅执行连接鉴别、能力凭证校验与加密流量转发。
5. **用户侧数据主权**：Pi 数据、Passkey 凭证记录、节点身份和本地 pi-web 凭据全部留在用户控制的设备上。

### 2. 非目标

- 不在中心服务提供云端 Pi 运行时、云端文件系统、云端会话同步或云端模型代理。
- 不由中心服务保存离线消息、离线任务、通知队列或请求重放队列。
- 不提供依赖中心用户库的邮箱登录、社交登录、密码找回、跨节点账户列表、计费或按用户配额。
- 不把中转服务做成任意 TCP、HTTP 或内网地址代理；它只能连接已配对节点，并由节点连接器把请求限制到配置好的本地 pi-web。
- 不承诺 Flutter UI 与 Web DOM/CSS 像素级一致；要求可观察行为、信息结构和状态语义对标，平台特有能力采用明确记录的原生等价实现。
- 不修改固定参考仓库，也不依赖其未声明稳定性的内部实现细节作为永久公共契约。

### 3. 必须先澄清的可行性边界

#### 3.1 “不存储”必须解释为“不持久化”

网络转发必然在内核、TLS 栈和应用中产生有界的瞬时内存缓冲。若“不存储任何用户数据”包含“任何时刻都不能进入服务端内存”，则任何中转都无法实现。

本计划采用以下可验证定义：

- 中心服务**不得持久化**任何用户身份数据和业务数据。
- 中心服务只允许在内存中短时维护活动连接路由、限流计数、未完成帧和短期防重放状态。
- 内存状态具有明确 TTL 或随连接关闭释放；服务重启后不得恢复用户状态。
- 日志、指标、trace、错误上报和 crash dump 不得成为旁路持久化渠道。

#### 3.2 标准 Passkey 不能由“零用户数据”的中心服务直接拥有

普通 WebAuthn/Passkey 认证要求 Relying Party 在注册后取得并保存 credential ID、公钥和相关凭证记录；认证期间还需要保存并校验一次性 challenge。W3C WebAuthn Level 3 和 Google 的服务端 Passkey 指南都明确包含这些 Relying Party 状态。

因此以下组合不可行：

```text
中心中转服务 = Passkey Relying Party 数据所有者
并且
中心中转服务 = 不保存任何用户数据
```

本计划采用的最小可行调整是：

- 中心域名仍提供稳定的 WebAuthn RP ID 和公网入口。
- Passkey 注册选项、challenge、credential ID、公钥、sign counter 和撤销状态由**用户自己的节点连接器**生成、保存和验证。
- 中心服务只把 Passkey ceremony 转发给在线节点，不拥有凭证记录。
- 节点验证成功后签发短时、节点绑定、客户端密钥绑定的 capability；中心服务只使用活动节点公钥校验 capability 后放行对应转发流。
- 中心服务没有账户恢复能力。用户通过本地连接、已有 Passkey 或用户设备上的管理命令添加/撤销 Passkey。

### 4. 当前差距

当前 `pi-client` 是一个可验证的 P0 垂直切片：

- 单一 `WorkspacePage`。
- 支持 pi-web URL、可选 Basic Auth、会话列表、历史消息、新会话、提示、SSE、停止和基本状态反馈。
- 仅支持 macOS 11+。
- 没有中心中转、Passkey、节点连接器和端到端加密。

固定 pi-web 基线还包含但当前未实现的主要能力：

- 项目选择、最近项目、项目身份、CWD 浏览与信任确认。
- 会话族、分支、fork、名称、删除、导出、上下文分页和状态恢复。
- 富消息、Markdown、Mermaid、ANSI、图片、thinking、工具进度、bash 全量输出和 written files。
- composer 草稿、输入历史、图片压缩、`@` 文件补全、slash commands、steer/follow-up 队列、模型、thinking level、tool preset 和 compaction。
- 文件树、文件搜索、上传、监听、预览、多标签页、diff 和图片查看。
- Git status/diff、worktree 创建和带脏状态确认的删除。
- Provider 登录/退出/API Key、模型发现/测试/配置和模型选择。
- Skills 搜索/安装/更新/启停，Plugins 配置与重载。
- Subagent profiles/settings/runtime，Extension UI request/status/widgets/custom UI。
- 主题、`en`/`zh-CN`/`zh-TW`、通知、声音、更新检查、移动布局和 PWA 行为。

### 5. 目标系统边界

| 组件 | Owner | Executor | API boundary | Anti-boundary |
| --- | --- | --- | --- | --- |
| Flutter Pi Client | 页面状态、本地展示偏好、已配对节点引用 | UI、Passkey 平台调用、直连或远程请求 | typed Pages、FlowR Events、`PiTransport` | 不直接读取 `~/.pi/agent`；不把本地 pi-web 密码上传中心服务 |
| 用户侧 Node Connector | 节点身份、Passkey 凭证记录、本地 pi-web 连接配置、授权策略 | WebAuthn challenge/验证、capability 签发、请求解密与本地转发 | 版本化 remote protocol；固定 loopback pi-web target | 不接受任意上游地址；不把 Pi 数据持久化到中心服务 |
| Central Relay | 服务配置和自身 TLS/部署材料；仅内存活动路由 | 节点连接鉴别、capability 校验、帧转发、限流 | 公网 HTTPS/WSS、版本协商、健康检查 | 不建用户库；不解密 Pi payload；不保存离线队列；不转发任意目标 |
| pi-web / Pi runtime | 会话、项目、文件、Git、模型、技能、插件、工具和运行时 | 现有 HTTP JSON/SSE API 与 Pi 执行 | 固定 pi-web API 适配层 | Flutter 和 Relay 不复制 Pi 运行时或直接改写 Pi 数据文件 |

推荐把远程能力作为第二个独立的第一方项目交付：

```text
pi-client/                 # 当前 Flutter 客户端
pi-remote/                 # 新项目；Go 单仓库
  cmd/pi-relay/            # 中心服务二进制
  cmd/pi-connector/        # 用户侧连接器二进制
  protocol/                # 版本化 schema、测试向量、Dart/Go 生成入口
```

这样可以保持 Flutter 项目边界清晰，同时让 Relay、Connector 和协议共享网络实现与安全测试。两个项目独立使用 SemVer；协议兼容性不由任一 UI 版本隐式决定。

### 6. 数据与凭据所有权

#### 6.1 中心服务允许持久化的内容

仅允许服务自身的非用户材料：

- 服务启动配置。
- TLS 证书或平台托管的 TLS 配置。
- 用于验证运营方签发的无状态接入许可的公共密钥（如启用）。
- 不带节点、用户、IP、URL 或 payload 标签的聚合运行指标配置。

#### 6.2 中心服务只允许存在于内存的内容

- `nodeId -> active connection` 路由。
- 活动连接的节点公钥和协议版本。
- 有 TTL 的 nonce、防重放标识和限流计数。
- 有界的加密帧、流窗口和背压队列。
- 当前网络连接需要的 IP/Socket 元数据。

所有上述状态在连接关闭、TTL 到期或服务重启后消失。

#### 6.3 中心服务禁止保存或记录的内容

- 用户账号、邮箱、手机号、昵称或中心用户 ID。
- Passkey credential ID、公钥记录、userHandle、challenge 或恢复材料。
- 节点私钥、本地 pi-web Basic Auth、Provider API Key 或 OAuth token。
- Session ID、cwd、提示、消息、thinking、工具调用、文件名、文件内容、Git diff 或模型配置。
- 完整请求 path/query/header/body、加密前 payload、capability 原文或可复用认证材料。
- 包含 nodeId、IP、credential、session 或 payload 的访问日志、trace span、错误上报和 crash dump。

#### 6.4 用户侧节点允许保存的内容

- 长期节点身份私钥；优先 OS Keychain/安全存储，文件回退必须是最小权限。
- Passkey credential records 和撤销状态。
- 本地 pi-web URL 和可选 Basic Auth；只在用户设备上保存。
- 配对客户端的节点公钥指纹与最小授权策略。

Pi 会话、文件、Git 和模型数据仍由 pi-web/Pi 原有所有者保存，Connector 不建立第二份业务数据库。

### 7. 连接与认证流程

#### 7.1 本机和局域网直连

- 保留当前 HTTP JSON/SSE direct mode。
- direct mode 使用 `PiTransport` 的本地实现连接明确配置的 pi-web URL。
- 现有 Basic Auth 仅用于 direct mode；密码不得进入 route、Model、日志或仓库。
- 后续可增加 mDNS/局域网发现，但发现不能自动授予访问权限。

#### 7.2 节点上线

1. Connector 首次启动生成节点身份密钥。
2. `nodeId` 由节点公钥的稳定加密摘要生成，具有足够熵，不依赖中心账户。
3. Connector 对 Relay 的随机 challenge 签名并建立长期 outbound WSS 连接，无需在用户网络开放入站端口。
4. Relay 仅在内存中注册活动 `nodeId`、节点公钥、协议版本和连接句柄。
5. Connector 断线后路由立即失效；没有离线队列。

#### 7.3 首次配对与 Passkey 注册

1. 用户在本机或局域网打开 Connector 管理入口。
2. Connector 显示一次性 QR/配对码，包含 relay URL、nodeId、节点公钥指纹和短期 enrollment nonce。
3. Flutter Client 校验并固定节点指纹。
4. Connector 生成 WebAuthn registration options；中心服务仅转发。
5. 客户端调用平台 Passkey API。
6. Connector 验证 registration response，并在用户设备上保存 credential record。
7. enrollment nonce 一次使用后立即失效。

首次注册不得只凭公开 nodeId 在公网完成，否则 Relay 或攻击者可抢先注册自己的 Passkey。

#### 7.4 公网认证与 capability

1. 客户端已知 relay URL、nodeId 和节点公钥指纹。
2. 客户端经 Relay 向在线 Connector 请求 authentication options。
3. Connector 生成并在本地短时保存 challenge。
4. 客户端调用 Passkey，assertion 经 Relay 返回 Connector。
5. Connector 验证 RP ID、origin、challenge、credential public key、用户验证标志和计数策略。
6. Connector 签发短时 capability，至少绑定：nodeId、活动连接代次、客户端临时公钥、scope、签发时间、到期时间和唯一标识。
7. Relay 使用当前活动节点公钥验证 capability；通过后才能建立数据流。
8. Connector 可拒绝、撤销或缩小后续流；Relay 不保存长期 session。

#### 7.5 端到端加密

- 外层 TLS 保护客户端/Connector 到 Relay 的公网传输。
- Pi payload 还必须在 Flutter Client 与 Connector 之间建立内层 E2EE，使 Relay 只能看到加密帧、大小、时序和连接元数据。
- 不手写新的密码学协议。实现前必须评估并选择有 Dart/Go 实现、可生成测试向量的已审计 Noise/HPKE 等标准方案。
- 客户端通过配对时固定的节点公钥验证 Connector，防止 Relay 冒充节点。
- capability 必须绑定客户端临时密钥，降低 capability 被复制后的重放价值。

### 8. 远程转发协议

推荐使用**受限的 API-aware framed tunnel**，而不是任意 TCP 代理或为每个 pi-web endpoint 重写一套中心 BFF。

最低协议能力：

- WSS 建连和明确的 protocol version negotiation。
- 控制帧：hello、challenge、capability、open、accept、reject、close、ping/pong。
- 数据帧：request head、response head、body chunk、stream event、error、window update。
- 支持 JSON、二进制文件、multipart upload、Range response、SSE 和长时间运行请求。
- 每条逻辑流有 stream ID、sequence、最大帧大小、窗口和取消语义。
- Connector 仅允许转发到固定本地 pi-web base URL，并执行 method/path/header allowlist。
- 禁止 hop-by-hop headers、代理凭据、任意 Host、绝对 URL、CONNECT 和本地其他端口。
- Relay 只读取路由与协议头，不读取内层 method/path/header/body。
- 背压从本地 pi-web 一直传播到 Flutter；不得使用无界队列吸收慢客户端。
- SSE 断线区分 Client、Relay、Connector 和 pi-web 四种原因，客户端只对可恢复原因重连。

首版使用 WebSocket 以覆盖 Flutter 桌面与移动端；协议不依赖 WebSocket 特性，后续可在不改变上层 `PiTransport` 的前提下评估 WebTransport/QUIC。

### 9. Flutter 架构演进

#### 9.1 基础原则

- 保留 FVM 和 Flutter `3.41.6`，升级必须单独决策。
- 继续使用 Source-First ACDD、FlowR、typed Pages 和 `fr-mvvm-contract`。
- 每个 Page/Component 使用 basename 匹配的独立 leaf directory；不同模块不得共用一个 `.c.dart` 目录。
- `.c.dart` 只拥有契约、Models、Events、DTO 和业务枚举；`.vm.dart` 拥有 API/状态；`.v.dart` 拥有 Widgets；`.srv.dart` 只做 transport/API adapter。
- API 和状态动作通过 Bloc Event；ViewModel 不拥有 `BuildContext` 和 router。
- 未来新增或重构契约的描述值使用当前项目解析出的 English Contract Description Language。

#### 9.2 目标模块图

```text
lib/app/
  app_shell/                    # responsive shell 与顶层 typed route
  workspace/                    # project/session/file 主工作区组合
  settings/
    general_settings/
    model_settings/
    skill_settings/
    plugin_settings/
    agent_settings/

lib/components/
  connection_target/            # direct/remote 节点与连接状态
  project_browser/              # recent projects、cwd、trust
  session_browser/              # session family、running、unread
  conversation/                 # history、stream、branch、stats
  prompt_composer/              # draft、image、slash、@、queue、controls
  file_workspace/               # explorer、tabs、viewer、upload、watch
  git_changes/                  # status/diff
  worktree_manager/             # create/remove/dirty confirmation
  model_configuration/
  skill_configuration/
  plugin_configuration/
  subagent_manager/
  extension_ui_host/

lib/widgets/
  markdown_body/
  ansi_text/
  image_preview/
  mermaid_view/
  tab_bar/

lib/api/pi/                     # pi-web typed DTO 与 API gateway
lib/transport/                  # PiTransport、DirectTransport、RelayTransport
lib/security/passkey/           # 平台 Passkey adapter，不拥有业务状态
lib/security/secure_storage/    # 配对引用和客户端侧非业务秘密
```

当前大而集中的 `WorkspaceViewModel` 不一次性重写；按已验证能力逐步拆分。每次拆分必须先发现并复用共享 UI，再为新增组件建立独立契约和 focused tests。

#### 9.3 Transport 抽象

```text
Pi feature component
  -> PiApi / domain gateway
     -> PiTransport
        -> DirectTransport  -> pi-web HTTP/SSE
        -> RelayTransport   -> E2EE framed tunnel -> Connector -> pi-web
```

- Feature contract 不判断 LAN/公网，也不拼接 Relay 帧。
- Direct 与 Relay 对同一 pi-web operation 返回相同 typed DTO/error taxonomy。
- pi-web 没有稳定 OpenAPI，因此继续使用 explicit API contract 与手写 adapter；不得虚构 BFF schema。
- 新的第一方 Relay control protocol 单独版本化并生成 Dart/Go types。

### 10. pi-web 对标清单

实施前把每项标为 `Exact`、`Native-adapted`、`Not-applicable`、`Blocked` 或 `Verified`，不能用“页面已出现”替代完整行为验证。

| Domain | 目标能力 | 当前状态 | 计划阶段 |
| --- | --- | --- | --- |
| App shell | 桌面侧栏、顶栏、panel/tab、窄屏抽屉和移动工具栏 | Partial | P1、P7 |
| Project/CWD | recent projects、目录选择、validate、default cwd、project trust | Missing | P3 |
| Sessions | list/refresh/running/unread/family/restore/new/rename/delete/export/auto-name | Partial | P3 |
| Agent lifecycle | ensure/lazy start、prompt、abort、reload、steer/follow-up、queue、retry、compact | Partial | P3 |
| Event stream | 完整 wire projection、tool delta、queue/retry/compaction/extension events | Partial | P3 |
| Messages | Markdown、Mermaid、ANSI、image、thinking、tool result、bash、custom、pagination | Partial | P3 |
| Composer | draft/history/image/slash/@/model/thinking/tools/bash/queue | Missing | P3 |
| Files | explorer/index/search/upload/watch/read/range/preview/tabs/written files | Missing | P4 |
| Git | status、diff、changed files | Missing | P4 |
| Worktree | list/create/remove/dirty confirmation/switching | Missing | P4 |
| Models/Auth | provider list/login/logout/API key、catalog/discover/test/config/select | Missing | P5 |
| Skills | list/search/check/install/update/dormancy | Missing | P6 |
| Plugins | list/configure/reload | Missing | P6 |
| Subagents | profiles/settings/runtime/status/abort | Missing | P6 |
| Extensions | blocking UI、notify、status、widgets、title、custom UI | Missing | P6 |
| Settings | general/models/skills/plugins/agents/tools/system prompt | Missing | P5、P6 |
| UX | theme、en/zh-CN/zh-TW、sound、clipboard、shortcuts、notifications、update | Missing | P7 |
| Remote access | Connector、Relay、Passkey、capability、E2EE | Missing | P2、P8 |

固定 pi-web API inventory 至少覆盖以下域：

- Agent：`/api/agent/new`、`/api/agent/running`、`/api/agent/:id`、events、bash-output。
- Sessions：list/detail/context/state、entry thinking、tool-result image、auto-name、export、PATCH、DELETE。
- Files/CWD：home、default-cwd、cwd browse/validate、file-index、files read/upload/watch/stream。
- Git/Worktree/Trust：git status、git diff、worktrees、project-trust。
- Models/Auth：models、models-config、catalog、discover、test、provider login/logout/API key。
- Skills/Plugins：skills list/search/check/install/update/PATCH、plugins GET/POST。
- Subagents/Tools：subagent runtime/profiles/settings、tools settings。
- Platform：push config/subscribe、app-update。

每个 operation 必须有 request/response/error/stream fixture、直接模式测试和远程模式等价测试。

### 11. 分阶段实施

#### P0 - 对标与协议冻结

交付：

- 从固定 pi-web commit 生成完整 feature/API/event matrix。
- 为每项确定 Exact、Native-adapted 或 Not-applicable；无证据项不得默认实现。
- 建立 Relay threat model、数据分类、日志规范和 protocol v1 草案。
- 建立新的 planned requirements、decision records 和 verification owner。
- 评估 Passkey、secure storage、Noise/HPKE、WebSocket 和 Go 依赖；未通过评估前不实现认证协议。

退出条件：

- 所有固定 pi-web route、主要组件和 event type 均有唯一对标记录。
- Passkey 凭证所有权和“不持久化”的可验证定义获得接受。
- P1/P2 的兼容面、仓库边界和安全负面测试已明确。

#### P1 - Flutter shell、契约和 transport 基础

交付：

- 将单 `WorkspacePage` 拆为 shell、connection、session、conversation 和 composer 边界。
- 建立 `PiTransport`、`DirectTransport` 和 typed `PiApi`，保持现有 direct behavior 不变。
- 建立响应式 shell 和 typed route，不一次性引入所有页面。
- 把现有 MVP tests 迁移为模块级 tests，并保持 Golden 和 live smoke 通过。

退出条件：

- 当前 P0 功能无回归。
- Contract/final validation、route validation、build_runner、analyze 和 tests 全部通过。
- Feature 代码不再直接依赖 Dio absolute URI 或 Relay 协议。

#### P2 - 公网访问安全垂直切片

交付：

- `pi-remote` 项目、Connector、Relay 和 protocol v1。
- 节点身份、outbound tunnel、内存路由和受限本地 pi-web 转发。
- 本地首次配对、Passkey 注册/认证、节点签发 capability。
- Client/Connector 内层 E2EE。
- 先仅覆盖连接、session list/detail、prompt、SSE 和 abort。

退出条件：

- 同一套 Flutter session flow 可在 direct 与 relay mode 运行。
- Relay 重启前后不存在可恢复用户状态；Connector/Client 能明确重连。
- Relay filesystem、DB、logs、metrics 和 crash output 检查无用户数据。
- 未认证、错误节点、错误 origin、过期 capability、重放、篡改帧和越权 path 全部被拒绝。

#### P3 - 会话、消息和 composer 完整对标

交付：

- 项目/session family、running/unread、恢复、重命名、删除、导出和分支导航。
- 历史分页、deferred thinking/media、完整消息角色、工具进度和 bash 输出。
- Markdown、Mermaid、ANSI、图片、written files、minimap、tokens/cost/context usage。
- drafts、输入历史、图片、slash、`@`、模型、thinking、tools、steer/follow-up、queue、compact 和 retry。
- 完整 Agent event wire，不把未知 event 静默伪装为成功。

退出条件：

- 对标矩阵中 session/message/composer 项全部 Verified。
- direct 与 relay 对同一 fixture 产生等价 Model state。
- disconnect、late response、session switch、duplicate event 和 command uncertainty 有聚焦测试。

#### P4 - 文件、Git 和 worktree

交付：

- 文件树、搜索、上传、监听、预览、tabs、Range、图片和 diff mode。
- Git status/diff 和 changed files。
- worktree list/create/switch/remove；脏 worktree force remove 使用两阶段确认。
- project trust 与路径安全提示。

退出条件：

- Connector 只转发 allowlist operation，不能成为 SSRF 或任意文件代理。
- 大文件、慢客户端、取消、SSE/file watch 并发和背压测试通过。
- 破坏性 worktree 操作有明确 target、dirty evidence、确认和失败恢复。

#### P5 - 模型、Provider 与通用设置

交付：

- 模型列表/选择、auto model、thinking level 和 scope warnings。
- models-config catalog/discover/test/read/write。
- provider login/logout/API key UI；所有 Provider 凭据仍由用户 Pi/pi-web 保存。
- general settings、theme、language、tool settings 和 system prompt/tool definitions。

退出条件：

- Provider secrets 不进入 Flutter Model、Relay、URL、日志、截图或仓库。
- 模型切换、失败回滚、reload 和 session state 更新有 focused tests。

#### P6 - Skills、Plugins、Subagents 与 Extension UI

交付：

- Skills list/search/check/install/update/dormancy。
- Plugins 列表、配置和运行时 reload。
- Subagent profile/settings/runtime/status/abort。
- Extension blocking UI、notify、status、widgets、title/editor/custom UI。

退出条件：

- 每种 blocking request 都有 timeout、cancel、disconnect 和 stale-response 测试。
- Subagent 父子会话、后台运行和通知抑制与 pi-web 基线一致。
- 安装/更新/启停操作有明确作用域和失败恢复。

#### P7 - 原生平台等价与可访问性

交付：

- Flutter 的 desktop/narrow-window/mobile layouts。
- `en`、`zh-CN`、`zh-TW`。
- 键盘、clipboard、sound、平台通知、深链和 app update 等价能力。
- macOS 继续作为首个完整验证平台；随后按独立 app-info/signing 审计启用 iOS/Android，Windows/Linux 另行排期。
- PWA install 不在 Flutter 中复制，记录为 native packaging 等价项。

退出条件：

- 固定 viewport Golden、Widget interaction、keyboard 和 accessibility semantics 通过。
- 平台差异都有 Exact/Native-adapted/Not-applicable disposition。

#### P8 - Relay 生产化与开源交付

交付：

- 单实例到多实例的无共享用户数据库扩展方案。
- 推荐使用按 nodeId 确定性分片或边缘一致性路由，使 Client 与 Connector 到达同一 Relay shard。
- 聚合指标、无敏感标签的健康监控、容量限制、连接 draining 和升级兼容。
- Docker/部署文档、安全配置、滥用控制和协议升级说明。
- 客户端、Relay、Connector 和协议的开源许可证与独立发布说明。

退出条件：

- 无 Redis/数据库用户路由表；实例重启清空所有活动用户状态。
- 升级、drain、断线重连、分片漂移和旧协议拒绝行为有可重复验证。
- 文档不包含生产域名凭据、真实 nodeId、Passkey records 或用户 payload。

### 12. 威胁模型与安全验收

必须覆盖：

- 恶意 Relay 读取或篡改 payload：由内层 E2EE、节点指纹固定和 AEAD 拒绝解决；Relay 仍可观察流量大小与时序，该元数据风险必须公开说明。
- 未授权客户端探测 nodeId：nodeId 必须高熵；认证前只开放最小 ceremony；内存限流和短超时。
- Relay 冒充节点：客户端固定节点公钥指纹，握手必须证明节点私钥。
- capability 窃取：短 TTL、client-key binding、scope、连接代次和防重放。
- Connector SSRF：固定 loopback target、严格 operation allowlist、禁止绝对 URL/Host 覆盖。
- Path traversal：Client 不自行判断 OS 路径安全；Connector 和 pi-web 的服务端规则为权威，错误必须保留。
- 无界内存：帧大小、stream 数、connection 数、窗口、上传大小和超时均有硬限制。
- 日志泄露：默认 route template 和聚合错误码；不记录 nodeId、IP、path、header、body、token 或 payload。
- 平台凭据泄露：Flutter 不保存 Provider API Key；节点私钥和配对引用使用 OS secure storage。
- Passkey 丢失：中心服务不提供账户恢复；恢复必须在用户节点本地完成。

### 13. 验证与证据所有者

| 风险/行为 | 主要验证层 |
| --- | --- |
| Flutter Contract、Event、Provider、typed route | `fr-mvvm-contract` validators、route validator、analyzer |
| UI 状态、滚动、输入、对话框、响应式布局 | Widget tests、Golden、accessibility semantics |
| pi-web operation 兼容 | typed gateway contract tests、固定 fixtures、live smoke |
| Direct/Relay 等价 | transport conformance suite，对同一 fixture 比较 domain state |
| Passkey ceremony | FIDO/WebAuthn server tests、fake authenticator 自动测试、真机手工验证 |
| Protocol 编解码 | Dart/Go 共享测试向量、property tests、fuzzing |
| E2EE | 已选标准库测试向量、篡改/重放/错误指纹负面测试 |
| SSE/上传/大响应/背压 | 多进程 integration、断线与慢消费者 chaos tests |
| Relay 无持久化 | 文件系统和网络观测、DB/queue 依赖审计、重启清空检查、日志扫描 |
| 跨服务用户流程 | Client -> Relay -> Connector -> fixture/live pi-web E2E |
| 部署与升级 | staging operational verification，不用单元测试替代 |

所有阶段完成报告必须给出精确 commit、验证命令和证据范围；一个 passing test 不能自动把整个对标域标为 Verified。

### 14. 兼容性与版本策略

- `pi-client`、`pi-remote` 和 remote protocol 独立使用 SemVer。
- 当前 `0.x` 允许明确记录的破坏性变化，但必须提供配置迁移与回退说明。
- `PiTransport`、Relay protocol、配对 QR schema、capability claims、节点本地 credential schema 和公开 deep link 都是兼容面。
- protocol handshake 必须携带 major/minor；不兼容 major 明确拒绝，不能静默降级为明文或无认证模式。
- direct mode 在 remote mode 引入后继续保留，现有本地用户不被强制迁移。
- 上游 pi-web 继续固定到 `28bab3...` 完成首轮全量对标；升级上游必须重新生成差异矩阵、执行 adapter tests 和 live smoke。
- Passkey RP ID 绑定公网域名。更换 RP ID 会要求重新注册 Passkey，属于明确迁移事件。
- 节点身份密钥轮换会改变节点指纹或 nodeId，必须经过本地确认并重新配对。

### 15. 决策路径

#### D1 - “无存储”的定义

- 选项 A：包括 RAM 在内完全不接触用户数据。
- 选项 B：中心服务不持久化用户数据，只允许有界、短时、可清空的内存处理。
- 推荐：B；A 无法实现网络中转。
- 同意影响：必须定义 TTL、内存上限、日志禁区和重启清空测试。
- 否决影响：如果否决 B，则应取消中心中转目标，而不是伪称可实现。

#### D2 - Passkey credential owner

- 选项 A：中心 Relay 保存 Passkey records。
- 选项 B：外部身份服务保存 Passkey records。
- 选项 C：用户侧 Connector 保存和验证 Passkey records，Relay 校验节点签发的 capability。
- 推荐：C。
- 同意影响：没有中心账号、跨节点账号列表和云端恢复；节点离线时不能认证。
- 否决影响：A 违反零持久化；B 把用户身份数据转移给第三方而不是消除存储。

#### D3 - Relay 转发粒度

- 选项 A：任意 TCP tunnel。
- 选项 B：为每个 pi-web endpoint 在中心服务实现业务 BFF。
- 选项 C：受限、API-aware、payload opaque 的 framed tunnel。
- 推荐：C。
- 同意影响：需实现 stream multiplexing、allowlist、背压和 conformance suite。
- 否决影响：A 扩大 SSRF/内网代理风险；B 复制 pi-web 语义并使中心服务看到业务 payload。

#### D4 - 内层加密

- 选项 A：仅使用 Client/Connector 到 Relay 的外层 TLS。
- 选项 B：外层 TLS 加 Client-to-Connector E2EE。
- 推荐：B。
- 同意影响：需要标准密码协议依赖评估、共享测试向量和密钥轮换设计。
- 否决影响：Relay 虽不落盘，但仍可读取 Passkey 后的 Pi 会话、文件和凭据流量，不符合最小信任目标。

#### D5 - 项目仓库边界

- 选项 A：Relay、Connector 和 Flutter 全部放入当前仓库。
- 选项 B：当前仓库继续拥有 Flutter；新 `pi-remote` 仓库拥有 Relay、Connector 和协议。
- 选项 C：Relay、Connector 和协议各自独立仓库。
- 推荐：B。
- 同意影响：形成两个独立发布项目和一条协议兼容链，但避免污染 Flutter 根目录。
- 否决影响：A 耦合构建/发布；C 在首版增加跨三仓同步成本。

#### D6 - 对标判定

- 选项 A：要求 Flutter 对 Web UI 像素级复制。
- 选项 B：要求行为、信息架构、状态和错误语义对标，平台特有能力采用记录在案的原生等价。
- 推荐：B。
- 同意影响：PWA、Web Push 和浏览器存储会有 Native-adapted disposition。
- 否决影响：A 会把 DOM/CSS 偶然细节错误升级为 Flutter 产品契约，并阻碍跨平台可访问性。

#### D7 - 多实例路由

- 选项 A：使用 Redis/数据库保存 nodeId presence。
- 选项 B：单实例起步，随后使用 nodeId 确定性分片/边缘一致性路由和实例内存 presence。
- 推荐：B。
- 同意影响：Connector/Client 需使用同一分片算法，实例故障会触发重连而不是状态迁移。
- 否决影响：A 引入中心用户路由状态，不满足本计划的数据边界。

### 16. 实施顺序约束

必须按以下依赖顺序执行：

```text
对标矩阵与安全边界
-> 决策接受与 requirements/decision/verification 更新
-> Flutter module/transport refactor
-> Relay core vertical slice
-> Passkey + capability + E2EE
-> 完整会话/消息能力
-> 文件/Git/worktree
-> 模型/Provider/设置
-> Skills/Plugins/Subagents/Extensions
-> 平台等价与生产化
```

不得：

- 在 Passkey owner 未确定时先写中心用户表。
- 在 E2EE 未确定时把 Pi payload 当作普通 Relay JSON API。
- 在 transport abstraction 完成前让每个 Feature 分别实现 direct/remote 分支。
- 用一份巨大 `WorkspaceModel` 承载所有未来域。
- 把当前已通过的 MVP tests 删除后以“新架构尚未完成”为理由降低验证。
- 将 Relay 日志、分析平台或托管代理的默认访问日志排除在“无用户数据”审计之外。
- 为了完整对标而绕过 pi-web 的项目信任、路径安全和破坏性操作确认。

### 17. 总体验收条件

仅当以下条件同时满足，才能称为“完成对标 pi-web 并支持公网访问”：

- 固定 pi-web feature/API/event matrix 没有未分类项。
- 所有 `Exact` 和 `Native-adapted` 项有实现与对应验证；`Not-applicable` 有理由和用户影响。
- Direct mode 与 Relay mode 对全部已支持 pi-web operations 行为等价。
- Passkey 首次配对、注册、认证、添加、撤销和本地恢复路径可验证。
- Relay 无用户数据库、无离线队列、无 payload 解密、无用户数据日志，重启后没有用户状态恢复。
- E2EE、capability、路径 allowlist、背压、限流、断线和重放负面测试通过。
- Flutter contracts、routes、generation、analysis、tests、Golden 和目标平台 builds 通过。
- Client、Relay、Connector、协议和上游 pi-web 版本边界在 README/部署文档中明确。
- 所有已知差异仍在对标矩阵中，不用“核心功能已完成”替代全量完成判断。

### 18. 外部依据

- pi-web 固定源码：`/tmp/pi-web-reference`，commit `28bab3c25f5f6770c9b0b745ebbfec1c27f7b948`。
- W3C Web Authentication Level 3：Passkey/WebAuthn Relying Party registration 和 authentication operations。
- Google Server-side passkey authentication：认证需要一次性 challenge、用户/credential 查找和 credential public key verification。
- 当前项目治理来源：`docs/requirements.md`、`docs/baseline.md`、`docs/benchmark.md`、`docs/verification.md` 和 `docs/decisions/`。

### 19. Breaking changes

- 本文只新增 Planned 方案，不改变当前运行时、API、配置、持久化或发布版本。
- 实施 P1 后，当前 `WorkspacePage` 内部模块边界将发生重构，但 direct mode 的可观察行为必须保持兼容。
- 实施 P2 后，将新增 remote protocol、配对数据和 Passkey RP ID 等 `0.x` 兼容面；任何不兼容变更必须在对应项目 release notes 中记录迁移与回退。
