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
      expect: {max_record_lines: 44, max_record_bytes: 8192, structured: true, min_confidence: 1.0}
  maintenance:
    query_contract: {mode: locked}
---
# 项目决策记录

默认评审级别：L6。

## DEC-005 - 首个可交付 MVP 功能清单

- 状态：Accepted
- 评审级别：L6
- 问题：`pi-web` 功能面很大，计划要求先冻结可验证对标清单，不能把完整 Web 产品一次性倒入 MVP。
- 选项 A：首版复制会话、聊天、文件、Git、worktree、模型、插件、技能、通知和全部设置。
- 选项 B：冻结 P0 为连接配置、连接检查、会话列表/刷新、会话选择与消息读取、新会话工作目录、发送提示、SSE 增量反馈、停止运行、加载/空/错误/重连状态；其余列为已知差异。
- 推荐：选项 B；它覆盖“找到并继续对话、运行智能体”的核心闭环，且每个状态都能通过 Flutter 测试重复验证。
- 选择：选项 B
- 同意影响：文件浏览、Git diff/worktree 管理、模型/provider 配置、插件/技能管理、分支/导出/删除、富媒体预览和推送通知延期。
- 否决影响：选择 A 会显著扩大协议、平台权限与 UI 验证范围，无法形成小而完整的首版验收闭环。
- 完成判断：P0 清单全部有代码、聚焦测试和 macOS Debug 构建证据；延期项必须记录但不伪装为已实现。
- 兼容性：未来增加延期能力应保持当前连接配置和会话/消息模型的向后兼容，除非在 `0.x` 明确记录破坏性迁移。
- 标签：`decision/005-mvp-scope`
