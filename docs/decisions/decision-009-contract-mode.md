---
mdq:
  version: 2
  dialect: gfm
  actors: {read: mixed, write: machine}
  records:
    boundary: {source: heading, levels: [2], pattern: '^(?P<id>DEC-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$'}
    key: {source: heading, pattern: '^(?P<id>DEC-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$', group: id}
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
      expect: {max_record_lines: 44, max_record_bytes: 8192, structured: true, min_confidence: 1.0}
  maintenance: {query_contract: {mode: locked}}
---
# 项目决策记录

默认评审级别：L6。

## DEC-009 - 多端点 pi-web 网关的契约模式

- 状态：Accepted
- 评审级别：L6
- 问题：显式 API 契约只接受一个 query 或 command Behavior，而 Workspace 同时读取会话/消息、创建会话、提交/终止命令并订阅 SSE；项目没有 OpenAPI 或生成 SDK。
- 选项 A：改用 BFF-JSON 并虚构 UI API、OpenAPI 和 `lib/api/gen` SDK。
- 选项 B：保留显式 API 模式，以会话与消息查询作为主 Behavior，把同一上游网关的 command/SSE 端点和所有权写入 Notes，由 [PiWebGateway]、ViewModel 与聚焦测试验证。
- 选项 C：仅为满足契约语法把一个工作区拆成多个各自拥有状态生命周期的组件。
- 推荐：选项 B；它不制造不存在的后端权威，也不为静态语法破坏单页状态所有权。
- 选择：选项 B
- 同意影响：契约校验可证明页面、状态、查询行为和结构；command/SSE 的请求字段、错误与重连由服务/VM 测试承担，README 明确 API 为上游不稳定边界。
- 否决影响：选择 A 会伪造 BFF 权威；选择 C 会让会话、消息和运行状态出现不必要的跨 VM 协调。
- 兼容性：不改变 pi-web 协议；仅明确验证所有权分工。
- 标签：`decision/009-contract-mode`
