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

默认评审级别：L6。运行时身份、发布不可变性和签名边界为 L9。

## DEC-021 - 在第一方运行时边界下采用跨平台发布工具

- 状态：Accepted
- 评审级别：L9
- 问题：如何把 `main@b33a3cb` 的六平台 CI、聚合产物、Pages、Homebrew 和发布治理工具并入已经实现第一方 Pi Node、项目自有 Protocol 与 Runtime Capsule 的 `1.0` 集成线，而不恢复旧运行时、伪造公开版本或错误记录桌面产物不含 Host runtime。
- 选项 A：完整保留 `main` 的 `0.0.3+3`、`six-platform-preview-v1`、`hostRuntimeIncluded: false` 和 transitional Preview 文案。
- 选项 B：拒绝全部 `main` 发布工具，只保留功能分支已有的单平台与桌面候选流程。
- 选项 C：保留 `DEC-016` 的原生 runner、聚合 manifest/checksum、精确 Tag/Draft 恢复和 Pages 身份门禁；将活动身份改为未发布 `0.1.0+3`、`independent-six-platform-development-v1`，让桌面 artifact 必须包含已验证第一方 Runtime Capsule，移动/Web 保持 connect-only，并在新的发布决策前禁用 publication 与 Homebrew 生成。
- 推荐：选项 C；它保留可复用治理能力，同时让产物事实与当前独立架构一致。
- 选择：选项 C
- 同意影响：`pubspec.yaml` 使用未发布开发版本 `0.1.0+3`；活动 Release Profile 为 publication-disabled；聚合资格流程可生成候选 evidence，但当前不能创建 `v0.1.0`、GitHub Release、下载 CTA 或 Homebrew Cask。`v0.0.2` 与任何已存在的 `v0.0.3` 身份均只能只读验证，不能移动、覆盖或复用。
- 产物边界：macOS、Windows 和 Linux 聚合候选必须记录 `hostRuntimeIncluded: true`，并先通过平台 Capsule verifier、安装布局、manifest、启动或 E2E 门禁；Android、iOS、Web JavaScript 和 WebAssembly 必须记录 `false` 并通过 connect-only 扫描。
- 签名边界：活动聚合 Profile 只属于 development candidate。稳定 Windows/Linux 候选在缺少 Authenticode/GPG 凭据时失败；macOS ad-hoc 资格不等于 Developer ID 或 Notarization；任何 stable Release 仍需要新的发布授权与完整签名门禁。
- Homebrew 边界：保留确定性 Cask 工具和测试，但只有 publication-enabled、已公开、精确 Tag/commit/asset/SHA-256 证据和 Universal macOS 资产同时存在时才允许生成。当前产品页、README 和贡献指南不显示未发布 Homebrew 或下载入口。
- 与既有决策的关系：保留 `DEC-016` 的工具和不可变发布治理，取代其“当前桌面 artifact 不含 Host runtime”和 `six-platform-preview-v1` 活动身份；保留 `DEC-017` 的独立产品站边界；将 `DEC-018` 的即时 `v0.0.3`/Homebrew 发布路径归档为未执行历史授权；`DEC-019` 与 `DEC-020` 的历史快照及项目自有产品权威保持不变。
- 计划关系：跨平台资格与发布工具由 `PLAN-PI-007` 维护；Homebrew 后续入口由 `PLAN-PI-006` 维护；完整产品和 `1.0.0` 继续由 `PLAN-PI-004` 负责。
- 兼容性：从 `0.0.3+3` transitional Preview 草案切换到未发布 `0.1.0+3` 第一方开发身份，属于未发布发布合同 Breaking correction；不改变已发布 Tag、Release 或远端字节。
