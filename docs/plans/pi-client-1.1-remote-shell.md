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
      expect: {max_record_lines: 220, max_record_bytes: 32768, structured: true, min_confidence: 1.0}
    plans_by_status:
      match: {source: field, field: status, operator: eq}
      select: [title, review_level, target]
      expect: {max_total_bytes: 131072, structured: true, min_confidence: 1.0}
  maintenance: {query_contract: {mode: locked}}
---
# Pi Client 1.1 实施计划

默认评审级别：L3。用户批准的版本重点、项目级授权和 connect-only 远程结果为 L9。

## PLAN-PI-008 - 1.1 远程 Shell 重点版本

- Status: Planned
- Review level: L9（产品结果与安全边界）/ L3（实现路径）
- Target: 在 `1.0.0` 稳定交付之后，以安全的项目级远程 Shell 作为 `1.1` 的重点功能，为桌面、移动端和 Web 提供一致的命令与 PTY 用户结果。

### 权威与版本关系

- `REQ-PI-019` 拥有远程 Shell 的产品语义和验收；本计划只拥有 `1.1` 实施顺序。
- `DEC-022` 明确 `1.0` 只提供外部终端入口；本计划不得把内置命令、PTY、远程 Shell、移动/Web Shell 或任意 Extension TUI 重新加入 `PLAN-PI-004` 的 `1.0.0` 门禁。
- `PLAN-PI-002` 继续拥有 Friday Workspace、身份、Grant、Tunnel 和 E2EE；本计划通过其已接受边界传输 Shell 帧，但不替代 friday-relay 的跨项目权威。
- 历史 Shell、ANSI、Process 和 Tool 消息渲染继续由 `REQ-PI-020` 负责，不构成本计划的执行证据。

### 目标结果

- 在当前受信项目和 allowed roots 内启动有界非交互命令或交互式 PTY。
- 流式显示 stdout/stderr、退出状态、信号、截断状态和可授权的完整输出。
- 支持输入、终端 resize、取消、超时、进程树终止和显式会话关闭。
- 支持桌面 Local Direct，以及经授权、加密的 Friday Transport；Android、iOS 和 Web 只远程连接，不获得本地 Shell host。
- 支持 Windows Shell 配置和任意 Extension 自定义终端交互，但两者必须复用同一授权、流控、取消和陈旧响应边界。

### 非目标

- 任意 TCP、URL、文件或 Shell proxy。
- 在 Flutter 中保存 Provider 凭据、环境秘密、完整命令历史或可重用 Access Grant。
- 绕过 Project Trust、allowed roots、Node pairing、Grant scope、E2EE 或命令确认。
- 让移动/Web 产物包含 Node runtime、Shell host、PTY host、宿主文件系统或本地进程实现。
- 通过 `sh -c`、字符串拼接或未声明的环境注入替代结构化执行合同。

### 实施路径

1. 冻结 Protocol 1.x 的 additive Shell capability、command/PTY/stream identity、accepted/rejected/uncertain admission、sequence、resume cursor、window/backpressure、cancel、timeout 和 terminal resize 语义。
2. 在 Pi Node 建立 Project Trust 与 allowed-root 后的 Shell coordinator；命令、cwd、环境 allowlist、Shell profile、资源限制和进程树由宿主独占拥有。
3. 建立非交互命令执行与 PTY 两个明确模式；标准输出、错误输出和 terminal frame 不互相伪装。
4. 为 macOS/Linux 使用受支持 PTY，为 Windows 使用受支持 ConPTY/终端宿主；平台差异通过同一领域结果表达。
5. 为 Flutter 增加远程 Shell 页面、队列、输入、resize、断线恢复、只读降级和明确的 writer lease。
6. 让 Friday Access Grant 绑定 Workspace、Node、project、Shell scope、client key、连接代次和短 TTL；Relay 只转发 E2EE 帧。
7. 将任意 Extension 自定义终端 UI 映射到同一有界 terminal stream，并保留标准原生 Extension dialogs 的独立 `1.0` 路径。
8. 对 Local Direct 与 Friday Transport 运行同一 conformance fixture，并证明移动/Web 只有远程控制面。

### 安全和恢复门禁

- 未信任项目、错误 Node、未授权 cwd、路径逃逸、符号链接逃逸、过期/重放 Grant、未知 stream 和超限 frame 必须失败关闭。
- 命令、参数、环境、stdout/stderr、terminal frame 和错误不得进入 Relay 日志、诊断、Crash report、公开截图或发布证据。
- 同一 Shell/PTY 只有一个 writer；断线、刷新、设备切换和 Session replacement 不得恢复陈旧输入权。
- Abort 必须终止完整进程树；不确定终止状态必须显示为 uncertain，而不是成功。
- Resume 只能从仍在保留窗口内的权威 cursor 恢复；缺口必须显式刷新或转只读。

### 验证范围

- Protocol 跨 Dart/TypeScript vectors、unknown fields、版本兼容、fuzz、limits、backpressure、cancel、resume 和 E2EE tamper。
- Pi Node 的 trust、cwd、symlink、环境 allowlist、资源限制、进程树、PTY、ConPTY、crash/restart 和 redaction。
- Flutter 的输入法、键盘、焦点、200% 缩放、stream 性能、队列、stale generation、只读状态和无障碍语义。
- macOS、Windows、Linux 本地宿主；Android、iOS、Web 远程连接；Local Direct 与 Friday Transport 一致性。
- connect-only artifact scan 证明不存在本地 Shell/PTY host 或进程执行实现。

### 退出条件

- `VER-PI-030` 对 `REQ-PI-019` 的每项验收给出自动或人工证据，并且没有已知安全缺口。
- Local Direct 和 Friday Transport 在相同领域 fixture 下得到一致结果；Friday Relay 不能读取明文 Shell 数据。
- macOS、Windows、Linux 的命令和 PTY 原生运行证据通过；Android、iOS、Web 的远程结果与本地 host 缺失证据通过。
- Windows Shell 设置和任意 Extension 终端 UI 不能绕过核心 Shell coordinator。
- `1.1` 发布使用同一 major 的 additive compatibility；任何不兼容 Protocol 或持久状态变化必须遵循正式 SemVer 和迁移治理。

### 当前状态

- `1.0` 外部终端入口不执行命令、不拥有 PTY、不捕获输出，也不建立 Shell wire capability。
- 当前 Protocol、Pi Node 和 Flutter 不因该入口增加 Shell request、event、stream 或 artifact。
- 本计划保持 Planned；只有 `1.0.0` 交付和独立的 `1.1` 实施授权后才进入 runtime 实现。
