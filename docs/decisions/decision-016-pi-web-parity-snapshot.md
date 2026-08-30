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

默认评审级别：L6。用户明确指定的功能完整性目标与独立实现边界为 L9。

## DEC-016 - 冻结 pi-web 可见功能完整性快照

- 状态：Accepted
- 评审级别：L9
- 问题：如何把“Pi Client 拥有当前 pi-web 的所有功能”转为可完成、可验收且不破坏 `DEC-012` 独立实现边界的 `1.0.0` 范围。
- 选项 A：持续跟随 pi-web `main`，并把其实现、协议和隐藏能力都视为 Pi Client 需求。
- 选项 B：固定版本，但直接以 pi-web 的路由、类型、事件、数据结构和测试作为 Pi Client 契约。
- 选项 C：固定 pi-web `v0.8.11`、commit `28bab3c25f5f6770c9b0b745ebbfec1c27f7b948`；仅将该快照中用户可见且可到达的产品能力作为完整性基线，由 Pi Client 自有 requirements 定义语义、平台适配和验收。
- 推荐：选项 C；它把当前用户指令转换为稳定的 completeness baseline，同时保留项目自身的产品、架构、安全和兼容性权威。
- 选择：选项 C
- 同意影响：`docs/benchmark.md` 必须完整分类可见能力、Native-adapted 项和排除项；`docs/requirements.md` 是实现与验收的语义权威；外部快照变化不自动扩大 `1.0.0` 范围。
- 排除边界：不可到达的隐藏 UI、仅内部 route/schema/event/type、测试专用能力、实现缺陷、构建与部署机制不属于严格对等。`v0.8.11` 的 built-in subagent 创建运行时被硬关闭，且普通 Settings 未挂载 Agents 配置，因此严格对等只包含已有 child/subagent session 的识别、状态和打开。
- 独立实现边界：不得导入、复制、调用、部署或要求安装 pi-web runtime、源码、组件、路由、schema、event、protocol 或 artifact；Pi Node 只集成经过评审的第一方 Pi SDK/Runtime 边界。
- 与既有决策的关系：保留并强化 `DEC-012`；不改变 `DEC-013` 的 Friday Workspace owner、`DEC-014` 的六平台执行角色或 `DEC-015` 的历史 Preview 发布边界。
- 计划关系：`PLAN-PI-004` 拥有 P0-P11 至 `1.0.0` 的实施顺序；`PLAN-PI-002` 作为 Friday Workspace 并行轨道；`PLAN-PI-001` 继续保持 Superseded，不因本决策复活。
- 兼容性：从 `v0.0.2` pi-web Gateway 迁移到第一方 Pi Node 会移除 URL/Basic Auth 历史配置，属于后续 `0.x` Breaking Change；历史 tag、Release 和验证记录保持不可变。
