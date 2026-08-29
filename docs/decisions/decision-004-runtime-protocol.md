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
      expect: {max_record_lines: 40, max_record_bytes: 8192, structured: true, min_confidence: 1.0}
  maintenance:
    query_contract: {mode: locked}
---
# 项目决策记录

默认评审级别：L6。

## DEC-004 - 客户端运行时协议边界

- 状态：Accepted
- 评审级别：L6
- 问题：Flutter 客户端无法从 UI 对标自动推断如何直接嵌入 Node 版 pi SDK。
- 选项 A：在 Flutter 内重写或嵌入 pi 编程智能体运行时。
- 选项 B：把已运行的 `pi-web` 服务作为本地网关，使用其 HTTP JSON 与 SSE 接口；默认地址 `http://127.0.0.1:30141`，可配置 Basic Auth 密码。
- 选项 C：等待未提供的 `friday-relay` API。
- 推荐：选项 B；它复用已验证的 pi 会话与配置所有权，不把后端能力倒灌到 Flutter MVP，也符合计划中“不接入 friday-relay”的边界。
- 选择：选项 B
- 同意影响：客户端负责连接配置、请求适配、SSE 重连和 UI 状态；`pi-web` 继续拥有会话文件、模型配置、工具执行与安全边界。
- 否决影响：选择 A 会形成未经授权的新运行时；选择 C 会让 MVP 依赖计划明确排除的后续系统。
- 兼容性：`pi-web` API 未声明稳定公共版本，本客户端 `0.x` 将协议适配视为不稳定兼容面并固定对标 commit。
- 标签：`decision/004-runtime-protocol`
