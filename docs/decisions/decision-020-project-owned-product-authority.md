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

默认评审级别：L6。用户明确指定的产品独立性、范围权威和历史边界为 L9。

## DEC-020 - 项目自有产品权威

- 状态：Accepted
- 评审级别：L9
- 问题：初始探索材料仍被当前文案和治理当作完整性、兼容性或运行时关系，如何恢复 Pi Client 的独立产品权威。
- 选项 A：继续让外部对照资料定义 `1.0.0` 功能完整性，只移除用户可见名称。
- 选项 B：仅修改 README、站点和贡献指南，不调整活跃 baseline、requirements、verification 和 plan。
- 选项 C：当前产品范围只由项目自有 requirements 与验收证据定义；初始探索和旧版兼容记录归档为历史；负向产物扫描继续证明外部 artifact 不会进入当前交付。
- 推荐：选项 C；它同时消除当前产品关系、保留历史真实性，并维持可验证的无外部依赖边界。
- 选择：选项 C
- 同意影响：当前产品面、活跃治理、架构、协议、实现、兼容性、运行时、构建、部署和发布不再从初始探索资料获得任何权威；`BASE-PI-008`、release-scoped Must requirements 与对应 verification 共同定义 `1.0.0` 完整性。
- 历史边界：旧版发布说明、已接受历史决策和归档探索清单保留当时事实，但不得作为当前需求、验收、兼容目标或安装入口。
- 安全边界：产物 denylist、manifest 拒绝规则和公开素材负向测试继续保留；它们只证明禁止外部 artifact 和品牌进入当前产物，不建立产品关系。
- 与既有决策的关系：本决策取代 `DEC-019` 的当前 completeness/parity 权威；`DEC-019` 的固定历史事实和排除边界继续归档。`DEC-012` 的独立实现负面边界保持兼容，但不定义当前产品范围。
- 计划关系：`PLAN-PI-004` 只以项目自有 requirements、baseline 和 verification 为当前输入；`PLAN-PI-001` 与 `PLAN-PI-003` 继续作为历史记录，`PLAN-PI-002` 只拥有 Friday Workspace 轨道。
- 发布边界：当前 Landing Page 只展示源代码和开发状态，不提供历史 Preview 或未发布版本的下载 CTA；未来下载入口必须绑定已授权、公开且验证通过的精确产物。
- 兼容性：这是治理和文档级 Breaking correction，不改变当前第一方 runtime/API 行为，也不重写已发布 tag、Release 或历史证据。
