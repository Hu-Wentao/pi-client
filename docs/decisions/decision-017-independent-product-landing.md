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
      expect: {max_record_lines: 60, max_record_bytes: 12288, structured: true, min_confidence: 1.0}
  maintenance:
    query_contract: {mode: locked}
---
# 项目决策记录

默认评审级别：L6。

## DEC-017 - 独立产品 Landing Page

- 状态：Accepted
- 评审级别：L9
- 问题：当前产品站是否继续把已归档 Preview 的运行时、截图、安装步骤和下载入口作为 Pi Client 的当前产品身份。
- 选项 A：保留现有站点，仅修正域名和少量措辞。
- 选项 B：使用只含品牌与 GitHub 链接的临时占位页。
- 选项 C：保留中英文静态站点与既有视觉系统，重写为独立跨平台产品页；只展示六平台工程、平台角色契约和开放开发状态，撤下归档 Preview 下载与遗留运行时内容。
- 推荐：选项 C；它满足用户“本项目与 pi-web 没有关系”的产品身份确认，同时避免把尚未合入或尚未发布的第一方运行时描述为已交付。
- 选择：选项 C
- 同意影响：规范域名继续为 `https://pi.wyattcoder.top/`；页面不渲染旧下载、旧 Workspace 截图、旧安装说明或遗留适配器名称；主 CTA 改为 GitHub 和贡献指南；桌面 Host-capable 与 Android/iOS/Web connect-only 仅按已验证契约描述，并显著说明 Host runtime 尚未作为当前公开产品交付。
- 否决影响：选项 A 继续把历史实现错误地提升为当前产品身份；选项 B 虽然安全，但无法说明已经验证的六平台与执行角色事实。
- 与历史决策的关系：本决策取代 `DEC-015` 对“当前产品站内容和主 CTA”的约束，但不撤销或改写 `v0.0.2` Tag、GitHub Release、资产、校验和、历史部署与验收证据。历史发布元数据可继续供自动化校验，但不得由当前产品页渲染。
- 范围边界：本决策不修改 Flutter 运行时，不合并任何 Pi Node 开发分支，不把 Local Direct、Friday Workspace、Agent Host 或其他未交付能力宣传为当前功能，也不改变 Pages 的现有 Release 资产准入逻辑。
- 兼容性：撤下当前产品页上的归档 Preview 下载入口属于用户可见 Breaking Change；历史 Release URL 和字节保持不变。
- 发布边界：用户已授权本次站点实现、提交、合并、推送 `main` 和 `pi.wyattcoder.top` Pages 部署验证；该授权不包含创建或移动 Release Tag、修改 Release 资产、发布新版本或改变 DNS。
