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

## DEC-002 - MVP 目标平台与应用标识

- 状态：Accepted
- 评审级别：L6
- 问题：计划未冻结首要平台、最低版本和 Bundle ID。
- 选项 A：仅 macOS，最低 macOS 11.0，应用标识 `io.github.huwentao.pi_client`。
- 选项 B：采用脚手架默认 Android+iOS。
- 选项 C：首版同时启用全部 Flutter 平台。
- 推荐：选项 A；`pi-web` 的本机 pi 数据、工作目录和 localhost 服务模型天然适合桌面端，且 ACDD 脚手架对 macOS 11 有完整验证路径。
- 选择：选项 A
- 同意影响：MVP 可在单一桌面环境完成构建、启动和本机服务联调；其他平台不在本次验收范围。
- 否决影响：选择 B 或 C 会引入移动端网络、沙箱、文件系统或多平台构建问题，降低首版可验证性。
- 版本：项目从 `0.0.1` 起步，`0.x` 兼容面保持不稳定。
- 兼容性：新增配置面；没有既有客户端兼容承诺。
- 标签：`decision/002-target-platform`
