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

## DEC-016 - 六平台 CI 与聚合 Preview Release

- 状态：Accepted（发布身份和 Host runtime inclusion 由 `DEC-021` 更新）
- 评审级别：L6
- 问题：如何把现有安全边界较强但仅覆盖 macOS 的 Preview workflow 扩展到 Android、iOS、macOS、Windows、Linux 和 Web，同时不篡改既有 `v0.0.2`、不伪造签名能力，也不把尚未实现的 Pi SDK Agent Host 打入任何产物。
- 选项 A：继续只维护 macOS workflow，其他平台仅保留手动构建命令。
- 选项 B：照搬 FlClash 的 `v*` Tag 触发、单 workflow、下游渠道和打包脚本。
- 选项 C：保留当前 main 准入、精确 commit、SHA-pinned Action、annotated Tag、Draft/readback 和 Pages gate；新增原生 runner 六平台 CI、版本化 Artifact Profile、统一产物契约、聚合 manifest/checksum，以及手动 `qualify`/`publish` Preview workflow。
- 推荐：选项 C；它复用 FlClash 已验证的原生 runner、统一命名和 Artifact 聚合思想，但保留 Pi Client 更严格的身份与发布校验，并独立实现而不复制 GPL-3.0 代码。
- 选择：选项 C
- 当时同意影响：`pubspec.yaml` 继续是版本和 build number 权威；`release/release.json` 只选择 Artifact Profile 和主资产；`macos-preview-v1` 只能匹配 `0.0.2+2`，后续候选必须使用更高且相对远端稳定 Tag 单调递增的版本；普通 CI 在对应宿主构建六平台；聚合资格统一生成应用产物、stage evidence、`artifact-manifest.json`、`SHA256SUMS` 和主资产单文件校验和。活动 Profile 与 Runtime inclusion 已由 `DEC-021` 更新。
- 否决影响：选项 A 不能补齐 Windows/Linux runner 证据或形成可审计的跨平台交付；选项 B 会引入宽泛 Tag 准入、浮动依赖、Release 后修改主线、签名披露不足和许可证风险。
- 当时平台边界：Android、iOS 和 Web 的 manifest 角色必须是 `remote-client-only`；macOS、Windows 和 Linux 是 `agent-host-capable`。本决策最初要求所有产物记录 `hostRuntimeIncluded: false`，因为当时 Host 尚未交付；`DEC-021` 已在第一方 Runtime Capsule 实现后将桌面候选改为 `true`，并保留移动/Web 的 `false` 与 connect-only 扫描。
- 签名边界：本阶段只产生明确披露的 Preview 产物。Android Release 不得回退到 Debug 签名；iOS 只提供 no-codesign archive；macOS 和 Windows 不得声称 Developer ID、Notarization 或 Authenticode；缺少正式签名身份时不能把 Preview 提升为正式分发。
- 发布边界：落地 workflow、脚本、测试和文档不等于授权发布下一版本。`publish` 对明确不存在的身份创建 annotated Tag 和 Draft；对已存在且指向同一 commit 的 annotated Tag、Draft 或公开 Release，必须提供原资格运行的 `resume_run_id` 并复用其精确聚合 bundle，只执行受限 starter 资产修复、缺失资产补齐或只读复核，绝不移动 Tag、覆盖已上传字节或修改已公开资产。Pages 从该 annotated Tag 调度并再次证明 Tag peel 等于冻结 commit。运行 `publish`、创建新 `v*` Tag、推送决策 Tag、上传商店或修改下游渠道仍需要对应的当前授权。
- 标签：`decision/016-six-platform-ci-and-preview-release`。
- 后续决策：`DEC-021` 采用本决策的原生 runner、聚合和不可变恢复机制，并更新活动版本、Profile、WASM 与桌面 Host runtime inclusion。
