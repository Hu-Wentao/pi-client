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
      expect: {max_record_lines: 60, max_record_bytes: 12288, structured: true, min_confidence: 1.0}
  maintenance:
    query_contract: {mode: locked}
---
# 项目决策记录

默认评审级别：L6。用户明确批准的 1.0 与 1.1 产品范围为 L9。

## DEC-022 - 1.0 外部终端入口与 1.1 远程 Shell 范围

- 状态：Accepted
- 评审级别：L9
- 问题：如何在保留完整 Pi Client 产品路线的同时，降低 `1.0` 内置终端、远程 Shell 和任意 Extension TUI 的跨平台与安全成本。
- 选项 A：`1.0` 继续实现内置命令执行、PTY、远程 Shell、移动/Web Shell 和任意 Extension TUI。
- 选项 B：`1.0` 完全删除所有终端相关入口，并且不建立后续版本责任。
- 选项 C：`1.0` 的 CLI 范围只保留“将当前已验证且不需要信任审批的桌面项目在外部终端打开”；`1.1` 以安全的项目级远程 Shell 为重点功能，并承接命令、PTY、移动/Web 远程控制、Windows Shell 设置和任意 Extension 终端桥接。
- 推荐：选项 C；它保留桌面开发者进入 Pi CLI 的最小路径，并把高权限远程执行集中到一个独立版本完成协议、安全和平台验收。
- 选择：选项 C
- `1.0` 范围：macOS、Windows 和 Linux 只把 Pi Node 已验证的 `PiProjectIdentity` canonical cwd 交给系统外部终端；不得自动执行 `pi`、复制或生成命令、接受任意命令/参数/环境、捕获输出、提供 stdin、PTY、内置命令执行或远程 Shell。
- 安全边界：入口只对当前选中且 `trusted` 或 `notRequired` 的项目可见；启动使用结构化进程参数而不是 Shell 插值、URL scheme 或 `sh -c`；失败反馈不得暴露未显示路径、进程错误或环境内容。
- 平台边界：Android、iOS 和 Web 不显示入口并返回 unsupported；connect-only 产物不得包含 Shell host、PTY host 或远程命令执行实现。
- `1.1` 范围：`REQ-PI-019` 保留身份、Must 优先级和 Planned 状态，但目标改为 `1.1` 的项目级命令、PTY 与远程 Shell；`PLAN-PI-008` 是该版本唯一实施计划，`PLAN-PI-004` 不以它作为 `1.0.0` 发布门禁。
- Extension 边界：标准 Select、Confirm、Input、Editor、Notify、Status、Widget、Title 和 Editor Text 继续属于 `1.0`；任意自定义终端 UI 与 Windows Shell 设置移到 `1.1`。
- 渲染兼容：历史或 Agent 产生的 Shell、ANSI、Process 和 Tool 内容仍由 `REQ-PI-020` 的只读富消息渲染器展示；本决策不授权删除这些卡片或把渲染误认为 Shell 执行能力。
- 需求关系：新增 `REQ-PI-038` 作为 `1.0` 外部终端结果；`REQ-PI-026` 不再以 Windows Shell 设置作为 `1.0` 验收；`REQ-PI-029` 在 `1.0` 只拥有标准原生 Extension 交互。
- 与既有决策的关系：保留 `DEC-014` 的桌面宿主与 connect-only 平台角色、`DEC-020` 的项目自有产品权威和 `DEC-021` 的产物边界；本决策只收窄尚未发布的 `1.0` Shell/TUI 范围。
- 兼容性：这是尚未发布 `1.0` 产品范围的 Breaking narrowing；不改变现有 Pi Protocol wire、Pi Node runtime、历史 Release、会话数据或富消息渲染兼容性。
