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
      expect: {max_record_lines: 70, max_record_bytes: 14336, structured: true, min_confidence: 1.0}
  maintenance:
    query_contract: {mode: locked}
---
# 项目决策记录

默认评审级别：L6。公开发布、第三方 Tap 写入和远程部署为 L9。

## DEC-023 - 发布第一方 Pi Client Homebrew Preview

- 状态：Accepted
- 评审级别：L9
- 问题：如何让当前第一方 `0.1.0+3` 架构通过稳定 Homebrew 命令提供 macOS Preview，同时让后续 Preview 发布自动同步 Tap，而不把未验证产物描述为正式稳定版。
- 选项 A：继续保持 source-only 页面和 dormant Homebrew，不提供当前架构的安装入口。
- 选项 B：直接复用历史 `v0.0.3` transitional Preview 的 Cask 和下载资产。
- 选项 C：建立新的 publication-enabled first-party Preview Profile，使用带 Runtime Capsule 的 Universal macOS 产物，发布不可变 GitHub Preview Release，并在公开资产回读后自动更新同一个 Homebrew Cask。
- 推荐：选项 C；它让安装命令保持稳定，同时把版本、资产、commit 和 checksum 绑定到每次已公开验证的 Release。
- 选择：选项 C
- 发布身份：当前 `0.1.0+3` 使用 `v0.1.0` Tag；`0.1.0` 是应用版本，`3` 是 build number。Homebrew Cask 使用 `0.1.0`，不把 Flutter build metadata 写入 Cask version。
- macOS 边界：公开 Preview 必须是 Universal arm64/x86_64，包含第一方 Pi Node Runtime Capsule，采用 ad-hoc 签名且明确未公证；Homebrew 保留 quarantine，任何 Gatekeeper 绕过都禁止。
- 平台边界：Android、iOS、Web JavaScript 和 WebAssembly 继续保持 connect-only；Windows 和 Linux Preview 资产可以公开，但不得把 unsigned Preview 描述为稳定分发。
- 自动同步：发布 workflow 只接受精确 annotated Tag、peeled commit、公开 Release、资产和真实 SHA-256；随后使用专用 `HOMEBREW_TAP_TOKEN` 更新 `Hu-Wentao/homebrew-tap/Casks/pi-client.rb`，并在 macOS runner 上执行干净安装、版本、Universal 架构和 Runtime Capsule 验证。
- 页面边界：Homebrew 命令只在 release-bound Pages 构建中显示；普通 main 构建保持 source-only。页面不硬编码版本，后续 Release 只更新 Tap 的 Cask version、URL 和 checksum。
- 兼容性：本决策 supersede `DEC-021` 中“当前 Profile publication-disabled、Landing Page 不显示 Homebrew”的当前发布边界，但保留其项目自有运行时、精确身份、不可变资产、connect-only 和 Gatekeeper 安全原则；历史 `v0.0.2` 与 `v0.0.3` 字节保持不变。
