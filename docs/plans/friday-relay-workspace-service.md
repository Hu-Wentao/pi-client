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
      expect: {max_record_lines: 650, max_record_bytes: 131072, structured: true, min_confidence: 1.0}
    plans_by_status:
      match: {source: field, field: status, operator: eq}
      select: [title, review_level, target]
      expect: {max_total_bytes: 262144, structured: true, min_confidence: 1.0}
  maintenance: {query_contract: {mode: locked}}
---
# Pi Client Relay 技术方案

默认评审级别：L3。跨平台客户端、WebAssembly 客户端、一名用户一个独立子域、中心服务付费、复用 friday-relay 用户身份及“pi-client 不复制中心鉴权复杂度”为 L9；Friday Relay 当前边界来自其 Active baseline；新增 Workspace、Native OIDC 和 Tunnel 能力仍为 Planned。

## PLAN-PI-002 - Friday Relay Workspace 中心接入服务

- Status: Planned
- Review level: L9（产品边界）/ L3（技术设计）
- Target: 原生与 WebAssembly Pi Client 通过 friday-relay 用户身份、付费权益和独立 Workspace 子域访问用户自己的 Pi Node
- Supersedes: `PLAN-PI-001` 中关于 Stateless Relay、Pi Node 自有 Passkey 和中心零身份状态的设计
- Friday Relay evidence: `@friday-relay/identity` 拥有 User、Passkey、WebAuthn、Friday/OIDC session；Entitlement 和 Billing/Commerce 拥有付费授权；现有动态 Public Host 不自动成为 Passkey RP
- 当前状态说明：本文只定义跨项目目标边界，不表示 friday-relay 已经提供 Pi Workspace、Native OIDC、Wildcard Workspace Host 或 Pi Tunnel。

### 1. 产品目标

系统最终由以下客户端组成：

- macOS、Windows、Linux、iOS 和 Android 原生客户端。
- 由同一 Flutter 工程构建的 WebAssembly 客户端。
- 用户设备上独立运行的 Pi Node。

中心化访问是一项 friday-relay 付费服务：

- 每个 Friday Relay user 最多拥有一个个人 Pi Workspace。
- 每个 Workspace 拥有一个唯一的平台子域名，例如 `https://WORKSPACE_SLUG.pi.example.com`。
- Native App 和 WebAssembly Client 访问同一个 Workspace 与 Pi Node。
- 用户身份、Passkey、中心 session、付费订单、订阅权益、Workspace/Subdomain 映射和中心风控均由 friday-relay 拥有。
- pi-client 不实现密码登录、Passkey ceremony、账户恢复、计费、套餐、订阅续期或中心用户数据库。
- 用户的 Pi session、prompt、message、file、Git、tool output 和 Provider credential 不进入 friday-relay 的持久业务存储。

访问模式分离：

- **Local Direct**：Native Client 在本机或局域网直连 Pi Node，不要求 Friday Relay user 或付费 entitlement；它使用独立的节点本地配对边界。
- **Friday Workspace**：Native Client 或 WebAssembly Client 通过独立子域和 Friday Relay 访问 Pi Node；该模式要求 Friday identity 与 active paid entitlement。
- WebAssembly Client 由 Friday Relay Workspace Host 承载，因此第一版只提供 Friday Workspace 模式，不提供浏览器直连任意 LAN Node。
- Friday Workspace entitlement 只能控制中心接入，不得禁用或改变用户已有的 Local Direct 能力。

### 2. 核心架构

```text
Friday Relay canonical Web/Auth
  - User / Passkey / OIDC
  - Billing / Entitlement
  - PiWorkspace / Subdomain directory
  - Node enrollment / access grants
             |
             | identity + paid access
             v
https://WORKSPACE_SLUG.pi.example.com
  - Friday Relay workspace ingress
  - static Flutter WebAssembly assets
  - host-only workspace session
  - encrypted Pi tunnel endpoint
             |
     +-------+-------------------+
     |                           |
WebAssembly Pi Client       Native Pi Client
     |                           |
     +------ E2EE Pi Protocol ---+
                 |
          Friday Relay data plane
                 |
          outbound node tunnel
                 |
              Pi Node <----------- Native Local Direct
                 |
        Pi SDK / Pi Runtime
```

本方案把中心复杂度集中在 friday-relay：

- **Control plane**：身份、订阅、Workspace、子域、Node enrollment、授权和审计。
- **Data plane**：验证短期 grant、定位在线 Node、转发 E2EE 帧、执行背压和连接生命周期。
- **Pi Client**：触发标准登录、读取安全 session projection、取得 access grant、连接 Pi Node、显示产品状态。
- **Pi Node**：执行 Pi 业务和保存用户 Pi 数据。

### 3. Friday Relay 当前可复用边界

方案只能复用 friday-relay 已有的 owner，不在 pi-client 重建同类能力。事实依据是 friday-relay 的 `identity-tenancy-contexts.md`、`authority-entitlement-contexts.md`、`billing-commerce-contexts.md`、`service-access-hosting-topology.md`、`domain-binding.md`、`admin-user-identity-model.md`、`fixed-client-oidc-provider.md` 和 `user-passkey-login.md`：

| Friday Relay owner | 当前可复用语义 | 本方案新增需求 |
| --- | --- | --- |
| Identity | User、password、Passkey、WebAuthn ceremony、Friday session、OIDC credential | Pi Client Native public client profile、Workspace session handoff |
| Authority/Tenancy | enabled user、`authVersion`、Team 与平台授权边界 | Pi Workspace 不继承 Team/Admin role；只绑定 owner user |
| Entitlement | Plan/Subscription 与 typed access Decisions | 新增个人 Pi Workspace service entitlement Decision |
| Billing/Commerce | Product、Order、Payment、ServiceFulfillment、Stripe/线下支付事实 | 新增命名的 `pi_workspace_access` 商品与履约，不使用通用自由 effect |
| Domain/Host | Public Host admission、DomainBinding、Caddy/Cloudflare 受治理入口 | 新增平台 wildcard Workspace Host；不得复用 Team custom `domain_bindings` 语义 |
| Audit/Observability | allowlisted actor/action metadata 与 secret 禁区 | Workspace、Node enrollment、grant 和连接结果的低基数审计/指标 |

Friday Relay 当前 fixed-client OIDC 只支持 confidential Web/BFF profile，并明确排除 Native、SPA 和动态 client。本方案必须在 friday-relay 中新增独立受治理的 Pi Client profile，不能通过放宽现有 profile 实现。

### 4. 领域所有权

| 领域 | Owner | 必须拥有 | 禁止旁路 |
| --- | --- | --- | --- |
| Identity | friday-relay Identity | User、Passkey、password、session、OIDC、禁用和 `authVersion` | pi-client 不保存密码或实现 WebAuthn server |
| Commerce | friday-relay Billing/Commerce | Workspace 商品、订单、支付、退款和履约事实 | pi-client 不推断订阅状态或自行解锁服务 |
| Entitlement | friday-relay Entitlement | Workspace 使用期、暂停、到期和 access Decision | token claim 不能成为长期授权真相源 |
| Pi Workspace | friday-relay 新 Context | 一用户一 Workspace、slug、hostname、生命周期、Node binding | 不复用 Team DomainBinding 或 AccessPoint Plan |
| Workspace ingress | friday-relay | Host 解析、session/grant、静态 WASM、Tunnel 路由 | Pi Node 不决定公共 hostname |
| Pi product state | Pi Node | Pi session、files、Git、models、skills、runtime | friday-relay 不持久化 Pi payload |
| Client state | pi-client | 页面状态、安全 user/workspace projection、短期连接状态 | 不复制 Identity、Billing 或 Entitlement model |

### 5. Pi Workspace 数据模型

friday-relay 应新增独立、命名明确的 Pi Workspace Context。以下是语义草案，不是已批准的 Prisma schema：

```text
PiWorkspace
- id
- ownerUserId              UNIQUE, one workspace per user
- slug                     UNIQUE, DNS-safe
- hostname                 UNIQUE, server-derived
- lifecycle                provisioning | active | suspended | closing
- entitlementRef
- createdAt / activatedAt / suspendedAt

PiNodeRegistration
- id
- workspaceId
- nodePublicKeyThumbprint
- lifecycle                pending | active | revoked
- protocolMajor / protocolMinor
- enrolledAt / lastConnectedAt / revokedAt

PiNodeEnrollment
- id
- workspaceId
- secretHash
- expiresAt
- consumedAt
```

固定规则：

- `ownerUserId` 来自 Friday session，不接受客户端 body 指定。
- 每个 user 最多一条未关闭 Workspace。
- `slug` 使用小写 ASCII DNS label，拒绝保留字、混淆字符和公共服务名称。
- 第一版 slug 在激活后不可修改，避免 hostname、cookie、deep link 和证书语义迁移。
- `hostname` 只能由 `slug + managed workspace base domain` 在服务端生成。
- Workspace entitlement 与 lifecycle 分离：购买事实不直接等于 Node online，Node offline 也不取消订阅。
- Node public key 只用于节点身份和 E2EE，不承载 Friday user role。

平台子域不复用现有 `domain_bindings`：后者表达用户自带域名、DNS TXT 验证、Team allowlist 和付费 slot；本方案的 hostname 是 Friday Relay 自己管理的 wildcard 子域，并绑定个人 Workspace。

### 6. 独立子域与入口路由

#### 6.1 DNS 与 TLS

Friday Relay 运维层提供：

```text
*.pi.example.com -> Friday Relay Workspace ingress
```

- 使用平台控制的 wildcard DNS 和 TLS certificate。
- `WORKSPACE_SLUG.pi.example.com` 必须先解析成唯一 active Workspace，再解析 user 或 node。
- 未知、suspended、closing Workspace 不回退到公开主站或其他用户 Workspace。
- `Host` 是入口身份来源；不信任客户端提交的 `X-Forwarded-Host`。
- Workspace Host 与 Admin、canonical Friday Web、Gateway Host 和用户自定义 DomainBinding Host 分离。

#### 6.2 路径所有权

推荐在每个 Workspace origin 固定以下路径：

```text
/                         Flutter WebAssembly shell
/assets/*                 content-hashed WASM/static assets
/_friday/session          safe identity/workspace/entitlement projection
/_friday/auth/start       canonical Friday login handoff
/_friday/auth/callback    one-time handoff exchange
/_friday/access-grant     short-lived Pi tunnel grant
/_pi/connect              encrypted Pi Protocol WebSocket
```

- Friday Relay ingress 拥有全部路径路由，不把任意 HTTP path 转发给 Pi Node。
- Pi Node 只接收 `/_pi/connect` 内已经授权和加密的 Pi Protocol stream。
- HTML 使用短缓存或 revalidate；content-hashed WASM/assets 使用 immutable cache。
- WebAssembly Client 不能覆盖 auth/control 路径，也不能从 Node 动态加载可执行脚本。

### 7. 鉴权最小化设计

#### 7.1 pi-client 的责任

pi-client 只定义一个小型 `CentralAccessGateway`：

```text
observeSession()
beginLogin()
completeLoginCallback()
logout()
loadMyWorkspace()
requestWorkspaceAccessGrant()
```

客户端只保存和展示：

```text
CentralSessionStatus
- unknown | anonymous | active | reauthenticationRequired

WorkspaceAccessStatus
- provisioning | subscriptionRequired | active | suspended | nodeOffline

CentralUserProjection
- stable user id
- safe display email, if Friday Relay chooses to expose it

WorkspaceProjection
- workspace id
- slug
- origin
- lifecycle
- entitlement summary
- node online state
```

客户端不得拥有：

- password form 或 password policy。
- Passkey registration/authentication options、credential records 或 WebAuthn verification。
- Friday refresh-token rotation rules。
- Billing product、price、order、subscription 或 refund state machine。
- Workspace slug uniqueness、hostname allowlist、entitlement Decision 或 Node ownership判断。

购买、续费、Passkey 管理和账户恢复进入 Friday Relay canonical Web 页面；Native App 使用系统浏览器打开，WebAssembly Client 使用受控同站跳转。

#### 7.2 WebAssembly Client

WebAssembly 不能安全持有 client secret 或长期 bearer token。推荐使用 Workspace Host BFF session：

1. 浏览器访问 `https://WORKSPACE_SLUG.pi.example.com`。
2. `/_friday/session` 没有有效 host-only session 时，WASM 调用 `/_friday/auth/start`。
3. Friday Relay 把浏览器导航到 canonical Friday Web/Auth。
4. 用户在 canonical origin 使用 Friday Relay 已有 password、Passkey 或未来身份方式登录。
5. Friday Relay 从服务端 Workspace record 计算 exact callback origin，不接受请求提供的任意 redirect。
6. canonical auth 签发一次性、短 TTL、hash-only handoff code。
7. Workspace callback server-side exchange code，并设置 Secure、HttpOnly、SameSite、host-only Workspace session Cookie。
8. WASM 只读取安全 session projection，不读取 Cookie 或 token 原文。

Workspace 子域不直接运行 Passkey ceremony。这样保持 friday-relay 当前“Passkey 仅限显式 canonical origin/RP”的安全边界，也避免把所有用户子域纳入共享 RP 信任范围。

#### 7.3 Native Client

Native App 使用 Friday Relay 新增的 public OIDC client profile：

- Authorization Code + PKCE `S256`。
- 无 client secret。
- 系统浏览器完成 canonical Friday 登录和 Passkey。
- 精确 allowlist 的 universal/app link callback；不接受任意 return URL。
- Access token audience 只允许 Pi Workspace control plane，不允许 Gateway `/v1/*`、Admin 或普通 Web User API。
- 短期 access token；如需要长期登录，使用旋转且 device-bound 的 refresh credential，保存在 OS secure storage。
- Native Client 不解析 Friday roles、Plan 或 Billing claims；只请求 server-side Workspace Decision。

该 profile 是 friday-relay 新需求。不能复用当前 confidential OIDC client，也不能把 secret 嵌入 App。

### 8. Passkey 边界

Passkey 完全属于 friday-relay Identity：

- 用户在 Friday Relay canonical Web/Auth 注册、管理和使用 Passkey。
- pi-client 不依赖 `@simplewebauthn/*`，不拥有 RP ID、origin、challenge 或 credential schema。
- Native App 通过系统浏览器进入 canonical login，不在 App 内复制 Passkey UI。
- WebAssembly Workspace origin 通过 canonical auth handoff 登录，不成为动态 Passkey origin。
- Friday Relay user disabled、`authVersion` 变化、session revoke 和 Passkey 删除语义继续由 Identity 决定。
- Passkey 只证明 user identity；Workspace ownership 和 paid access 在认证后由 Pi Workspace/Entitlement 决定。

### 9. 付费权益

Friday Workspace 中心接入只能在 friday-relay 返回 active entitlement Decision 时使用。Local Direct 不查询也不消费该 entitlement。

推荐新增命名业务能力：

```text
ServiceProduct: pi_workspace_access
Billing Order: purchase / renew
ServiceFulfillment: create-or-renew personal Pi Workspace entitlement
Entitlement Decision: decidePiWorkspaceAccess(userId, workspaceId, at)
```

边界：

- Billing/Commerce 拥有价格、订单、付款、退款和履约事实。
- Entitlement 拥有有效期、暂停、到期和 access Decision。
- Pi Workspace Context 拥有 workspace 和 subdomain，不拥有金额或付款状态。
- Identity 只证明 actor，不读取 Billing 表推断 entitlement。
- Ingress 和 grant issuer 调用 typed Entitlement Decision，不直接查 subscription 表。
- 不使用 Model Access 的 AccessPoint/Plan entitlement 表达 Pi Workspace 服务；两者是不同产品能力。
- friday-relay 当前 `ServiceProduct` 只接受 `partner_team_annual`，实施时必须增加命名 effect 和对应 transaction，不能开放 caller-selected generic fulfillment。

访问检查顺序：

```text
valid Friday identity
AND user owns workspace
AND workspace lifecycle allows access
AND active Pi Workspace entitlement
AND node registration active
AND node currently online
```

稳定产品结果：

- `401 authentication_required`
- `402 pi_workspace_subscription_required`
- `403 pi_workspace_forbidden`
- `409 pi_workspace_provisioning`
- `423 pi_workspace_suspended`
- `503 pi_node_offline`

pi-client 只把这些结果映射为登录、购买、等待开通、联系支持或重试状态，不自行改变授权结论。

### 10. Node enrollment 与 Tunnel

#### 10.1 Enrollment

1. 用户在 Friday Relay Web 或已登录 Native App 请求 Node enrollment。
2. friday-relay 验证 user、workspace ownership 和 entitlement。
3. friday-relay 创建一次性短 TTL enrollment secret，只持久化 hash。
4. Pi Node 首次启动生成长期 node keypair，并提交 workspace ID、enrollment secret 和 public key。
5. friday-relay 原子消费 enrollment、绑定 node key、撤销旧 active node 或按明确 replacement flow 拒绝。
6. Pi Node 获得只允许建立该 Workspace outbound tunnel 的 node credential。

Pi Node 不接收 Friday password、Passkey credential、refresh token 或 Billing 数据。

#### 10.2 Outbound tunnel

- Pi Node 主动连接 friday-relay，不要求用户开放入站端口。
- Node 通过签名 challenge 和短期 node lease 证明已注册 key。
- Relay tunnel registry 可以保存在连接 owner 实例内存中；PostgreSQL只保存 Workspace/Node identity 与 lifecycle。
- friday-relay 当前基线规定 PostgreSQL 是唯一运行时数据库，因此首版不引入 Redis presence authority。
- 多实例优先使用 workspace/node ID 确定性分片，使 client ingress 和 node tunnel 到达同一 connection owner；跨 shard forwarding 需要单独评审。
- tunnel lease 到期、entitlement失效、node revoked 或 workspace suspended 时关闭连接。

### 11. Access grant 与 E2EE

Friday Relay 身份和付费授权是信任根，但 Pi payload 仍应保持 Client-to-Node 端到端加密：

1. Client 生成临时连接公钥。
2. `/_friday/access-grant` 验证 session、workspace ownership、entitlement 和 node online。
3. friday-relay 签发短期 access grant，绑定 user ID、workspace ID、node key thumbprint、client key thumbprint、scope、issuedAt、expiresAt 和 grant ID。
4. Client 与 Pi Node 使用 grant 建立标准化 E2EE handshake。
5. Relay 只验证 grant envelope、路由和流量限制，不解密 Pi Protocol payload。
6. Node 验证 Friday Relay issuer、workspace、node key、client key、scope 和 expiry。

Access grant 目标 TTL 为 5 分钟；长连接必须在到期前重新授权或续租。Subscription 被取消、user disabled 或 Workspace suspended 后，短 TTL 限制撤权延迟；若产品要求即时断开，Friday Relay 需要增加 control-plane disconnect signal。

禁止自创密码学算法。应评估并固定具有 Dart/WebAssembly 和 Pi Node 实现的 Noise/HPKE 等标准方案与测试向量。

### 12. Friday Relay 数据边界

#### 12.1 允许持久化

- User、Passkey、Friday/OIDC session。
- Billing product/order/payment、subscription/entitlement。
- Workspace ID、owner、slug、hostname、lifecycle。
- Node public-key thumbprint、registration lifecycle 和非敏感 protocol version。
- Hash-only enrollment/handoff/access credential 状态。
- Allowlisted audit facts与低基数 operational metadata。

#### 12.2 禁止持久化或记录

- Pi prompt、message、thinking、tool call/result。
- Session transcript、project path、file name/content、Git diff。
- Pi Provider credential、model key、Node private key。
- E2EE plaintext、decrypted frame、完整 access grant/token/cookie。
- Authorization header、WebAuthn material、refresh credential 和自由文本错误正文。

Relay 可以持有有界的 encrypted frame buffer、connection metadata 和背压窗口；连接结束后释放。Friday Relay 已有 Capture 例外不自动适用于 Pi Tunnel；Pi Protocol payload 必须明确排除 Capture。

### 13. Flutter 跨平台架构

```text
lib/central_access/
  central_access.dart
  central_access.c.dart
  central_access.vm.dart
  friday_relay_auth.srv.dart
  workspace_directory.srv.dart

lib/transport/
  pi_transport.dart
  direct_node_transport.dart          # Local Direct, no Friday identity
  friday_relay_tunnel_transport.dart  # Paid Friday Workspace

lib/platform/auth/
  native_oidc_adapter.dart
  web_workspace_session_adapter.dart

lib/platform/secure_storage/
  native_secure_storage.dart
  web_no_secret_storage.dart
```

要求：

- Domain Feature 只依赖 `PiTransport`；只有 Friday Workspace shell 依赖 `CentralAccessGateway` 和 `WorkspaceDirectory`。
- 使用 conditional import 隔离 `dart:io`、浏览器 API、deep link 和 secure storage。
- WebAssembly build 不引入不支持 WASM 的 native auth/crypto/storage package。
- Web 不保存 access/refresh token到 localStorage、sessionStorage、IndexedDB 或 Flutter state serialization。
- Native rotating credential 只进入 OS secure storage，不进入 FlowR Model、route、日志或 crash report。
- friday-relay 的 Product、Subscription 和 User 完整 DTO 不进入客户端；只返回安全 projection 和 action URL。
- 购买/续费 UI 使用 friday-relay Web，不在 Flutter 复制 commerce form。

### 14. WebAssembly 发布与版本

- Friday Relay Workspace ingress 托管经过签名/哈希验证的 Flutter WebAssembly artifact。
- HTML/shell 与 hashed assets 使用不同缓存策略，避免 shell 引用已移除 artifact。
- Workspace Host 只选择已经发布且兼容当前 Pi Node Protocol major 的 Client release。
- 原生 App、WASM Client、Pi Node Protocol 和 friday-relay Workspace API 分别使用 SemVer。
- WebAssembly rollout 支持 staged release 和快速回退；回退不能改变 Identity、Billing 或 Workspace 数据语义。
- Service Worker/PWA 属于可选后续能力，不是 WebAssembly 交付前提。

### 15. Friday Relay 需要新增的能力

这些修改属于 friday-relay 项目，不在 pi-client 中实现：

1. Pi Workspace Context、schema、Queries、Commands 和 lifecycle。
2. `owner_user_id` 唯一的 Workspace 和唯一 slug/hostname。
3. `pi_workspace_access` Product/Order/Fulfillment 与 Entitlement Decision。
4. Wildcard Workspace Host admission 与 exact host routing。
5. Workspace canonical-auth handoff 和 host-only session。
6. Native Pi Client OIDC public profile：PKCE、无 secret、exact callback、可选 rotating device-bound refresh。
7. Node enrollment、key registration、revocation 和 lease。
8. Workspace access grant issuer 与 signing-key rotation。
9. Outbound tunnel registry、deterministic shard routing、backpressure 和 disconnect。
10. Static Flutter WebAssembly artifact hosting和 release selection。
11. Pi payload Capture exclusion、audit allowlist、metrics 和 secret sentinel。
12. User Console 中的 Workspace、subscription、node status、enrollment 和 purchase/manage入口。

friday-relay 新增能力必须在其独立治理流程和隔离 worktree 中实施；本仓库只消费受版本管理的公开合同，不直接修改或读取 friday-relay 的内部数据库与 Repository。

### 16. Pi Client 需要新增的能力

1. 跨平台 `CentralAccessGateway`。
2. Web Workspace session adapter。
3. Native public OIDC + PKCE adapter。
4. 安全 `CentralUserProjection` 与 `WorkspaceProjection`。
5. Local Direct 与 Friday Workspace mode selection，以及 subscription-required、suspended、provisioning 和 node-offline states。
6. Friday Relay tunnel transport 与 access-grant renewal。
7. Client-to-Node E2EE。
8. Flutter WebAssembly build、asset manifest和 workspace-host bootstrap。
9. 原生 deep link/universal link 与 secure storage。
10. 购买、续费、Passkey 管理和账户恢复的 external Friday Web handoff。

### 17. 分阶段实施

#### R0 - 跨项目契约冻结

- 在 pi-client 记录安全 projection、platform auth adapter 和 tunnel interface。
- 在 friday-relay 建立 Pi Workspace、Identity integration、Entitlement、Billing、Host 和 Tunnel requirements。
- 固定 Workspace base domain、slug policy、OIDC callback、grant claims、E2EE 和 Protocol version。
- 输出两个项目的 requirement/verification traceability，不让一边的测试替另一边声明完成。

退出条件：所有 owner 和反向依赖明确；无 pi-client 自有中心 Identity/Billing 实现。

#### R1 - Friday Relay Workspace control plane

- 实现 Workspace、slug/hostname、paid entitlement、User Console 和 exact Host resolution。
- 实现 canonical auth handoff、Workspace session和安全 session projection。
- 先使用 fake node state，不开放 Pi payload tunnel。

退出条件：一名 enabled user最多一个 Workspace；未付费、暂停和未知 Host 均失败关闭。

#### R2 - Pi Node enrollment 与 tunnel

- 实现 enrollment、node key、outbound tunnel、lease、offline state和 deterministic shard。
- 建立最小 Pi Protocol health/session smoke。

退出条件：Node 不开放入站端口；错误 Workspace/key/enrollment 无法接管 tunnel。

#### R3 - WebAssembly Client

- 生成 Flutter WebAssembly artifact。
- Workspace Host 提供 shell、auth handoff、session projection、grant和 WebSocket。
- WASM 不持有长期 token或 client secret。

退出条件：用户从独立子域登录并连接自己的 Node；跨子域访问失败。

#### R4 - Native Clients

- friday-relay 增加 Native public OIDC profile。
- Flutter 实现 system-browser PKCE、callback和 secure storage。
- macOS、Windows、Linux、iOS、Android 使用相同 Workspace Directory 和 Tunnel。

退出条件：App 不包含 Friday client secret；callback、state、nonce和 PKCE 负向测试通过。

#### R5 - E2EE 与撤权

- 实现 client-key-bound grant、标准 E2EE、renewal和 scope。
- 覆盖 user disabled、subscription expiry、workspace suspend、node revoke和 grant replay。

退出条件：friday-relay 无法读取 Pi payload；授权失效在声明窗口内停止访问。

#### R6 - 付费生产化

- 完成购买/续费/退款/暂停、billing reconciliation、support和 observability。
- 完成 wildcard DNS/TLS、multi-instance、WASM staged rollout和 disaster recovery。

退出条件：付费、域名、身份、Node、Tunnel和客户端均有 production-equivalent evidence。

### 18. 验证矩阵

| 行为 | Primary owner |
| --- | --- |
| User、Passkey、session、禁用和恢复 | friday-relay Identity tests/E2E |
| Native OIDC PKCE 与 callback | friday-relay OIDC + pi-client platform integration |
| Workspace 一用户一条与 slug 唯一性 | friday-relay Workspace storage tests |
| Product、Order、Subscription、refund | friday-relay Billing/Entitlement tests |
| Wildcard Host 与 cross-tenant denial | friday-relay ingress integration |
| Node enrollment、key replacement和 revoke | friday-relay + Pi Node integration |
| Access grant claims/TTL/replay | friday-relay grant tests + Pi Node verification |
| E2EE 与 payload opacity | cross-language vectors、tamper tests、relay sentinel |
| WASM 无 token persistence | browser storage/manual inspection + static scan |
| Native secret storage与 deep link | platform integration/manual verification |
| Direct/Remote Pi behavior | pi-client/Pi Node conformance suite |
| Paid service E2E | Friday login -> purchase -> workspace -> node -> client |

不能用以下证据替代：

- pi-client Widget test不能证明 Friday subscription有效。
- friday-relay auth test不能证明 WASM 未把 token写入 storage。
- tunnel connected不能证明 Pi Node belongs to当前 user。
- payment succeeded不能证明 Workspace fulfillment和 entitlement生效。
- E2EE test不能证明日志、Capture和 crash output无泄漏。

### 19. 决策与影响

#### D1 - 中心身份与付费 owner

- 选择：friday-relay。
- 同意影响：pi-client 删除自有 Passkey server、中心用户和订阅设计，只保留 adapter与 UI state。
- 否决影响：会复制 Identity/Billing，违背本轮目标。

#### D2 - Workspace 与用户关系

- 选择：第一版一名 Friday user 最多一个个人 Workspace。
- 同意影响：`ownerUserId` 唯一，Native/WASM无需 Workspace selector。
- 否决影响：多 Workspace需要新的目录、默认选择、权限和计费模型。

#### D3 - Workspace slug

- 推荐：用户在 provisioning 时选择一次，激活后不可修改。
- 同意影响：hostname、cookie、deep link和证书语义稳定。
- 否决影响：可重命名需要 alias、redirect、保留期和抢注防护。

#### D4 - Web auth

- 推荐：canonical Friday auth + one-time Workspace handoff + host-only session。
- 同意影响：Workspace 子域不进入 Passkey RP，WASM不处理 token。
- 否决影响：在动态子域直接启用 Passkey会扩大 RP trust和前端认证复杂度。

#### D5 - Native auth

- 推荐：独立 public OIDC profile + Authorization Code/PKCE，无 client secret。
- 同意影响：friday-relay必须新增 Native profile和 callback policy。
- 否决影响：复用 confidential client会把不可保密的 secret嵌入 App。

#### D6 - Pi payload privacy

- 推荐：Client-to-Node E2EE，friday-relay只转发 opaque frame。
- 同意影响：需要跨 Dart/WASM/Pi Node crypto contract和 grant key binding。
- 否决影响：friday-relay可读取用户 prompt、file和tool output，扩大中心数据责任。

#### D7 - Paid entitlement model

- 推荐：新增命名 Pi Workspace service product与 entitlement，不复用 AccessPoint Plan。
- 同意影响：Friday Billing/Commerce与Entitlement需要新 workflow。
- 否决影响：复用 Model Access Plan会混淆两种产品权限和计费语义。

#### D8 - Workspace Host 与自定义域名

- 选择：第一版只支持 Friday Relay 管理的 wildcard子域。
- 同意影响：无需用户DNS验证，Host与Workspace可确定映射。
- 否决影响：自定义域名需要独立 DomainBinding、TLS、Passkey和support设计。

### 20. 总体验收

仅当以下条件同时满足，中心化服务才能称为完成：

- 同一个 Friday user在所有平台看到同一个 Workspace和唯一子域。
- Local Direct 在Friday Relay不可用或用户未订阅时仍可独立连接本地Pi Node。
- Friday Workspace的未登录用户只能进入Friday Relay登录；Passkey由canonical Friday origin处理。
- 未购买、已到期或 suspended用户不能取得 access grant或连接 Node。
- WebAssembly没有client secret、refresh token或长期 bearer storage。
- Native App没有Friday client secret，使用system-browser PKCE。
- Pi Node只接受绑定自己Workspace和key的有效grant。
- 另一个user、subdomain或node不能访问当前Workspace。
- friday-relay持久化Identity/Commerce/Workspace控制数据，但不持久化或记录Pi payload。
- Native与WASM通过同一Pi Protocol获得等价产品行为。
- Billing履约、entitlement、Workspace activation和node enrollment保持可解释且幂等。
- Wildcard DNS/TLS、Host admission、shard routing、升级和回退有production-equivalent evidence。

### 21. 兼容性与 Breaking changes

- 本计划取代`PLAN-PI-001`的Stateless Relay和Pi Node自有Passkey设计，属于架构级Breaking Change。
- friday-relay从“仅转发”变为中心Identity、Commerce、Entitlement、Workspace和Ingress owner；它允许持久化控制面用户数据，但仍禁止持久化Pi业务payload。
- 当前friday-relay fixed OIDC client不支持Native；新增public profile是独立协议扩展，不能修改既有confidential client语义。
- 当前Passkey只允许显式canonical origin；Workspace子域通过auth handoff保持该边界，不自动加入RP。
- 当前Team `domain_bindings`不迁移为Pi Workspace hostname；两者继续拥有不同schema和产品语义。
- 当前pi-client的pi-web URL/Basic Auth仍属于MVP遗留实现，后续迁移到Pi Node/Friday Relay时按`0.x`Breaking Change处理。
