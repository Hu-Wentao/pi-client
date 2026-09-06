---
mdq:
  version: 2
  dialect: gfm
  actors: {read: mixed, write: machine}
  records:
    boundary:
      source: heading
      levels: [2]
      pattern: '^(?P<id>TECH-FIT-[A-Z0-9-]+)(?:[ ：:-]+(?P<title>.*))?$'
    key:
      source: heading
      pattern: '^(?P<id>TECH-FIT-[A-Z0-9-]+)(?:[ ：:-]+(?P<title>.*))?$'
      group: id
  fields:
    title:
      source: heading
      group: title
    status: {source: label, labels: [Status, 状态]}
    scope: {source: label, labels: [Scope, 范围]}
    fit: {source: label, labels: [Fit, 适配度]}
    disposition: {source: label, labels: [Disposition, 处置]}
    evaluated: {source: label, labels: [Evaluated, 评估日期]}
    shared_assessment: {source: label, labels: [Shared assessment, 共享评估]}
    shared_revision: {source: label, labels: [Shared revision, 共享修订]}
    upstream_ref: {source: label, labels: [Upstream ref, 上游版本]}
    raw: {source: body}
  queries:
    fit_by_id:
      when: {pattern: '^TECH-FIT-[A-Z0-9-]+$'}
      match: {source: key, operator: eq}
      select: [title, status, scope, fit, disposition, evaluated, shared_assessment, shared_revision, upstream_ref]
      expect: {max_record_lines: 220, max_record_bytes: 65536, structured: true, min_confidence: 1.0}
  maintenance: {query_contract: {mode: locked}}
---
# Mastra project fit

## TECH-FIT-PI-MASTRA: pi-client 使用 Mastra 的可行性

- Status: assessed
- Scope: `node/` 中的桌面 Pi Node 侧 Agent/Workflow 编排、审批、评估与实验能力；不包含 Flutter UI、Pi Protocol 替换、Pi SDK 会话存储替换或移动/Web 宿主运行时。
- Fit: partial
- Disposition: trial
- Evaluated: 2026-09-06
- Shared assessment: `RESOURCE-ASSESS-GITHUB-COM-MASTRA-AI-MASTRA-C597B1A8`
- Shared revision: `sha256:80d4190f3a080f3cec37959e645b8bd2ebc612707b5712da3373308ea5db503d`
- Upstream ref: `@mastra/core@1.63.2` 及共享评估中列出的配套包集合

### 结论

Mastra 对 Pi Client **可行，但只适合先作为 Node 侧的旁路编排能力进行受限试验**。不建议把它直接替换当前 Pi SDK 或第一方 Pi Node domain。推荐的处置是 `trial`：保留现有 Pi SDK、Pi Node domain、PiNodeApi 和 Protobuf transport 作为产品主路径，仅验证 Mastra 是否能为未来的多步任务、审批、评估和可恢复编排提供增量价值。

项目拟采用的上游评估固定为 [Mastra 项目](https://github.com/mastra-ai/mastra) 的共享评估记录与上述修订；上游能力、许可证、版本和通用风险不在本记录重复展开。

### 项目适配判断

1. **运行时落点可行。** 当前 `node/` 已是 ESM TypeScript 包，开发和 Runtime Capsule 使用 Node.js `22.19.0`，因此 Mastra 的 Node 侧集成方向与桌面 Pi Node 的进程边界相容。Bun 是当前构建工具链的一部分，但 Mastra 相关包在本项目中的 Bun 执行兼容性仍需单独验证，不能由安装成功推断。
2. **产品边界可保持。** Mastra 若只存在于 `node/`，Flutter 仍只依赖 `PiNodeApi`，不会把 Mastra 类型、Agent ID、Memory thread 或 Mastra HTTP 路由暴露为客户端合同。Android、iOS、Web 和 WebAssembly 不应打包 Mastra 或任何 Node Agent runtime。
3. **现有 Pi 会话模型不是 Mastra Memory 的同义替代。** 当前 `PublicPiSdkDomainSession` 依赖 Pi SDK 的持久会话、JSONL 历史、分支树、fork/clone、历史游标、统计和导出；这些语义不能直接映射为 Mastra 的 memory thread。若替换，需要重新设计持久化、分支、迁移、事件顺序、统计和导出，并会扩大当前 `REQ-PI-015`、`REQ-PI-016` 与 `REQ-PI-034` 的兼容面。
4. **安全边界要求旁路化。** Mastra 的 Workspace/LocalSandbox 默认可在应用宿主机上执行命令。当前 Pi Client 要求 Project Trust、allowed roots、Pi Node 授权和 1.0 无内置 Shell/PTY；因此试验不得启用生成的宿主命令工具，也不得让 Mastra 绕过 Pi Node 的路径、权限、日志脱敏或确认策略。需要文件或工具能力时，只能通过 Pi Node 自有的、逐操作授权的适配层提供。
5. **Provider 所有权不能分裂。** 当前计划要求 Provider 凭据由 Pi Node 独占管理。Mastra 的模型配置、环境变量和 Memory/Storage 配置不能形成第二套未审计的凭据或持久化入口。试验应优先使用无真实凭据的模型/工具替身，或明确复用 Pi Node 已批准的 Provider 边界。
6. **协议与事件不能隐式扩张。** Mastra 的 Agent stream、workflow stream、tool approval、suspend/resume 事件可以被 Node 内部消费，但不能未经新的 Protocol 设计就直接暴露给 Flutter。若未来产品要展示 workflow run、暂停恢复或工具审批，需要定义新的 Pi Node 领域操作、稳定错误、序列/重连语义和跨 Direct/Friday transport 的一致行为。
7. **发布成本可控但不是零。** 引入 Mastra 会扩大 Bun lock、Runtime Capsule、许可证清单、供应链审查、Node/桌面启动、平台架构和体积验证范围。应优先验证 `@mastra/core` 最小依赖集，避免把 Studio、HTTP server、MCP server 或 Enterprise `ee/` 能力打进桌面产品；任何锁文件或运行时变化都必须重新走现有 Capsule 与六平台门禁。

### 候选路径

| 路径 | 项目结论 | 主要原因 |
| --- | --- | --- |
| 直接用 Mastra 替换 Pi SDK | 不建议；当前范围视为 blocked | 丢失或重建 Pi 会话 JSONL、分支/fork/clone、项目信任、Provider 所有权、导出和既有事件合同，迁移面过大。 |
| 在 Pi Node 内作为旁路 Agent/Workflow 编排器 | 推荐受限 trial | 不改变 Flutter/Protocol 主合同，可为多步任务、审批、评估提供能力；但必须复用 Pi Node 授权和凭据边界。 |
| 把 Mastra 放入 Friday Relay 或公共 BFF | 当前不建议 | Relay 只应承载控制和加密后的不透明 Pi payload，不应获得 Pi prompt、消息、工具数据或 Provider 凭据；需要另立用户拥有的远程 Agent 服务边界。 |
| 仅用于本地开发、评估和实验工具 | 高可行性 | 对产品协议和 Runtime Capsule 影响最小，但不能据此宣称桌面产品已采用 Mastra。 |

### 受限试验边界

- 只在 `node/` 建立隔离 spike，不改 `PiNodeApi`、Protobuf schema、Flutter contract 或现有 Pi SDK session backend。
- 先固定与当前 Node `22.19.0` 相容的 Mastra 包版本，并用 Node 执行；Bun 只作为单独兼容性测试目标。
- 先验证一个不触碰真实项目文件、不启用 Shell 的 workflow，以及一个能消费受控 typed tool 的 Agent；工具输入输出必须经过 Zod/项目自有 DTO 和稳定错误映射。
- 验证 stream 到现有 conversation/event normalizer 的映射、abort signal、重复/迟到事件、失败与恢复、日志脱敏和无凭据启动。
- 验证 Runtime Capsule 的依赖、许可证、大小、启动、平台架构和 mobile/Web 禁止打包扫描；试验失败时不得改变当前 Pi SDK 主路径。

### 退出条件与复审触发器

试验只有在以下证据齐全后才可提出单独的实现授权：Node 与 Bun 的运行时结果、最小包锁与许可证清单、stream/abort/approval/recovery 测试、Project Trust 和 secret scan、Runtime Capsule 与桌面启动验证，以及对现有 Pi session/branch/export 行为无回归的 conformance 结果。

以下变化需要重新评估：Mastra 主版本或 Agent/Workflow stream 合同变化；Workspace sandbox 或 tool approval 语义变化；Memory/Storage ownership 变化；Node/Bun 支持声明变化；Provider、MCP、HTTP server 或 `ee/` 能力进入产品包；Pi Protocol v1、Provider auth、Friday E2EE 或 Runtime Capsule 合同冻结；以及任何需要把 Mastra 状态或事件暴露到 Flutter、Relay 或公共 API 的需求。
