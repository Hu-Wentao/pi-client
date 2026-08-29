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
      expect: {max_record_lines: 42, max_record_bytes: 8192, structured: true, min_confidence: 1.0}
  maintenance: {query_contract: {mode: locked}}
---
# 项目决策记录

默认评审级别：L6。

## DEC-011 - Freezed 生成文件的确定性空白

- 状态：Accepted
- 评审级别：L6
- 问题：全新 checkout 运行 Freezed 3 `build_runner` 时，会在 `workspace.freezed.dart` 的 `// dart format off` 区域生成一处尾随空格；手工删除后，冷生成会再次恢复并让工作树变脏。
- 选项 A：每次生成后用自定义脚本重写生成文件空白。
- 选项 B：提交生成器的原始确定性输出，并把该生成区域视为第三方生成件，不对它执行手工空白规范化。
- 推荐：选项 B；它避免建立项目自有的生成后修补链，并保证新 checkout 运行标准 `build_runner` 后工作树保持干净。
- 选择：选项 B
- 同意影响：该生成文件包含一处由 Freezed 产生的尾随空格；仓库卫生检查对生成文件使用“生成后无 diff”而不是通用尾随空格规则。
- 否决影响：选择 A 会新增必须维护、测试和文档化的生成后转换步骤，并可能掩盖生成器升级差异。
- 兼容性：无运行时、API 或数据兼容性影响。
- 标签：`decision/011-generated-output`
