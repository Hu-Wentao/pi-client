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

默认评审级别：L6。

## DEC-015 - 独立 Landing Page 与未签名 macOS 预览发布

- 状态：Accepted
- 评审级别：L9
- 问题：开源仓库如何提供独立产品入口和首个可下载的 macOS 产物，同时不把尚未交付的 WebAssembly 或长期 Pi transport 描述成当前能力。
- 选项 A：仅维护 README，不建立独立网站或可下载产物。
- 选项 B：使用 Flutter Web 同时承担营销页和未来产品客户端，并等待签名、公证及 DMG 后再发布。
- 选项 C：同仓库维护 Astro 中英文静态 Landing Page，通过 GitHub Pages 部署；发布未签名 Universal macOS APP ZIP 作为次级 Preview，并显著披露 Gatekeeper、签名和存储隔离边界。
- 推荐：选项 C；它建立面向使用者的产品入口和真实下载路径，同时把营销站点、当前 macOS Preview 与未来 WebAssembly Client 保持为不同职责。
- 选择：选项 C
- 同意影响：固定 Astro `7.2.9`、Bun `1.4.0`、英文根路由和 `/zh-cn/`；`v0.0.2` 下载 URL 指向 `Pi-Client-0.0.2-macOS-universal.zip`；APP 名称为 `Pi Client`；未签名 Preview 使用独立目录和公开固定密钥，未来签名版继续使用 Keychain；GitHub Pages 只有在精确 Release 资产存在后才部署。
- 否决影响：选项 A 无法满足独立 Landing Page 和 Release 下载目标；选项 B 会把营销页与产品运行时混合，并在当前没有 WebAssembly transport、浏览器安全边界和签名资产时扩大范围。
- 当前兼容边界：pi-web `0.8.11` 只作为 `0.0.2` 早期 Preview 的过渡兼容桥接；长期产品使用第一方、版本化的 Pi SDK/transport 路径；本决策不撤销 `DEC-012` 的长期独立实现目标，也不授权 WebAssembly 实现。
- 安全与兼容性：未签名 ZIP 不具备 Developer ID、Notarization 或有效 Gatekeeper 信任；公开固定密钥不提供保密性；Preview 偏好不自动迁移到未来签名版；密码仍不得持久化。
- 发布边界：当前用户已授权在全部门禁通过后推送实现、创建 `decision/015-landing-page-and-preview-release`、发布不可变 `v0.0.2` GitHub prerelease，并部署 GitHub Pages；任何后续版本仍需要新的当前授权。
- 标签：`decision/015-landing-page-and-preview-release`。
