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
  maintenance: {query_contract: {mode: locked}}
---
# 项目决策记录

默认评审级别：L6。用户明确指定的全平台范围与平台执行角色为 L9。

## DEC-014 - 全平台客户端与 Agent 宿主执行角色

- 状态：Accepted
- 评审级别：L9
- 问题：`DEC-002` 仅冻结 macOS MVP，当前产品需要明确六个平台的客户端范围以及哪些平台可以承载 Pi SDK 和 Agent。
- 选项 A：同一 Flutter 工程覆盖 Android、iOS、macOS、Windows、Linux 和 Web；macOS、Windows、Linux 为 Agent 宿主能力平台，Android、iOS、Web 为仅连接宿主的客户端。
- 选项 B：六个平台均为仅连接宿主的客户端，Agent 宿主始终是独立产品。
- 选项 C：六个平台均可嵌入 Pi SDK 并执行 Agent。
- 推荐：选项 A；桌面平台具备进程、文件系统和开发工具边界，移动端与 Web 保持最小远程客户端权限。
- 选择：选项 A
- 同意影响：所有平台共享 UI 与 Pi transport 合同；只有桌面平台可以出现 Pi SDK 初始化、宿主生命周期、工具执行和宿主文件系统能力。
- 否决影响：选择 B 会割裂桌面一体化宿主目标；选择 C 会把 Agent 执行和宿主权限错误扩展到移动端与 Web。
- 与历史决策的关系：本决策替代 `DEC-002` 的未来目标平台范围；`DEC-002` 继续作为已交付 macOS MVP 的历史决策和验证依据。
- 实施边界：本次只建立六平台工程和可测试的平台能力合同，不实现真实 Pi SDK、Agent 宿主生命周期或远程 Tunnel。
- 应用标识：Android 使用 `io.github.huwentao.pi_client`；iOS 和 macOS 使用现有 `io.github.huwentao.piClient`；可见应用名为 `Pi Client`。
- 兼容性：平台范围是加法性变更，不移除现有 macOS MVP 行为；未来移除遗留 `PiWebGateway` 仍按独立 `0.x` Breaking Change 治理。
