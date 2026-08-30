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

默认评审级别：L3。用户直接指定的独立产品目标、数据约束及“pi-web 只可提供灵感，不作为需求或代码权威”为 L9；已由当前仓库确认的事实为 L6；尚未实施的架构、协议和阶段安排为 L3。

## PLAN-PI-001 - 独立 Pi 客户端与无持久化公网中转

- Status: Superseded
- Superseded by: `PLAN-PI-002` in `docs/plans/friday-relay-workspace-service.md`.
- Supersession scope: This entire document is historical and authorizes no implementation, including its candidate capability lists, phases, decisions, and acceptance conditions. Only an item explicitly reaccepted by a current requirement, decision, or `PLAN-PI-002` remains in scope under that current authority.
- Review level: L9（产品目标与数据约束）/ L3（技术方案）
- Target: 独立 Flutter Pi 客户端通过 Passkey 与中心化中转服务安全访问用户自己的 Pi
- 当前项目基线：`pi-client` `0.0.1+1`，`main` 上已经交付的 MVP 仍通过 `PiWebGateway` 验证基础交互
- 外部参考边界：pi-web 只是非权威的产品灵感来源；它不定义本项目的需求、验收、架构、协议或实现。
- 架构纠正：根据 `DEC-012`，目标产品不得导入、复制、调用、部署或要求安装任何 pi-web 代码。
- 历史状态说明：本文只保留已取代方案的背景，不改变 `docs/baseline.md` 中当前 MVP 已生效的事实；其中任何 Pi Node、Relay、Passkey 或产品能力只有被当前 authority 明确重新接受后才进入范围。

### 1. 目标

本计划交付一个独立产品体系：

1. **独立 Flutter 客户端**：依据用户确认的产品需求，独立设计和实现会话、消息、文件、Git、worktree、模型、技能、插件、子代理、扩展交互、设置和响应式体验。
2. **独立 Pi Node Gateway**：用户设备上的第一方节点服务直接集成 Pi SDK、Pi RPC 或其他经过评审的官方 Pi 运行时边界，不依赖 pi-web 服务端或其 API。
3. **本地与公网访问**：客户端既可直连本机或局域网中的 Pi Node，也可通过中心 Relay 从公网访问同一个 Pi Node。
4. **Passkey 鉴权**：远程访问使用 Passkey 完成用户到自己 Pi Node 的认证，不使用中心账户密码。
5. **中心服务无用户数据持久化**：Relay 不建立用户账户库，不持久化 Passkey 凭证、Pi 会话、消息、提示、文件、模型配置、API Key 或其他用户业务数据，只执行连接鉴别、能力凭证校验与加密流量转发。
6. **用户侧数据主权**：Pi 数据、Passkey 凭证记录、节点身份、Provider 凭据和项目文件全部留在用户控制的设备上。

### 2. 外部产品参考边界

pi-web 只提供候选灵感，不是需求来源或验收权威。任何候选能力只有在转换为本项目独立的 requirement、interaction contract 和 acceptance rule，并由用户接受后，才能进入范围。

允许的参考方式：

- 观察公开界面的产品概念和用户流程。
- 比较通用的加载、空、错误和运行状态表达。
- 研究响应式桌面与移动产品体验。
- 在许可证允许范围内记录产品差异。

禁止以下行为：

- 根据 pi-web 源码、route、event、type 或测试自动生成本项目需求和协议。
- Flutter、Pi Node 或 Relay 在运行时调用 pi-web HTTP/SSE API。
- 要求用户安装、启动或配置 pi-web。
- 导入 pi-web npm package、源码文件、React component、Next.js route 或内部类型。
- 复制 pi-web 的业务实现、内部 API schema、状态管理代码或服务端文件访问代码。
- 把 pi-web 的未声明稳定 API 变成本项目协议。
- 使用 pi-web 作为 Pi Node 的代理、sidecar、BFF 或部署依赖。

实施和验收不要求读取 pi-web 源码。本文后续的产品能力目录是待用户确认的候选范围，不代表必须镜像 pi-web。

### 3. 非目标

- 不实现 pi-web 兼容服务器，也不保证第三方 pi-web 客户端能连接本项目 Pi Node。
- 不在中心服务提供云端 Pi Runtime、云端文件系统、云端会话同步或云端模型代理。
- 不由 Relay 保存离线消息、离线任务、通知队列或请求重放队列。
- 不提供依赖中心用户库的邮箱登录、社交登录、密码找回、跨节点账户列表、计费或按用户配额。
- 不把 Relay 做成任意 TCP、HTTP 或内网地址代理；Relay 只能把已认证的加密流量转发给对应在线 Pi Node。
- 不要求 Flutter UI 与任何 Web DOM/CSS 像素级一致；产品能力、信息结构、状态语义和关键交互由本项目独立 requirements 决定，平台特有能力采用明确记录的原生实现。
- 不直接读写 `~/.pi/agent` 来绕过 Pi Runtime 的公开或经过审查的运行时边界；若某项能力没有受支持的 Pi API，必须先形成独立契约和风险决策。

### 4. 必须先澄清的可行性边界

#### 4.1 “不存储”解释为“不持久化”

网络转发必然在内核、TLS 栈和应用中产生有界的瞬时内存缓冲。若“不存储任何用户数据”包含“任何时刻都不能进入服务端内存”，则任何中转都无法实现。

本计划采用以下可验证定义：

- Relay **不得持久化**任何用户身份数据和业务数据。
- Relay 只允许在内存中短时维护活动连接路由、限流计数、未完成帧和短期防重放状态。
- 内存状态具有明确 TTL 或随连接关闭释放；服务重启后不得恢复用户状态。
- 日志、指标、trace、错误上报和 crash dump 不得成为旁路持久化渠道。

#### 4.2 标准 Passkey 不能由“零用户数据”的 Relay 直接拥有

普通 WebAuthn/Passkey 认证要求 Relying Party 在注册后取得并保存 credential ID、公钥和相关凭证记录；认证期间还需要保存并校验一次性 challenge。W3C WebAuthn Level 3 和 Google 的服务端 Passkey 指南都包含这些 Relying Party 状态。

因此以下组合不可行：

```text
Central Relay = Passkey 凭证数据所有者
并且
Central Relay = 不保存任何用户数据
```

本计划采用的最小可行调整：

- 中心域名提供稳定 WebAuthn RP ID 和公网入口。
- Passkey registration options、challenge、credential records 和撤销状态由用户自己的 Pi Node 生成、保存和验证。
- Relay 只把 Passkey ceremony 转发给在线 Pi Node，不拥有凭证记录。
- Pi Node 验证成功后签发短时、节点绑定、客户端密钥绑定的 capability；Relay 只使用活动节点公钥校验 capability 后放行对应转发流。
- Relay 不提供账户恢复。用户通过本地连接、已有 Passkey 或用户设备上的管理命令添加和撤销 Passkey。

### 5. 当前差距

当前 `pi-client` 是一个已经完成验证的临时 P0 MVP：

- 单一 `WorkspacePage`。
- 通过 `PiWebGateway` 支持 URL、可选 Basic Auth、会话列表、历史消息、新会话、提示、SSE、停止和基本状态反馈。
- 仅支持 macOS 11+。
- 没有独立 Pi Node、中心 Relay、Passkey 和端到端加密。

`PiWebGateway` 只证明 Flutter 的基础会话交互可行，不属于目标架构。P1 必须以第一方 `PiNodeApi` 和独立 Pi Runtime integration 替换它。

从产品能力参考看，当前还缺少：

- 项目选择、最近项目、项目身份、CWD 浏览与信任确认。
- 会话族、分支、fork、名称、删除、导出、上下文分页和状态恢复。
- 富消息、Markdown、Mermaid、ANSI、图片、thinking、工具进度、bash 全量输出和 written files。
- composer 草稿、输入历史、图片压缩、`@` 文件补全、slash commands、steer/follow-up 队列、模型、thinking level、tool preset 和 compaction。
- 文件树、文件搜索、上传、监听、预览、多标签页、diff 和图片查看。
- Git status/diff、worktree 创建和带脏状态确认的删除。
- Provider 登录/退出/API Key、模型发现/测试/配置和模型选择。
- Skills 搜索/安装/更新/启停，Plugins 配置与重载。
- Subagent profiles/settings/runtime，Extension UI request/status/widgets/custom UI。
- 主题、`en`/`zh-CN`/`zh-TW`、通知、声音、更新检查和移动布局。

### 6. 目标系统边界

| 组件 | Owner | Executor | API boundary | Anti-boundary |
| --- | --- | --- | --- | --- |
| Flutter Pi Client | 页面状态、本地展示偏好、已配对节点引用 | UI、Passkey 平台调用、直连或远程请求 | typed Pages、FlowR Events、`PiNodeApi` | 不依赖 pi-web；不直接读取 Pi 数据目录；不保存 Provider 凭据 |
| 用户侧 Pi Node | 节点身份、Passkey records、Pi Runtime 生命周期、本地授权策略 | Agent、session、文件、Git、worktree、模型、技能、插件和子代理操作 | 第一方版本化 Pi Node Protocol | 不调用 pi-web；不接受任意上游代理目标；不把用户数据交给 Relay |
| Central Relay | 服务配置和自身 TLS/部署材料；仅内存活动路由 | 节点连接鉴别、capability 校验、帧转发和限流 | 公网 HTTPS/WSS、版本协商、健康检查 | 不建用户库；不解密 Pi payload；不保存离线队列；不执行 Pi 业务 |
| Pi SDK / Pi Runtime | Pi 原生会话、模型、工具和运行行为 | 实际 Agent execution | 经过依赖评估的官方 SDK、RPC 或 CLI boundary | Pi Node 不复制 pi-web 的 Runtime manager；不绕过 Pi 的安全语义 |

推荐保持当前 Flutter 仓库独立，并新建远程运行项目：

```text
pi-client/                 # 当前 Flutter 客户端
pi-remote/                 # 新项目；不包含任何 pi-web 代码
  protocol/                # 第一方 Pi Node Protocol schema 与测试向量
  node/                    # 用户侧 Pi Node；优先评估 TypeScript/Bun + 官方 Pi SDK
  relay/                   # Stateless Relay；语言由连接/资源基准决定
```

`pi-client`、Pi Node、Relay 和 Protocol 分别拥有兼容面。是否在同一 `pi-remote` 仓库发布由 P0 决策，但不能把这些服务代码倒入 Flutter feature 目录。

### 7. 数据与凭据所有权

#### 7.1 Relay 允许持久化的内容

仅允许服务自身的非用户材料：

- 服务启动配置。
- TLS 证书或平台托管的 TLS 配置。
- 用于验证运营方签发的无状态接入许可的公共密钥（如启用）。
- 不带节点、用户、IP、URL 或 payload 标签的聚合运行指标配置。

#### 7.2 Relay 只允许存在于内存的内容

- `nodeId -> active connection` 路由。
- 活动连接的节点公钥和协议版本。
- 有 TTL 的 nonce、防重放标识和限流计数。
- 有界的加密帧、流窗口和背压队列。
- 当前网络连接需要的 IP/Socket 元数据。

所有上述状态在连接关闭、TTL 到期或服务重启后消失。

#### 7.3 Relay 禁止保存或记录的内容

- 用户账号、邮箱、手机号、昵称或中心用户 ID。
- Passkey credential ID、公钥记录、userHandle、challenge 或恢复材料。
- 节点私钥、Provider API Key、OAuth token 或 Pi Runtime 凭据。
- Session ID、cwd、提示、消息、thinking、工具调用、文件名、文件内容、Git diff 或模型配置。
- 完整请求 path/query/header/body、加密前 payload、capability 原文或可复用认证材料。
- 包含 nodeId、IP、credential、session 或 payload 的访问日志、trace span、错误上报和 crash dump。

#### 7.4 Pi Node 允许保存的内容

- 长期节点身份私钥；优先 OS Keychain/安全存储，文件回退必须是最小权限。
- Passkey credential records 和撤销状态。
- Pi Runtime 的用户配置、Provider 凭据和受支持的本地状态。
- 配对客户端的节点公钥指纹与最小授权策略。

Pi 会话、项目文件、Git 和模型数据保留在用户自己的设备上。Pi Node 不建立面向 Relay 的第二份云端业务数据库。

### 8. 连接与认证流程

#### 8.1 本机和局域网直连

- Flutter 通过第一方 Pi Node Protocol 连接本机或局域网 Pi Node。
- 本机首次启动使用操作系统用户上下文或一次性本地 enrollment 完成 bootstrap。
- 局域网访问也必须经过节点配对和 capability，不因处于私网而自动可信。
- 当前 pi-web URL/Basic Auth UI 仅作为旧 MVP 迁移输入，目标架构不保留对 pi-web 的连接能力。
- 后续可增加 mDNS 发现，但发现不能自动授予访问权限。

#### 8.2 节点上线

1. Pi Node 首次启动生成节点身份密钥。
2. `nodeId` 由节点公钥的稳定加密摘要生成，具有足够熵，不依赖中心账户。
3. Pi Node 对 Relay 的随机 challenge 签名并建立长期 outbound WSS 连接，无需在用户网络开放入站端口。
4. Relay 只在内存中注册活动 nodeId、节点公钥、协议版本和连接句柄。
5. Pi Node 断线后路由立即失效；没有离线队列。

#### 8.3 首次配对与 Passkey 注册

1. 用户在本机打开 Pi Node 管理入口。
2. Pi Node 显示一次性 QR/配对码，包含 relay URL、nodeId、节点公钥指纹和短期 enrollment nonce。
3. Flutter Client 校验并固定节点指纹。
4. Pi Node 生成 WebAuthn registration options；Relay 仅转发。
5. 客户端调用平台 Passkey API。
6. Pi Node 验证 registration response，并在用户设备上保存 credential record。
7. enrollment nonce 一次使用后立即失效。

首次注册不得只凭公开 nodeId 在公网完成，否则攻击者可抢先注册自己的 Passkey。

#### 8.4 公网认证与 capability

1. 客户端已知 relay URL、nodeId 和节点公钥指纹。
2. 客户端经 Relay 向在线 Pi Node 请求 authentication options。
3. Pi Node 生成并在本地短时保存 challenge。
4. 客户端调用 Passkey，assertion 经 Relay 返回 Pi Node。
5. Pi Node 验证 RP ID、origin、challenge、credential public key、用户验证标志和计数策略。
6. Pi Node 签发短时 capability，至少绑定 nodeId、活动连接代次、客户端临时公钥、scope、签发时间、到期时间和唯一标识。
7. Relay 使用当前活动节点公钥验证 capability；通过后才能建立数据流。
8. Pi Node 可拒绝、撤销或缩小后续流；Relay 不保存长期 session。

#### 8.5 端到端加密

- 外层 TLS 保护 Client/Pi Node 到 Relay 的公网传输。
- Pi payload 还必须在 Flutter Client 与 Pi Node 之间建立内层 E2EE，使 Relay 只能看到加密帧、大小、时序和连接元数据。
- 不手写新的密码学协议。实现前必须评估并选择有 Dart 和 Pi Node 实现、可生成共享测试向量的已审计 Noise/HPKE 等标准方案。
- 客户端通过配对时固定的节点公钥验证 Pi Node，防止 Relay 冒充节点。
- capability 必须绑定客户端临时密钥，降低 capability 被复制后的重放价值。

### 9. 第一方 Pi Node Protocol

目标协议由本项目定义，不镜像 pi-web route。它描述稳定的产品领域和流式语义：

- Node/session/project discovery。
- Agent create/start/prompt/steer/follow-up/abort/reload/compact。
- Session history、pagination、branch、rename、delete 和 export。
- Agent event、message delta、tool progress、queue、retry、compaction 和 extension UI。
- File browse/search/read/write/upload/watch 和 binary range。
- Git status/diff 和 worktree operations。
- Model/provider/tool/skill/plugin/subagent configuration。
- Node health、capabilities、protocol version 和 feature negotiation。

协议要求：

- request、response、error 和 event 使用版本化 schema。
- 每个 command 有明确的 accepted/rejected/uncertain 语义和幂等边界。
- 每条 stream 有 stream ID、sequence、取消、窗口和背压语义。
- 支持 JSON、二进制、multipart-like upload、Range、长时间运行和增量事件。
- Pi Node 只执行声明的领域操作，不接受任意 URL、Host、shell proxy 或透明 TCP 转发。
- Direct 与 Relay 模式使用相同领域协议；Relay 只承载加密后的协议帧。
- 协议定义独立于 Pi Runtime SDK 的内部类型，避免把第三方实现细节变成客户端兼容面。

外部产品观察可以帮助发现候选能力，但源码 route、event、type 和内部状态不得作为本协议的命名、字段、语义或兼容性权威。

### 10. Flutter 架构演进

#### 10.1 基础原则

- 保留 FVM 和 Flutter `3.41.6`，升级必须单独决策。
- 继续使用 Source-First ACDD、FlowR、typed Pages 和 `fr-mvvm-contract`。
- 每个 Page/Component 使用 basename 匹配的独立 leaf directory；不同模块不得共用一个 `.c.dart` 目录。
- `.c.dart` 只拥有契约、Models、Events、DTO 和业务枚举；`.vm.dart` 拥有 API/状态；`.v.dart` 拥有 Widgets；`.srv.dart` 只做第一方 Pi Node adapter。
- API 和状态动作通过 Bloc Event；ViewModel 不拥有 `BuildContext` 和 router。
- 新增或重构契约的描述值使用项目解析出的 English Contract Description Language。
- 不从 pi-web TypeScript 类型自动生成 Dart DTO，也不复制其 React state shape。

#### 10.2 目标模块图

```text
lib/app/
  app_shell/
  workspace/
  settings/
    general_settings/
    model_settings/
    skill_settings/
    plugin_settings/
    agent_settings/

lib/components/
  node_connection/
  project_browser/
  session_browser/
  conversation/
  prompt_composer/
  file_workspace/
  git_changes/
  worktree_manager/
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

lib/api/pi_node/                 # 第一方 typed DTO 与 PiNodeApi
lib/transport/                   # DirectNodeTransport、RelayNodeTransport
lib/security/passkey/
lib/security/secure_storage/
```

当前集中的 `WorkspaceViewModel` 不一次性重写；按已经验证的能力逐步拆分。每次拆分必须先发现并复用共享 UI，再为新增组件建立独立契约和 focused tests。

#### 10.3 调用路径

```text
Pi feature component
  -> PiNodeApi / domain gateway
     -> DirectNodeTransport -> local/LAN Pi Node
     -> RelayNodeTransport  -> E2EE framed tunnel -> Pi Node
     -> Pi Runtime adapter  -> official Pi SDK/RPC/CLI
```

- Feature contract 不判断 LAN/公网，也不拼接 Relay 帧。
- Direct 与 Relay 对同一 Pi Node operation 返回相同 typed DTO/error taxonomy。
- Pi Runtime adapter 只存在于 Pi Node，不进入 Flutter。
- 当前 `PiWebApi` 和 `PiWebGateway` 在迁移完成后删除，不作为兼容 adapter 长期保留。

### 11. 独立产品能力清单

下表是根据当前目标整理的候选范围。P0 必须让用户确认每项是否进入 requirements，再标为 `Planned`、`Native-adapted`、`Not-applicable`、`Blocked` 或 `Verified`。pi-web 不参与状态判定。

| Domain | 目标能力 | 当前状态 | 计划阶段 |
| --- | --- | --- | --- |
| App shell | 桌面侧栏、顶栏、panel/tab、窄屏抽屉和移动工具栏 | Partial | P1、P7 |
| Project/CWD | recent projects、目录选择、validate、default cwd、project trust | Missing | P3 |
| Sessions | list/refresh/running/unread/family/restore/new/rename/delete/export/auto-name | Partial | P3 |
| Agent lifecycle | create/lazy start、prompt、abort、reload、steer/follow-up、queue、retry、compact | Partial | P3 |
| Event stream | message/tool/queue/retry/compaction/extension events | Partial | P3 |
| Messages | Markdown、Mermaid、ANSI、image、thinking、tool result、bash、custom、pagination | Partial | P3 |
| Composer | draft/history/image/slash/@/model/thinking/tools/bash/queue | Missing | P3 |
| Files | explorer/index/search/upload/watch/read/range/preview/tabs/written files | Missing | P4 |
| Git | status、diff、changed files | Missing | P4 |
| Worktree | list/create/remove/dirty confirmation/switching | Missing | P4 |
| Models/Auth | provider auth、catalog/discover/test/config/select | Missing | P5 |
| Skills | list/search/check/install/update/dormancy | Missing | P6 |
| Plugins | list/configure/reload | Missing | P6 |
| Subagents | profiles/settings/runtime/status/abort | Missing | P6 |
| Extensions | blocking UI、notify、status、widgets、title、custom UI | Missing | P6 |
| Settings | general/models/skills/plugins/agents/tools/system prompt | Missing | P5、P6 |
| UX | theme、en/zh-CN/zh-TW、sound、clipboard、shortcuts、notifications、update | Missing | P7 |
| Remote access | Pi Node、Relay、Passkey、capability、E2EE | Missing | P2、P8 |

P0 必须把用户接受的能力转换成项目自己的 requirements、interaction flows 和 Pi Node operations。未被用户接受的候选项不得因为其他产品存在类似功能而自动进入范围。

### 12. 分阶段实施

#### P0 - 独立需求与架构冻结

交付：

- 从用户目标和候选产品灵感整理 feature/state/interaction proposal，并逐项取得范围确认。
- 为每个已接受 requirement 确定 `Planned`、`Native-adapted` 或 `Not-applicable`；未接受项不得默认实现。
- 评估官方 Pi SDK、RPC、CLI 和 session/runtime extension points，确定 Pi Node 的受支持集成边界。
- 建立第一方 Pi Node Protocol、Relay threat model、数据分类、日志规范和 protocol v1 草案。
- 建立 planned requirements、decision records 和 verification owners。
- 评估 Passkey、secure storage、Noise/HPKE、WebSocket 和服务运行时依赖。

退出条件：

- 候选能力均已接受、排除或延期，没有未经确认而自动进入范围的项目。
- 每项已接受能力都有本项目自己的 owner、API/Flow 和验证层。
- 文档和依赖图中没有 pi-web runtime/build/source dependency。
- Pi Runtime integration、Passkey owner 和“不持久化”的可验证定义获得接受。

#### P1 - 独立 Pi Node 与 Flutter 基础迁移

交付：

- 创建 Pi Node 最小运行时，直接集成经过评审的 Pi 官方边界。
- 建立第一方 Pi Node Protocol、`PiNodeApi` 和 DirectNodeTransport。
- 将单 `WorkspacePage` 拆为 shell、node connection、session、conversation 和 composer 边界。
- 迁移现有会话列表、历史、prompt、stream 和 abort 行为到 Pi Node。
- 删除产品运行路径中的 `PiWebGateway` 依赖。

退出条件：

- 用户不安装、不启动 pi-web，也能完成现有 MVP 全流程。
- Pi Node 的 session/runtime behavior 有独立 integration tests。
- Contract/final validation、route validation、build_runner、analyze 和 tests 全部通过。
- Flutter feature 代码只依赖 `PiNodeApi`。

#### P2 - 公网访问安全垂直切片

交付：

- Pi Node outbound tunnel、Stateless Relay 和 protocol v1 remote transport。
- 节点身份、内存路由、首次本地配对、Passkey 注册/认证和 capability。
- Flutter Client 与 Pi Node 内层 E2EE。
- 先覆盖 connection、session list/detail、prompt、event stream 和 abort。

退出条件：

- 同一 Flutter session flow 可在 Direct 与 Relay 模式运行。
- Relay 重启前后不存在可恢复用户状态；Pi Node/Client 能明确重连。
- Relay filesystem、DB、logs、metrics 和 crash output 检查无用户数据。
- 未认证、错误节点、错误 origin、过期 capability、重放、篡改帧和越权 operation 全部被拒绝。

#### P3 - 会话、消息和 composer 完整交付

交付：

- 项目/session family、running/unread、恢复、重命名、删除、导出和分支导航。
- 历史分页、deferred thinking/media、完整消息角色、工具进度和 bash 输出。
- Markdown、Mermaid、ANSI、图片、written files、minimap、tokens/cost/context usage。
- drafts、输入历史、图片、slash、`@`、模型、thinking、tools、steer/follow-up、queue、compact 和 retry。
- 第一方完整 Agent event model，不把未知 event 静默伪装为成功。

退出条件：

- 已接受的 session/message/composer requirements 全部 `Verified`。
- Direct 与 Relay 对同一 Pi Node fixture 产生等价 Model state。
- disconnect、late response、session switch、duplicate event 和 command uncertainty 有聚焦测试。

#### P4 - 文件、Git 和 worktree

交付：

- Pi Node 拥有文件树、搜索、上传、监听、预览、Range 和 diff operations。
- Flutter 实现 explorer、tabs、viewer、written files 和 diff mode。
- Git status/diff 和 changed files。
- worktree list/create/switch/remove；脏 worktree force remove 使用两阶段确认。
- project trust 与路径安全提示。

退出条件：

- Pi Node operation allowlist 不能成为 SSRF、任意文件或任意 shell proxy。
- 大文件、慢客户端、取消、file watch 并发和背压测试通过。
- 破坏性 worktree 操作有明确 target、dirty evidence、确认和失败恢复。

#### P5 - 模型、Provider 与通用设置

交付：

- 模型列表/选择、auto model、thinking level 和 scope warnings。
- Pi Node 管理模型 catalog/discover/test/config。
- Provider login/logout/API Key UI；所有 Provider 凭据只保存在用户 Pi Node。
- general settings、theme、language、tool settings、system prompt 和 tool definitions。

退出条件：

- Provider secrets 不进入 Flutter Model、Relay、URL、日志、截图或仓库。
- 模型切换、失败回滚、runtime reload 和 session state 更新有 focused tests。

#### P6 - Skills、Plugins、Subagents 与 Extension UI

交付：

- Skills list/search/check/install/update/dormancy。
- Plugins 列表、配置和运行时 reload。
- Subagent profile/settings/runtime/status/abort。
- Extension blocking UI、notify、status、widgets、title/editor/custom UI。

退出条件：

- 每种 blocking request 都有 timeout、cancel、disconnect 和 stale-response 测试。
- Subagent 父子会话、后台运行和通知抑制满足独立 requirements。
- 安装/更新/启停操作有明确作用域和失败恢复。

#### P7 - 原生平台等价与可访问性

交付：

- Flutter desktop/narrow-window/mobile layouts。
- `en`、`zh-CN`、`zh-TW`。
- 键盘、clipboard、sound、平台通知、深链和 app update 等价能力。
- macOS 继续作为首个完整验证平台；随后按独立 app-info/signing 审计启用 iOS/Android，Windows/Linux 另行排期。
- PWA install 不在 Flutter 中复制，记录为 native packaging 等价项。

退出条件：

- 固定 viewport Golden、Widget interaction、keyboard 和 accessibility semantics 通过。
- 平台差异都有 `Exact`、`Native-adapted` 或 `Not-applicable` disposition。

#### P8 - Relay 生产化与开源交付

交付：

- 单实例到多实例的无共享用户数据库扩展方案。
- 推荐使用按 nodeId 确定性分片或边缘一致性路由，使 Client 与 Pi Node 到达同一 Relay shard。
- 聚合指标、无敏感标签的健康监控、容量限制、连接 draining 和升级兼容。
- Docker/部署文档、安全配置、滥用控制和协议升级说明。
- Client、Pi Node、Relay 和 Protocol 的开源许可证与独立发布说明。

退出条件：

- 无 Redis/数据库用户路由表；实例重启清空所有活动用户状态。
- 升级、drain、断线重连、分片漂移和旧协议拒绝行为有可重复验证。
- 文档不包含生产域名凭据、真实 nodeId、Passkey records 或用户 payload。

### 13. 威胁模型与安全验收

必须覆盖：

- 恶意 Relay 读取或篡改 payload：由内层 E2EE、节点指纹固定和 AEAD 拒绝解决；Relay 仍可观察流量大小与时序，该元数据风险必须公开说明。
- 未授权客户端探测 nodeId：nodeId 必须高熵；认证前只开放最小 ceremony；内存限流和短超时。
- Relay 冒充 Pi Node：客户端固定节点公钥指纹，握手必须证明节点私钥。
- capability 窃取：短 TTL、client-key binding、scope、连接代次和防重放。
- Pi Node 越权：每个 operation 有独立授权 scope；不接受任意 URL、文件路径、shell 或动态代码执行请求。
- Path traversal：路径规范化、allowed roots、project trust 和操作系统语义由 Pi Node 统一执行，Flutter 不自行推断。
- 无界内存：帧大小、stream 数、connection 数、窗口、上传大小和超时均有硬限制。
- 日志泄露：默认 operation template 和聚合错误码；不记录 nodeId、IP、path、header、body、token 或 payload。
- 平台凭据泄露：Flutter 不保存 Provider API Key；节点私钥和配对引用使用 OS secure storage。
- Passkey 丢失：Relay 不提供账户恢复；恢复必须在用户 Pi Node 本地完成。

### 14. 验证与证据所有者

| 风险/行为 | 主要验证层 |
| --- | --- |
| Flutter Contract、Event、Provider、typed route | `fr-mvvm-contract` validators、route validator、analyzer |
| UI 状态、滚动、输入、对话框、响应式布局 | Widget tests、Golden、accessibility semantics |
| 产品需求验收 | 独立 acceptance scenarios、状态截图和人工审查，不使用任何外部产品 API contract |
| Pi Runtime integration | Pi Node focused/integration tests 与官方 Pi runtime fixture |
| Direct/Relay 等价 | transport conformance suite，对同一 Pi Node fixture 比较 domain state |
| Passkey ceremony | FIDO/WebAuthn server tests、fake authenticator 自动测试、真机手工验证 |
| Protocol 编解码 | Client/Pi Node/Relay 共享测试向量、property tests、fuzzing |
| E2EE | 已选标准库测试向量、篡改/重放/错误指纹负面测试 |
| Event/上传/大响应/背压 | 多进程 integration、断线与慢消费者 chaos tests |
| Relay 无持久化 | 文件系统和网络观测、DB/queue 依赖审计、重启清空检查、日志扫描 |
| 跨服务用户流程 | Client -> Relay -> Pi Node -> Pi Runtime E2E |
| 部署与升级 | staging operational verification，不用单元测试替代 |

所有阶段完成报告必须给出精确 commit、验证命令和证据范围；一个 passing test 不能自动把整个产品域标为 `Verified`。

### 15. 兼容性与版本策略

- `pi-client`、Pi Node、Relay 和 Pi Node Protocol 独立使用 SemVer。
- 当前 `0.x` 允许明确记录的破坏性变化，但必须提供配置迁移与回退说明。
- `PiNodeApi`、Relay transport、配对 QR schema、capability claims、节点本地 credential schema 和公开 deep link 都是兼容面。
- protocol handshake 必须携带 major/minor；不兼容 major 明确拒绝，不能静默降级为明文或无认证模式。
- Direct 与 Relay 都连接 Pi Node；它们不形成两套业务 API。
- 当前 `pi-web URL/password` 配置属于 MVP 遗留面。删除前必须提供明确迁移提示，不把它升级为长期兼容承诺。
- 外部产品可以用于发现候选想法，但其版本和实现变化不自动改变本项目协议、requirements 或 release。
- Passkey RP ID 绑定公网域名。更换 RP ID 会要求重新注册 Passkey，属于明确迁移事件。
- 节点身份密钥轮换会改变节点指纹或 nodeId，必须经过本地确认并重新配对。

### 16. 决策路径

#### D1 - pi-web 的角色

- 选项 A：运行时依赖 pi-web 服务端和内部 API。
- 选项 B：复制 pi-web 服务端代码形成自己的网关。
- 选项 C：只借鉴产品能力，独立实现 Flutter、Pi Node 和 Protocol。
- 选择：C，由用户明确指定，记录在 `DEC-012`。
- 同意影响：P1 必须替换当前 `PiWebGateway`，Pi Node 直接集成 Pi Runtime。
- 否决影响：A 和 B 均违背用户目标，不再作为实施路径。

#### D2 - “无存储”的定义

- 选项 A：包括 RAM 在内完全不接触用户数据。
- 选项 B：Relay 不持久化用户数据，只允许有界、短时、可清空的内存处理。
- 推荐：B；A 无法实现网络中转。
- 同意影响：必须定义 TTL、内存上限、日志禁区和重启清空测试。
- 否决影响：如果否决 B，则应取消中心中转目标，而不是伪称可实现。

#### D3 - Passkey credential owner

- 选项 A：Relay 保存 Passkey records。
- 选项 B：外部身份服务保存 Passkey records。
- 选项 C：用户侧 Pi Node 保存和验证 Passkey records，Relay 校验节点签发的 capability。
- 推荐：C。
- 同意影响：没有中心账号、跨节点账号列表和云端恢复；节点离线时不能认证。
- 否决影响：A 违反零持久化；B 把用户身份数据转移给第三方而不是消除存储。

#### D4 - Relay 转发粒度

- 选项 A：任意 TCP tunnel。
- 选项 B：Relay 实现 Pi 业务 API。
- 选项 C：Relay 只承载 E2EE 后的第一方 Pi Node Protocol 帧。
- 推荐：C。
- 同意影响：需要 stream multiplexing、backpressure、capability 和 conformance suite。
- 否决影响：A 扩大内网代理风险；B 让 Relay 接触业务语义和 payload。

#### D5 - 内层加密

- 选项 A：仅使用 Client/Pi Node 到 Relay 的外层 TLS。
- 选项 B：外层 TLS 加 Client-to-Pi Node E2EE。
- 推荐：B。
- 同意影响：需要标准密码协议依赖评估、共享测试向量和密钥轮换设计。
- 否决影响：Relay 虽不落盘，但仍可读取 Pi 会话、文件和凭据流量，不符合最小信任目标。

#### D6 - 项目仓库边界

- 选项 A：Relay、Pi Node 和 Flutter 全部放入当前仓库。
- 选项 B：当前仓库继续拥有 Flutter；新 `pi-remote` 仓库拥有 Protocol、Pi Node 和 Relay。
- 选项 C：Pi Node、Relay 和 Protocol 各自独立仓库。
- 推荐：B。
- 同意影响：形成两个第一方源码项目和多项独立 artifact，但避免污染 Flutter 根目录。
- 否决影响：A 耦合构建/发布；C 在首版增加跨仓同步成本。

#### D7 - 外部产品参考方式

- 选项 A：把外部产品的 UI 和行为视为必须复制的验收标准。
- 选项 B：只把外部产品当作候选灵感，由本项目 requirements 独立决定范围和验收。
- 推荐：B。
- 同意影响：平台体验、状态和能力可以按用户目标独立设计，不承担外部产品兼容承诺。
- 否决影响：A 会把其他产品的偶然实现错误升级为本项目契约。

#### D8 - 多实例路由

- 选项 A：使用 Redis/数据库保存 nodeId presence。
- 选项 B：单实例起步，随后使用 nodeId 确定性分片/边缘一致性路由和实例内存 presence。
- 推荐：B。
- 同意影响：Pi Node/Client 需使用同一分片算法，实例故障会触发重连而不是状态迁移。
- 否决影响：A 引入中心用户路由状态，不满足本计划的数据边界。

### 17. 实施顺序约束

必须按以下依赖顺序执行：

```text
独立产品需求矩阵与 Pi Runtime 边界
-> 独立 requirements/decision/verification
-> Pi Node Protocol 与 Direct vertical slice
-> Flutter module migration and PiWebGateway removal
-> Relay + Passkey + capability + E2EE
-> 完整会话/消息能力
-> 文件/Git/worktree
-> 模型/Provider/设置
-> Skills/Plugins/Subagents/Extensions
-> 平台等价与生产化
```

不得：

- 在任何目标模块中导入、复制或调用 pi-web 代码。
- 在 Pi Runtime integration 未确定前模仿 pi-web route 定义自己的协议。
- 在 Passkey owner 未确定时先写中心用户表。
- 在 E2EE 未确定时把 Pi payload 当作普通 Relay JSON API。
- 在 `PiNodeApi` 建立前让每个 Feature 分别实现 Direct/Remote 分支。
- 用一份巨大 `WorkspaceModel` 承载所有未来域。
- 把当前已通过的 MVP tests 删除后以“新架构尚未完成”为理由降低验证。
- 将 Relay 日志、分析平台或托管代理的默认访问日志排除在“无用户数据”审计之外。
- 为了功能完整性而绕过项目 trust、路径安全和破坏性操作确认。

### 18. 总体验收条件

仅当以下条件同时满足，才能称为“独立 Pi Client 已完成目标能力并支持公网访问”：

- 用户确认的 requirement/interaction matrix 没有未分类项。
- 所有 `Planned` 和 `Native-adapted` 项有实现与对应验证；`Not-applicable` 有理由和用户影响。
- 用户不安装、不启动 pi-web，也能完成全部产品流程。
- 代码、依赖、构建、部署和运行时中不存在 pi-web artifact。
- Direct 与 Relay 对全部已支持 Pi Node operations 行为等价。
- Passkey 首次配对、注册、认证、添加、撤销和本地恢复路径可验证。
- Relay 无用户数据库、无离线队列、无 payload 解密、无用户数据日志，重启后没有用户状态恢复。
- E2EE、capability、operation authorization、背压、限流、断线和重放负面测试通过。
- Flutter contracts、routes、generation、analysis、tests、Golden 和目标平台 builds 通过。
- Client、Pi Node、Relay、Protocol 和 Pi Runtime dependency 版本边界在 README/部署文档中明确。
- 所有已知差异仍在矩阵中，不用“核心功能已完成”替代全量完成判断。

### 19. 外部依据

- `DEC-012`：pi-web 只可提供非权威产品灵感，不能成为需求、代码、协议或运行时依赖。
- Pi Runtime：实施前必须选择并固定经过依赖评估的官方 Pi SDK、RPC 或 CLI 边界。
- W3C Web Authentication Level 3：Passkey/WebAuthn Relying Party registration 和 authentication operations。
- Google Server-side passkey authentication：认证需要一次性 challenge、用户/credential 查找和 credential public key verification。
- 当前项目治理来源：`docs/requirements.md`、`docs/baseline.md`、`docs/benchmark.md`、`docs/verification.md` 和 `docs/decisions/`。

### 20. Breaking changes

- 本次修订对前一版计划构成**架构级 Breaking correction**：删除“Connector 转发本地 pi-web”的目标路径，改为 Pi Node 直接集成 Pi Runtime。
- 本次只修改 Planned 文档和决策记录，不改变当前已发布 `0.0.1` 运行时。
- 实施 P1 时，当前 `PiWebGateway`、pi-web URL 和 Basic Auth 配置将进入迁移/删除流程；该实现变更属于 `0.x` 破坏性变化，必须另行记录迁移、回退和验证证据。
