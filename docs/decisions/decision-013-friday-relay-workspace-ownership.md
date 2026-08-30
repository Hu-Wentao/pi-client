---
mdq:
  version: 2
  dialect: gfm
  actors: {read: mixed, write: machine}
  records:
    boundary:
      source: heading
      levels: [2]
      pattern: '^(?P<id>DEC-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$'
    key:
      source: heading
      pattern: '^(?P<id>DEC-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$'
      group: id
  fields:
    title: {source: heading, group: title}
    status: {source: label, labels: [状态, Status]}
    selected: {source: label, labels: [选择, Selected]}
    review_level: {source: label, labels: [评审级别, Review level]}
    raw: {source: body}
  queries:
    decision_by_id:
      when: {pattern: '^DEC-[0-9]{3}$'}
      match: {source: key, operator: eq}
      select: [title, status, selected, review_level]
      expect: {max_record_lines: 52, max_record_bytes: 10240, structured: true, min_confidence: 1.0}
  maintenance:
    query_contract: {mode: locked}
---
# 项目决策记录

默认评审级别：L6。

## DEC-013 - Friday Relay 拥有中心 Workspace 服务

- 状态：Accepted
- 评审级别：L9
- 问题：跨平台 Native/WebAssembly Pi Client 的中心身份、付费权益、独立子域和公网接入由哪个项目拥有。
- 选项 A：在 pi-client 中实现用户、Passkey、订阅、子域和 Relay 控制面。
- 选项 B：Pi Node 自行拥有 Passkey 和用户身份，中心只做无状态转发。
- 选项 C：friday-relay 拥有 User/Passkey/OIDC、Commerce/Entitlement、Pi Workspace、平台子域、Node enrollment、access grant 和公网 ingress；pi-client 只实现标准 auth adapter、安全 projection 和 Pi tunnel UI/transport。
- 推荐：选项 C；它复用 friday-relay 已有 Identity、Passkey、OIDC、Billing 和 Entitlement owner，把中心复杂度留在中心项目，并最小化 Native/WASM 客户端鉴权代码。
- 选择：选项 C
- 同意影响：每个 Friday user 第一版最多一个个人 Workspace和平台管理子域；WebAssembly 使用 canonical Friday auth handoff与host-only session；Native使用新增public OIDC + PKCE profile；付费 access由friday-relay实时Decision；Pi业务payload仍不得持久化到friday-relay；Native Local Direct不依赖Friday身份或订阅。
- 否决影响：选项A复制Friday Identity/Billing并扩大客户端安全面；选项B无法满足中心付费服务和统一用户子域目标。
- 与历史决策的关系：`DEC-012`继续禁止任何pi-web代码依赖；本决策取代`PLAN-PI-001`中的Stateless Relay和Pi Node自有Passkey设计，不改变已交付MVP历史。
- 跨项目边界：friday-relay新增能力必须在其独立治理流程和worktree中实施；本仓库只能消费受版本管理的公共合同，不能直接读取Friday Relay数据库或内部Repository。
- 兼容性：Native public OIDC、Workspace Host、Pi Workspace entitlement和Node tunnel都是新兼容面；不得通过放宽现有confidential OIDC、Team DomainBinding或Model Access Plan语义实现。
- 标签：`decision/013-friday-relay-workspace-ownership`
