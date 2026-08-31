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

## DEC-018 - 未签名 macOS Preview 的 Homebrew 分发

- 状态：Accepted
- 评审级别：L9
- 问题：在项目当前没有付费 Apple Developer 账号、Developer ID 和 Notarization 能力时，如何让 macOS 用户通过一条 Homebrew 命令安装 Pi Client，同时不篡改归档 `v0.0.2`、不绕过 Gatekeeper，也不把 Preview 描述成受信任正式分发。
- 选项 A：等待 Developer ID 和 Notarization 后再提供 Homebrew。
- 选项 B：建立 `Hu-Wentao/homebrew-tap`，为高于 `v0.0.2` 的新 unsigned Preview 提供 Cask；Homebrew 保留 quarantine，首次启动由用户在 Finder 中 Control-click 后选择 Open。
- 选项 C：让安装命令使用 `--no-quarantine`、删除扩展属性或关闭 Gatekeeper，以获得无提示首次启动。
- 推荐：选项 B；它达成一行安装目标，复用现有不可变 GitHub Release 与 SHA-256 边界，并明确保留 macOS 的用户确认和 Preview 风险披露。
- 选择：选项 B
- 同意影响：当前版本切换为 `0.0.3+3` 和 `six-platform-preview-v1`；发布新的 annotated `v0.0.3` GitHub Prerelease；macOS Universal ZIP 成为 `pi-client` Cask 的唯一应用资产；用户命令为 `brew install --cask hu-wentao/tap/pi-client`；README、Release Notes 和 Cask caveats 必须披露 unsigned、未公证、Gatekeeper 首次启动步骤、当前 transitional pi-web 兼容边界以及未交付的第一方 Host runtime。
- 否决影响：选项 A 无法立即满足一行 Homebrew 安装；选项 C 会主动削弱 macOS 安全边界，项目不得实现或推荐。
- Tap 边界：应用仓库拥有版本、Release 资产和确定性 Cask 生成/验证契约；独立公开仓库 `Hu-Wentao/homebrew-tap` 只保存生成后的 `Casks/pi-client.rb`。Cask 必须固定 exact version、GitHub Release URL 和小写 SHA-256，不得指向移动分支、Actions 临时 Artifact 或归档 `v0.0.2`。
- 产品站边界：`DEC-017` 继续有效；Landing Page 不渲染 Preview 下载、Homebrew 命令、平台安装步骤或 legacy runtime 名称。Homebrew 安装入口由 README、GitHub Release 和 Tap 拥有。
- 发布边界：用户已授权本次实现、`v0.0.3` unsigned Preview 发布、公开 Tap 创建与推送，以及真实 Homebrew 安装验收；该授权不包含 Apple 签名、Notarization、商店上传、Gatekeeper 绕过、修改既有 Tag/Release 字节或后续版本发布。
- 标签：`decision/018-unsigned-homebrew-preview`。
