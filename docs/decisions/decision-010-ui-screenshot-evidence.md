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
      expect: {max_record_lines: 40, max_record_bytes: 8192, structured: true, min_confidence: 1.0}
  maintenance: {query_contract: {mode: locked}}
---
# 项目决策记录

默认评审级别：L6。

## DEC-010 - UI 截图验证证据

- 状态：Accepted
- 评审级别：L6
- 问题：macOS Debug `.app` 已启动并出现进程，但当前宿主拒绝 `screencapture`，无法创建系统显示截图。
- 选项 A：等待用户授予宿主 Screen Recording 权限后再继续。
- 选项 B：使用 Flutter Widget 渲染管线在固定 1200 × 800 视口生成并版本化 Golden PNG，同时保留真实 `.app` 进程和构建证据。
- 推荐：选项 B；它无需外部权限，且 Golden 可在测试中重复生成和比对，比一次性桌面截图更适合回归验证。
- 选择：选项 B
- 同意影响：首帧视觉证据由 `test/goldens/` 和 Golden 测试所有；系统标题栏不在 PNG 内，但原生窗口尺寸由 Swift 与 macOS 构建验证。
- 否决影响：选择 A 会让完整目标依赖当前无法自行授予的宿主权限。
- 兼容性：仅改变验证载体，不改变 UI 或运行时行为。
- 标签：`decision/010-ui-screenshot-evidence`
