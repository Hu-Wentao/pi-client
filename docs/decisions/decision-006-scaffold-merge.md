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

## DEC-006 - 非空治理仓库的 Flutter 脚手架落位

- 状态：Accepted
- 评审级别：L6
- 问题：ACDD 新项目脚本拒绝写入已有治理文档的非空仓库根目录。
- 选项 A：删除治理文件后直接在根目录运行脚手架。
- 选项 B：在同级临时空目录运行官方 ACDD 脚手架并完成其全部验证，再把生成结果无覆盖地合并到任务 worktree，保留治理文件，随后删除临时目录。
- 选项 C：绕过脚本手工执行 `flutter create` 和依赖安装。
- 推荐：选项 B；它同时保留治理历史并继续让 ACDD 脚本负责项目创建、依赖、生成和初始验证。
- 选择：选项 B
- 同意影响：需要一次受控文件合并和合并后复验；若路径冲突必须停止而不是覆盖。
- 否决影响：选择 A 会破坏已接受的治理基线；选择 C 不符合 fr-mvvm-contract 的新项目工作流。
- 兼容性：无产品运行时影响。
- 标签：`decision/006-scaffold-merge`
