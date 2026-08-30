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
      expect: {max_record_lines: 48, max_record_bytes: 8192, structured: true, min_confidence: 1.0}
  maintenance:
    query_contract: {mode: locked}
---
# 项目决策记录

默认评审级别：L6。

## DEC-012 - pi-web 仅作为产品参考

- 状态：Accepted
- 评审级别：L9
- 问题：后续架构是否依赖 pi-web 服务端、内部 API 或源码实现。
- 选项 A：Flutter 和远程 Connector 继续把 pi-web 作为本地运行时网关。
- 选项 B：复制或改造 pi-web 的服务端代码，形成项目自己的网关。
- 选项 C：pi-web 只用于产品能力、信息架构和交互状态借鉴；项目独立实现 Flutter Client、Pi Node、Protocol 和 Relay，Pi Node 直接集成经过评审的官方 Pi Runtime 边界。
- 推荐：选项 C；它符合用户“只借鉴 pi-web，不依赖任何 pi-web 代码”的明确目标，并建立本项目自己的协议和运行时边界。
- 选择：选项 C
- 同意影响：目标产品不得要求安装或运行 pi-web，不得调用 pi-web HTTP/SSE API，也不得导入或复制其源码；当前 `PiWebGateway` 仅保留为已交付 MVP 的历史实现，并在 P1 迁移到 `PiNodeApi` 后删除。
- 否决影响：选项 A 会让产品继续依赖 pi-web；选项 B 会把参考实现变成代码来源，二者均违背用户目标。
- 与历史决策的关系：`DEC-004` 继续描述 `0.0.1` MVP 已经采用的临时协议事实；本决策负责后续目标架构，不回写或伪造历史。
- 兼容性：实施 P1 将移除 pi-web URL/Basic Auth 作为目标产品配置，属于后续 `0.x` Breaking Change；实施前必须记录迁移、回退和验证证据。
- 标签：`decision/012-pi-web-reference-only`
