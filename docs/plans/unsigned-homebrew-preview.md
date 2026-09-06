---
mdq:
  version: 2
  dialect: gfm
  actors: {read: mixed, write: machine}
  records:
    boundary: {source: heading, levels: [2], pattern: '^(?P<id>PLAN-PI-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$'}
    key: {source: heading, pattern: '^(?P<id>PLAN-PI-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$', group: id}
  fields:
    title: {source: heading, group: title}
    status: {source: label, labels: [Status, 状态]}
    review_level: {source: label, labels: [Review level, 评审级别]}
    raw: {source: body}
  queries:
    plan_by_id:
      when: {pattern: '^PLAN-PI-[0-9]{3}$'}
      match: {source: key, operator: eq}
      select: [title, status, review_level]
      expect: {max_total_bytes: 65536, structured: true, min_confidence: 1.0}
  maintenance: {query_contract: {mode: locked}}
---
# Pi Client 实施计划

默认评审级别：L6。公开发布与第三方 Tap 写入为 L9。

## PLAN-PI-006 - Homebrew 发布入口

- Status: Active
- Review level: L9
- Target: 通过稳定 Homebrew 命令交付带第一方 Runtime Capsule 的公开 macOS Preview，并在每次后续 Preview Release 后同步同一个 Tap Cask。

### 当前边界

- `DEC-023` 授权 `independent-first-party-preview-v1` publication-enabled Profile；当前 `0.1.0+3` 使用 `v0.1.0`，但仍是 ad-hoc/未公证 Preview，不是稳定版。
- Homebrew Cask 必须只指向已经公开、不可变、Universal、包含第一方 Host runtime 的精确 macOS 资产；`tool/homebrew_cask.mjs` 和 `tool/homebrew_tap.mjs` 共同拒绝错误证据。
- Homebrew 不是 macOS 签名、公证或 Gatekeeper 信任的替代物。Homebrew 保留 quarantine，发布说明和 Landing Page 必须说明首次启动行为，不得使用 `--no-quarantine` 或 `xattr` 绕过。
- 历史 `v0.0.3` transitional Cask 和 Tap 提交由 `VER-PI-028` 保留，不得复用或覆盖；当前 Preview 使用新的 first-party 资产身份。

### 实施路径

1. 从精确 commit 运行六平台 Preview qualification，验证 macOS Universal Runtime Capsule、manifest、checksum、启动和平台角色。
2. 由 publish workflow 创建不可变 annotated Tag 和公开 GitHub Preview Release，并在发布后读取公开资产重新计算 SHA-256。
3. 使用专用 `HOMEBREW_TAP_TOKEN` 更新 `Hu-Wentao/homebrew-tap/Casks/pi-client.rb`，执行远端文件回读；只更新 Cask，不移动 Tag 或覆盖 Release 资产。
4. 在干净 macOS runner 执行 `brew install --cask hu-wentao/tap/pi-client`，验证版本、Universal 架构、Runtime Capsule、quarantine、Gatekeeper 拒绝行为和卸载。
5. 仅在 Homebrew 更新和安装 smoke 通过后触发 release-bound Pages；普通 main 页面保持 source-only，页面命令不硬编码版本。

### 验证

- `test/homebrew_cask_test.mjs`、`test/homebrew_tap_test.mjs`、`test/release_contract_test.mjs` 和 `test/workflow_policy_test.mjs` 验证 Profile、Cask 证据、Tap 更新幂等性和工作流门禁。
- `VER-PI-026` 在公开 `v0.1.0` Release、Tap 回读和干净 Homebrew 安装证据完成前保持 PLANNED；历史 `v0.0.3` evidence 不得将其提升为 PASS。
