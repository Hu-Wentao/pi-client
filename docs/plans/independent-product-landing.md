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

默认评审级别：L6。产品身份、平台角色与公开能力边界为 L9。

## PLAN-PI-005 - 独立产品 Landing Page

- Status: Completed
- Review level: L9（产品身份与公开能力）/ L6（静态站点实现）
- Target: 在 `https://pi.wyattcoder.top/` 和 `/zh-cn/` 提供不依赖或宣传遗留适配器、归档 Preview 和未交付运行时的独立跨平台产品页。

### 当前事实

- GitHub Pages 已使用 `pi.wyattcoder.top` 自定义域名、有效 TLS 证书和强制 HTTPS；本计划不修改 DNS 或域名所有权。
- `main` 包含 Android、iOS、macOS、Windows、Linux 和 Web 工程，以及经过测试的桌面 Host-capable、移动端/Web connect-only 平台角色契约。
- 第一方运行时与完整 transport 尚未作为当前公开产品交付；其他开发分支的实现不能由站点声明为 `main` 已交付能力。
- `v0.0.2` Tag、Release、资产、校验和与历史部署证据必须保持不可变，但用户已确认它们不再构成当前产品站的主入口。

### 实施路径

1. 保留 Astro、Bun、中英文路由、规范域名、既有品牌色、响应式布局和零客户端 JavaScript。
2. Hero 只说明独立开放源代码 Flutter Client、一套代码与六个平台目标，CTA 指向 GitHub 和贡献指南。
3. 产品基础区只展示一套 Flutter 代码、六个平台工程、经过验证的平台角色和开放开发过程。
4. 平台角色区分别说明 macOS/Windows/Linux 的 Host-capable 契约与 Android/iOS/Web 的 connect-only 边界，并明确 Host runtime 尚未作为当前公开产品交付。
5. 当前状态区区分已经存在的工程、契约和自动化，与仍在开发的运行时和 transport。
6. 删除旧 Workspace 截图、安装步骤、下载 CTA、签名警告、遗留运行时文案和旧平台限定；使用品牌与平台角色 CSS 视觉替代截图。
7. 保留 `site/src/content/copy.ts` 中供 Release contract 使用的历史元数据块，但页面不导入或渲染它；构建验证从相同契约解析历史下载 URL 并拒绝其出现在 HTML 中。
8. 更新 README、贡献指南、产品站 Requirement、Baseline、Decision 和 Verification；历史 Release 与 Pages 证据继续保留在原记录中。

### 验证

- `bun run brand` 从项目品牌 SVG 生成 favicon、macOS App Icon 和新的跨平台 social card，不再生成或交付 Workspace 截图。
- Astro check/build/validate 必须覆盖双语 canonical、hreflang、六个平台、GitHub 链接、独立产品身份、开发状态、资源与零客户端 JavaScript。
- 构建验证必须拒绝遗留适配器名称、归档下载 URL、归档版本、旧截图和 `/pi-client/` 路径。
- Release contract、Preview artifact 和 workflow policy Node tests 必须继续通过，证明历史发布自动化未被改写。
- 受治理 Markdown 必须通过 mdq 内容、结构或合同检查。

### 外部部署

- 验证后的源提交 `a5b153503798d24590b764f96c81e8a0d15391bc` 已由受治理 worktree 流程合并为 `main` 提交 `e2110c0c03c03d9b4de8c7bfc62c303de00a375b` 并非强制推送到 `origin/main`。
- Pages run `33365568081` 绑定精确 `headSha=e2110c0c03c03d9b4de8c7bfc62c303de00a375b`，source、build、Release 资产准入和 deploy Jobs 全部成功。
- GitHub Pages readback 保持 `cname=pi.wyattcoder.top`、已验证域名、已批准证书和 `https_enforced=true`。
- 生产检查确认 HTTP `301` 到 HTTPS；英文 `/`、中文 `/zh-cn/`、产品标识和 social card 返回 `200`；退役的 `workspace-preview.webp` 返回 `404`。双语 HTML 包含六平台、独立产品身份、平台角色和开发状态，不包含遗留运行时、归档版本、历史下载、旧截图或 `/pi-client/` 资源路径。
- 本计划未创建 Release Tag、修改 Release 资产、发布新版本、改变 DNS 或合并 Pi Node 开发分支。

### 完成条件

`VER-PI-016` 已取得本地源码 PASS；Pages run `33365568081` 已部署精确 `main` 提交并通过生产正向与负向内容检查。生产页面返回 `200`、使用 `pi.wyattcoder.top` canonical、包含六平台独立产品定位，并排除遗留运行时、归档下载和旧截图，因此本计划已完成。
