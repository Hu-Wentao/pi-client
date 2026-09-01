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

- Status: Deferred
- Review level: L9
- Target: 保留可验证、确定性的 Homebrew Cask 生成能力，但在当前未发布 `0.1.0+3` 开发身份下保持 dormant。

### 当前边界

- `DEC-018` 曾授权的即时 `v0.0.3` unsigned Preview 路径已由 `DEC-021` 取代，本计划不得创建或复用该 Tag、Release、asset 或 Tap 提交。
- 当前 Profile `independent-six-platform-development-v1` 明确 `publicationEnabled: false`；`tool/homebrew_cask.mjs` 必须先拒绝生成，README、Landing Page 与 Release Notes 不显示安装命令。
- Homebrew 不是 macOS 签名、公证、Gatekeeper 信任或 first-party Runtime Capsule 完整性的替代物。
- `main` lineage 的 transitional `v0.0.3` 与 Tap commit `7ec1023866376f83ddda6164b77cd1e2e673cdc4` 已完成过 unsigned Homebrew 安装和卸载；该事实由 `VER-PI-028` 历史化保留，不代表当前独立构建可通过 Homebrew 获得。

### 恢复条件

1. 新的项目决策明确授权一个 publication-enabled Release Profile、精确稳定版本和公开发布动作。
2. macOS 资产为 Profile 声明的 Universal first-party Host runtime 产物，并已通过 Capsule、签名、架构、启动、manifest 和 checksum 门禁。
3. 输入证据显式绑定 annotated Tag、peeled commit、公开 GitHub Release、精确 asset 名和真实 SHA-256；不允许 placeholder、移动 ref、缺失 asset 或不同字节复用。
4. Cask 使用 stable archive URL 与精确 checksum，不使用 `--no-quarantine`、`xattr` 或其他 Gatekeeper 绕过。
5. Tap 更新必须在独立授权的治理流程中提交和回读；本仓库普通 qualification 不直接写第三方仓库。

### 验证

- `test/homebrew_cask_test.mjs` 证明当前 Profile 失败关闭，并用合成的未来 publication-enabled metadata 验证 Cask 渲染与证据拒绝路径。
- `VER-PI-026` 在新的 first-party Runtime Capsule 公开资产和独立 Tap 安装 evidence 完成前保持 PLANNED；历史 `v0.0.3` evidence 不得将其提升为 PASS。
