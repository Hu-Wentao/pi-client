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

## DEC-007 - 脚手架与治理仓库的忽略规则冲突

- 状态：Accepted
- 评审级别：L6
- 问题：受控合并发现唯一同名文件 `.gitignore`；治理仓库忽略本地 `.agents/`，Flutter 脚手架忽略构建、IDE 和平台产物。
- 选项 A：保留任意一方并丢弃另一方规则。
- 选项 B：以 Flutter 脚手架规则为主体，追加 `.agents/`，不忽略 `skills-lock.json`、治理文档、FVM 固定文件或业务源码。
- 推荐：选项 B；两组规则职责互补，合并后既不提交本地技能副本，也不污染仓库构建产物。
- 选择：选项 B
- 同意影响：`.gitignore` 成为两组既有规则的最小并集，其他脚手架文件继续无覆盖合并。
- 否决影响：选择 A 会提交本地缓存/技能源码，或让 Flutter 构建产物进入版本控制。
- 兼容性：无运行时影响。
- 标签：`decision/007-gitignore-merge`
