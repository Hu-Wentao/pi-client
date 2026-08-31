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

默认评审级别：L6。平台角色、运行时身份与发布不可变性为 L9。

## PLAN-PI-007 - 第一方六平台资格与发布工具

- Status: Active
- Review level: L9
- Target: 在不发布当前开发身份的前提下，把六平台原生 CI、候选聚合、manifest/checksum、精确 Tag/Draft 恢复、Pages 身份门禁和 Homebrew 工具适配到第一方 Pi Node、项目自有 Protocol 与 Runtime Capsule。

### 当前事实

- 当前活动应用版本是未发布 `0.1.0+3`；Node 与 Protocol 为私有 `0.2.0-dev.0`。
- 活动 Profile 是 `independent-six-platform-development-v1`，且 `publicationEnabled: false`；资格流程可以产生 Actions evidence，但不能创建 Tag、Release、下载入口或 Cask。
- macOS、Windows 和 Linux 是 Agent-host-capable，候选包必须包含并验证第一方 Runtime Capsule；Android、iOS、Web JavaScript 和 WebAssembly 是 connect-only，必须拒绝 Host runtime。
- `v0.0.2` 是不可变历史。`0.0.3+3`、`v0.0.3` 和 transitional Profile 不属于当前候选身份，也不能由本计划创建或覆盖。

### 实施路径

1. 使用共享 composite Action 固定 Dart/FVM/Flutter，并关闭冲突的 Dart problem matcher；CI 同时运行 Flutter、Protocol、Pi Node、Release 工具、Astro 与六平台构建。普通 Flutter 测试排除平台敏感 Golden，桌面 Golden 只在 macOS runner 执行。
2. Android、iOS、Web JS/WASM 在产物根执行 connect-only 扫描；普通桌面 Debug 构建保持不隐式下载 Capsule。
3. 聚合 development workflow 在目标原生 runner 构建 Release 形态；桌面先构建 Capsule，再安装进 App/Bundle，运行平台 verifier 与 bundled-app E2E，最后 stage 标准资产。
4. 每个 stage evidence 记录真实 `hostRuntimeIncluded` 与验证方法；聚合 manifest 固定完整 commit、版本、Flutter、平台、架构、角色、签名、runtime baseline、大小与 SHA-256。Windows 候选同时验证 `ProductName` 和 Flutter 实际写入的 `ProductVersion=<version>+<build>`。
5. `qualify` 可以上传同一 commit 的短期 Actions bundle。`publish` 必须先通过 `--require-publication`；当前活动 Profile 必然在任何远端 mutation 前失败。
6. 将来启用 publication 时，继续使用 `DEC-016` 的 annotated Tag、精确 commit、原 qualification run、Draft readback、同名字节不覆盖、单个 failed starter 有界修复和 publish-last 机制。
7. Pages 的 main push 只部署 source-only 产品站；Release dispatch 必须绑定 annotated Tag/commit，并仅在 publication-enabled Profile 的精确公开资产集合存在时部署。
8. Homebrew 工具不读取移动 ref 或占位 checksum；必须显式提供公开 Tag、commit、asset、SHA-256 和 Universal macOS 资格证据。
9. `.gitattributes` 固定版本、Release contract、站点版本内容和 Release Notes 为 LF，防止 Windows checkout 改写严格字节合同。

### 历史 main 交付事实

- `main` 的 transitional `v0.0.3` 曾完成六平台 Preview 资格、公开 Prerelease、Pages admission 和 unsigned Homebrew 安装；精确证据保留在 `VER-PI-027` 与 `VER-PI-028`。
- 这些事实只描述不含第一方桌面 Runtime Capsule 的历史 lineage，不激活当前 `0.1.0+3` Profile，不满足 `VER-PI-024`，也不授权 Tag、Release、Tap 或部署 mutation。

### 退出条件

- `VER-PI-023` 证明本地 Release 合同、工具、workflow policy、Astro 和适用构建门禁。
- `VER-PI-024` 只有在新的发布授权和 publication-enabled Profile 下取得原生 runner 聚合、公开 Release、下载回读与 Pages evidence 后才能 PASS。
- 本计划不创建 `v0.1.0`、`v0.0.3`、GitHub Release、Tap commit 或部署；这些都是独立的当前授权边界。
