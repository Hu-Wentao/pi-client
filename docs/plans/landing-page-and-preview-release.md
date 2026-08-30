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

默认评审级别：L6。用户确认的技术、发布和范围边界为 L9；从仓库事实推导的实现细节为 L6。

## PLAN-PI-003 - Landing Page 与 macOS Preview 发布

- Status: Partially implemented
- Review level: L9（目标与范围）/ L6（实现路径）
- Target: 提供中英文独立 Landing Page、精确 `v0.0.2` 下载入口和可审计的未签名 Universal macOS Preview 发布流程。

### 当前事实

- 当前 Flutter 产品只支持 macOS，版本目标为 `0.0.2+2`。
- 当前运行时仍通过 pi-web `0.8.11` HTTP/SSE 兼容桥接；它不是长期产品身份。
- `v0.0.1` 是不可变历史 annotated tag，不能移动到当前代码，也没有 Release 资产。
- 当前没有 Developer ID、Notarization 或 DMG 发布证据。
- WebAssembly Client 依赖尚未冻结的第一方 Pi SDK/transport、Friday Workspace 和浏览器安全边界，本计划不实现它。

### 已实现源码范围

1. `site/` 使用 Astro `7.2.9`、Bun `1.4.0` 和锁文件生成英文根路由及简体中文 `/zh-cn/` 路由。
2. 页面包含精确 `v0.0.2` Universal ZIP 下载 CTA、当前能力、过渡架构、安全边界、限制、canonical、`hreflang` 和 Open Graph 元数据。
3. 生产页面不使用客户端 hydration；构建验证拒绝业务 JavaScript、错误子路径资产和漂移的下载 URL。
4. 原创 SVG 是 App Icon、favicon 和社交分享图的单一品牌来源；确定性脚本生成 macOS PNG 尺寸和分享图。
5. 营销截图由 Flutter Widget 测试使用真实 Roboto 和 Material Icons 字体、合成路径、会话、提示和输出生成；测试拒绝真实用户路径、密码和 token 文本。
6. `unsigned-preview` 分发通道使用独立 `fr_storage_unsigned_preview` 目录和固定公开 32 字节密钥，不访问 Keychain；标准 Release 继续使用 `fr_storage` 和平台安全存储。
7. Release entitlement 为未来签名、沙箱化版本声明 outbound network client 能力，但不伪造 Apple Team 或 Keychain group。
8. Pages workflow 在 PR 和 main 上检查并构建站点，只在精确 Release 资产已发布时部署。
9. 手动 macOS workflow 从 main 构建、测试、生成未签名 Universal App、验证启动及架构、打包 ZIP/校验和、创建不可变 tag、发布 prerelease，并请求 Pages 部署。

### 尚未执行的外部操作

以下状态仍为 Planned，不能由源码或本地测试推断为完成：

1. 推送实现提交和后续决策标签。
2. 调度手动 Release workflow。
3. 创建并发布 annotated `v0.0.2` 和 GitHub prerelease。
4. 验证公开 ZIP 与 SHA-256 资产。
5. 启用并验证生产 GitHub Pages URL。
6. 在生产 URL 上完成 Safari、Chrome、键盘、VoiceOver、200% 缩放和 Lighthouse 人工验收。

### 发布准入

- Source commit 必须是已推送 `main` 的精确 HEAD。
- `pubspec.yaml`、Landing Page 和资产名称必须共同解析为 `0.0.2+2`、`v0.0.2` 和 `Pi-Client-0.0.2-macOS-universal.zip`。
- Tag 或 Release 已存在时必须失败，不能覆盖、移动或删除既有身份。
- Flutter format、generation、analysis、tests、Debug build、unsigned Preview Release build 和启动检查全部通过后才能创建 tag。
- App 内每个可执行 Mach-O 必须同时包含 `arm64` 和 `x86_64`。
- Bundle ID、版本、build number 和 macOS 11.0 最低版本必须匹配源码。
- Release 必须同时包含 ZIP 和 SHA-256；Draft 资产核对通过后才能公开。
- Pages 必须在公开 Release 的精确 ZIP 资产存在后部署。

### 回滚与后续

- 已发布 tag、Release 资产和版本不得覆盖；缺陷通过更高 patch 版本修复。
- Pages 可停止后续部署，但不能把旧下载 URL 指向不同字节。
- 未签名 Preview 偏好不迁移到未来签名版；用户可删除独立 Preview 数据而不影响标准目录。
- 签名、公证和 DMG 是后续独立目标，需要 Apple 开发者身份与发布授权。
- WebAssembly Client 继续由 `PLAN-PI-002` 及未来正式 Pi SDK/transport 决策约束，不进入本计划。

### 完成条件

本计划只有在 `VER-PI-013` 取得公开 Release、资产、Pages 和生产人工验收证据后才能改为 Completed。源码和工作流验证只满足 `VER-PI-012`，不能替代外部发布证据。
