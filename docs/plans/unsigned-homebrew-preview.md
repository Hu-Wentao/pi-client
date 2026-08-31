---
mdq:
  version: 2
  dialect: gfm
  actors: {read: mixed, write: machine}
  records:
    boundary:
      source: heading
      levels: [2]
      pattern: '^(?P<id>PLAN-PI-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$'
    key:
      source: heading
      pattern: '^(?P<id>PLAN-PI-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$'
      group: id
  fields:
    title: {source: heading, group: title}
    status: {source: label, labels: [Status, 状态]}
    review_level: {source: label, labels: [Review level, 评审级别]}
    target: {source: label, labels: [Target, 目标]}
    raw: {source: body}
  queries:
    plan_by_id:
      when: {pattern: '^PLAN-PI-[0-9]{3}$'}
      match: {source: key, operator: eq}
      select: [title, status, review_level, target]
      expect: {max_record_lines: 180, max_record_bytes: 32768, structured: true, min_confidence: 1.0}
    plans_by_status:
      match: {source: field, field: status, operator: eq}
      select: [title, review_level, target]
      expect: {max_total_bytes: 65536, structured: true, min_confidence: 1.0}
  maintenance: {query_contract: {mode: locked}}
---
# Pi Client 实施计划

默认评审级别：L6。macOS 安全披露和发布身份边界为 L9。

## PLAN-PI-006 - 未签名 macOS Preview 的 Homebrew 一行安装

- Status: In progress
- Review level: L9
- Target: 通过 `brew install --cask hu-wentao/tap/pi-client` 安装不可变 GitHub Prerelease 中的 Universal `Pi Client.app`，同时保留 quarantine、Gatekeeper 用户确认和全部 unsigned Preview 披露。

### 执行路径

1. 把当前 Release 身份切换为 `0.0.3+3`、`v0.0.3` 和 `six-platform-preview-v1`，保留 `v0.0.2` Tag、Release、资产和 checksum 不变。
2. 在应用仓库增加确定性的 Cask 生成与验证工具。输入只允许当前 Release contract 和 macOS ZIP 的 exact lowercase SHA-256；输出固定为 `Casks/pi-client.rb`。
3. Cask 固定 GitHub Release URL、版本、checksum、macOS 11 下限和 `Pi Client.app`；caveats 披露 unsigned、未公证、Finder 首次 Open、transitional pi-web 边界和未交付的第一方 Host runtime。
4. 共享 CI 和 Preview workflow 运行 Cask 工具测试；禁止 `--no-quarantine`、`xattr`、Gatekeeper disable 或把 ad-hoc 签名描述为 Developer ID。
5. 从同一 main commit 运行现有六平台 `publish` workflow，完成聚合 bundle、annotated Tag、GitHub Prerelease、资产回读和 Pages admission。
6. 从公开 macOS ZIP 计算 SHA-256，生成 Cask；创建并推送 `Hu-Wentao/homebrew-tap`，运行 Homebrew style、记录 official-new-cask audit 对 unsigned/prerelease 的预期拒绝，并完成真实安装、版本、Bundle ID、架构、Gatekeeper rejection 与卸载边界验证。
7. 把 Release run、Tag/commit、资产 digest、Tap commit 和 Homebrew 验收结果写入 `VER-PI-015` 与 `VER-PI-017`。

### 失败边界

- 新 Release 尚未公开或资产 digest 未冻结时，不发布带占位 checksum 的 Cask。
- Release workflow 失败后只恢复同一 qualification run、Tag、commit 和 bundle；不移动 Tag、不覆盖资产。
- Tap 发布失败不修改已经公开的 Release；修复 Cask 后仍绑定同一 Release 字节。
- Gatekeeper 接受不是本计划的成功条件。没有 Developer ID 时，验收必须证明安装成功且普通首次启动仍被 Gatekeeper 拒绝，并保留 Finder 用户确认路径。

### 完成条件

`v0.0.3` GitHub Prerelease 的 exact macOS ZIP 已公开；`Hu-Wentao/homebrew-tap` 的 Cask 固定相同版本和 SHA-256；一条 brew 命令把应用安装到 `/Applications`；Cask 不移除 quarantine；首次启动风险与 transitional runtime 边界被准确披露；安装、检查和卸载证据记录为 PASS。
