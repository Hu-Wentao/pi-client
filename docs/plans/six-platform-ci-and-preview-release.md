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

默认评审级别：L6。既有六平台和执行角色约束保持 L9；用户接受的 Release 实现路径为 L6。

## PLAN-PI-004 - 六平台 CI 与可审计 Preview Release

- Status: Completed
- Review level: L9（平台与角色边界）/ L6（发布实现路径）
- Target: 建立 Android、iOS、macOS、Windows、Linux 和 Web 的原生 runner CI，以及从同一 commit 聚合、校验并按需发布 Preview 产物的可审计流程。

### 当前事实

- 当前公开 `v0.0.2` 是不可变的 macOS-only unsigned Preview；不能补传新平台字节或移动 Tag 来把它改写成六平台版本。
- 源码已经包含六个平台工程和 `PlatformCapabilities` 角色契约，但 Windows/Linux 尚缺 GitHub-hosted runner 运行证据。
- 当前没有 Android Release Keystore、Apple Distribution/Developer ID、Notarization、Windows Authenticode、商店身份或发布授权。
- 当前没有真实 Pi SDK Agent Host；所有 Preview manifest 必须记录 `hostRuntimeIncluded: false`。
- Web 继续使用 JavaScript build；`flutter_secure_storage_web 1.2.1` 仍阻断 Dart WebAssembly。

### 已接受实施路径

1. `pubspec.yaml` 是版本与 build number 唯一权威；Release contract 校验 `.fvmrc`、Artifact Profile、站点文案、Release Notes 和资产名称的一致性。
2. `macos-preview-v1` 只允许当前 `0.0.2+2`；未来版本必须显式切换 `six-platform-preview-v1`、高于 `0.0.2` 并高于其他远端稳定 Tag，不能对旧 Release 追溯扩容。
3. PR、main push 和手动 CI 先运行 generation、format、analysis、Flutter tests、Node release tests 和 Astro checks，再在对应原生 runner 构建六平台 Debug 门禁。
4. 手动 Preview workflow 分为 `qualify` 与 `publish`。二者都从精确 `GITHUB_SHA` 构建六平台 Release Preview；只有 `publish` 在 main、身份未占用且全部回读校验通过后创建 annotated Tag 和 Prerelease。
5. 每个平台 Job 只上传独立命名空间中的标准化 Actions Artifact 和 stage evidence；聚合 Job 校验六个来源目录及平台归属，拒绝缺失、多余、错源、重名或零字节文件，并生成确定性的 manifest 与 checksum。
6. 正式签名、原生安装器、商店上传、F-Droid、真实 Pi SDK Host 和 WASM 均为后续独立目标；unsigned macOS Homebrew Cask 由 `PLAN-PI-006` 独立约束。

### Preview 产物契约

| 平台 | 架构 | 产物 | 角色 | 分发边界 |
| --- | --- | --- | --- | --- |
| Android | armeabi-v7a、arm64-v8a、x86_64 | unsigned Release APK | remote-client-only | 需要使用者或下游重新签名，不伪装为正式可安装包 |
| iOS | arm64 | no-codesign `.xcarchive.zip` | remote-client-only | 不是 IPA，必须由 Apple 身份重新签名 |
| macOS | arm64 + x86_64 | Universal App ZIP | agent-host-capable | unsigned、未公证，保留 Gatekeeper 和启动检查 |
| Windows | amd64 | Portable ZIP | agent-host-capable | 无 Authenticode，不提供安装器 |
| Linux | amd64 | bundle `.tar.gz` | agent-host-capable | 无包签名，不提供 DEB/RPM/AppImage；运行时需要兼容的桌面库和 libsecret |
| Web | JavaScript | static site ZIP | remote-client-only | 需要可信静态托管和目标 Host 的 HTTPS/CORS 配置 |

所有平台的 manifest 均为 `hostRuntimeIncluded: false`，并携带保留宿主运行时名称的递归包文件边界扫描 evidence。macOS/iOS Framework 内只指向包内目标的标准符号链接可保留；逃逸、损坏或以保留 Host 名称出现的路径会失败。该扫描不证明任意二进制内容，平台角色也不表示当前产物已经包含 Agent Host。

### 发布准入

- 所有外部 GitHub Actions 必须固定到完整 commit SHA；workflow 使用最小权限和非取消式 Release concurrency。
- `publish` 只允许已推送 main 的精确 commit。远端身份可以不存在，或是同一候选 annotated Tag 指向同一 commit 的可恢复 Draft/公开 Release；恢复必须提供原 qualification 运行的正整数 `resume_run_id`，并证明该运行属于同一 workflow、仓库和 commit，且仍保留唯一、未过期、非零的聚合 bundle。轻量 Tag、错误 commit、重复 Release、未知 API 状态和版本倒退全部失败。
- Tag 创建前必须完成共享质量门禁、六平台构建、平台身份/架构/签名边界检查、Artifact 聚合和本地 digest 验证。
- Tag 必须是指向 `GITHUB_SHA` 的 annotated Tag；已创建的 Tag 不得移动、覆盖或删除。
- Release 先保持 Draft；重试时复用 Draft 和原 qualification bundle，已存在同名 uploaded 资产必须与本地字节一致，只补传缺失资产且不覆盖。GitHub 上传失败留下的单个 `starter/0-byte` 资产可在 Draft 身份、名称、状态和 Release 未变化时受限删除后重传；公开 Release、非零或 uploaded 资产永不删除。服务端资产集合、数量、状态、大小和重新下载后的 SHA-256 全部匹配本地 manifest 后才能公开；外部并发公开会失败，已公开 Release 只复核并允许重试 Pages。
- Pages 只在当前 Artifact Profile 所要求的精确公开资产集合存在时部署，并从 annotated Release Tag 调度，证明本地 Tag、远端 Tag 和 GitHub Tag Object 都 peel 到 qualification 冻结的 full commit，而不是重新解析可能前移的 main。

### 分阶段状态

1. **源代码自动化**：实现 Release contract、打包/聚合工具、Node tests、六平台 CI、Preview workflow、Pages profile gate 和 Android fail-closed Release signing。
2. **本地资格验证**：在 macOS 宿主运行 Node、Flutter、Astro、actionlint，以及 Android/iOS/macOS/Web 可用构建。
3. **远端 CI 证据**：合并并在 GitHub-hosted runner 完成六平台 CI，补齐 Windows/Linux 和原生 runner 证据。
4. **下一版本资格运行**：以 `0.0.3+3`、Release Notes、非渲染站点 Release 元数据和 `six-platform-preview-v1` 运行资格检查，检查聚合 bundle。
5. **发布与分发**：按当前授权运行 `publish`；unsigned macOS Homebrew Cask 由 `PLAN-PI-006` 绑定公开资产，正式签名、商店和原生安装器继续使用独立计划。

### 兼容与回滚

- 当前 `v0.0.2`、公开 ZIP、checksum、Landing Page CTA 和生产 Pages 不因新自动化改变。
- 移除 Android Release 的 Debug signing fallback 会使未配置 Keystore 的本地 Release 产物保持 unsigned；日常开发继续使用 Debug，正式可安装 APK 必须显式配置签名。这是开发/打包行为收紧，不改变应用运行时协议。
- Workflow 失败时保留同一 commit 的聚合 Actions Artifact 和 run ID；若 Tag 已创建而 Draft、上传、公开或 Pages 失败，使用 `resume_run_id` 重跑会验证同一 annotated Tag/commit 并下载原 bundle，复用匹配 Draft、受限清理单个失败 starter、补齐缺失资产或只重试 Pages。任何不同字节、过期/空 bundle、非 starter 零字节或错误身份都保持 fail-closed；只有不兼容缺陷才准备更高版本。
- 新 workflow 可回退为只运行 `qualify`，但不能绕过 Artifact Profile、签名披露、manifest 或 checksum 门禁。

### 完成条件

源代码阶段在 `VER-PI-014` 通过后完成。整个计划只有在 `VER-PI-015` 取得 GitHub-hosted 六平台构建、聚合 bundle、Preview 发布回读和 Pages 准入证据后才能改为 Completed；workflow YAML 存在或本地单宿主构建不能替代该证据。
