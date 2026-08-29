---
mdq:
  version: 2
  dialect: gfm
  actors:
    read: mixed
    write: machine
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
    title:
      source: heading
      group: title
    status:
      source: label
      labels: [状态, Status]
    selected:
      source: label
      labels: [选择, Selected]
    review_level:
      source: label
      labels: [评审级别, Review level]
    raw:
      source: body
  queries:
    decision_by_id:
      when:
        pattern: '^DEC-[0-9]{3}$'
      match:
        source: key
        operator: eq
      select: [title, status, selected, review_level]
      expect:
        max_record_lines: 40
        max_record_bytes: 8192
        structured: true
        min_confidence: 1.0
  maintenance:
    query_contract:
      mode: locked
---
# 项目决策记录

默认评审级别：L6。目标要求“遇到问题采用推荐项、每次选择使用独立 Markdown 并打 Git 标签”为 L9。

## DEC-001 - 空仓库的治理与隔离开发起点

- 状态：Accepted
- 评审级别：L6
- 问题：仓库尚无提交且主工作树含项目技能配置，Git 无法从未出生分支创建隔离 worktree。
- 选项 A：直接在脏的主工作树实现全部 MVP。
- 选项 B：先提交现有项目技能锁和本决策作为治理基线，再创建临时隔离 worktree。
- 推荐：选项 B；它保留现有配置、建立可审计起点，并满足后续精确 HEAD 交付规则。
- 选择：选项 B
- 同意影响：主分支新增一个不含业务实现的初始治理提交；后续实现可在临时 worktree 完成并验证后合并。
- 否决影响：选择 A 会失去隔离交付和精确完成引用，不符合项目默认 `-w` Git 模式。
- 兼容性：无运行时或 API 兼容性影响。
- 标签：`decision/001-project-bootstrap`
