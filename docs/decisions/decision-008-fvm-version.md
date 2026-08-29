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

## DEC-008 - 固定 Flutter 工具链版本

- 状态：Accepted
- 评审级别：L6
- 问题：ACDD 脚手架通过全局 FVM 的 Flutter `3.41.6` 完成验证，但没有自动生成项目级版本固定文件。
- 选项 A：继续使用会漂移的全局 `stable`。
- 选项 B：执行 `fvm use 3.41.6`，提交 `.fvmrc`，并以该精确版本作为 MVP 构建基线。
- 推荐：选项 B；它把已经通过脚手架分析、测试和 macOS Debug 构建的工具链固定为可复现输入。
- 选择：选项 B
- 同意影响：开发者首次运行需让 FVM 准备 Flutter `3.41.6`；升级必须形成新的显式决策和验证。
- 否决影响：选择 A 会让 Dart SDK、生成器和平台构建结果随 `stable` 漂移。
- 兼容性：工具链固定，不改变应用运行时协议。
- 标签：`decision/008-fvm-version`
