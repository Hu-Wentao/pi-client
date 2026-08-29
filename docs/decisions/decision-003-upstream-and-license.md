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

## DEC-003 - pi-web 对标版本与许可证边界

- 状态：Accepted
- 评审级别：L6
- 问题：计划要求冻结上游 revision、许可证和可复用素材边界。
- 选项 A：跟随 `main` 浮动并直接复制实现与品牌素材。
- 选项 B：固定 `agegr/pi-web` commit `28bab3c25f5f6770c9b0b745ebbfec1c27f7b948`（package `0.8.11`），仅复刻可观察行为与协议，自主实现 Flutter UI，项目采用 MIT。
- 推荐：选项 B；固定 revision 可重复审计，MIT 允许参考与再实现，但避免复制品牌和截图可减少归属混淆。
- 选择：选项 B
- 同意影响：README 和对标清单必须注明上游、commit 与 MIT；不把 `Pi Web` 名称、截图或图标作为本项目自有素材。
- 否决影响：选择 A 会让验收基线漂移，并增加许可证通知与品牌混淆风险。
- 素材边界：仅保留必要的事实性链接和许可证归属；本项目 UI、测试和文档为独立实现。
- 兼容性：上游后续变化不会自动进入本 MVP。
- 标签：`decision/003-upstream-license`
