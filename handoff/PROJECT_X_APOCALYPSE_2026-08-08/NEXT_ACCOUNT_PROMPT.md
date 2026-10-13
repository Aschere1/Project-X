# 可直接发给下一个账号的提示词

```text
请接手本机项目：
D:\Project X\Project X_Migration_2026-08-03

先完整阅读：
1. handoff/PROJECT_X_APOCALYPSE_2026-08-08/README.md
2. handoff/PROJECT_X_APOCALYPSE_2026-08-08/STATUS.md
3. handoff/PROJECT_X_APOCALYPSE_2026-08-08/VERIFICATION.md
4. 根目录 README.md、AGENTS.md
5. docs/APOCALYPSE_VERTICAL_SLICE.md

当前默认产品是末日生存原型，不是牧场游戏。末日家园采用静态地图热点，没有头像移动、WASD、碰撞箱或 E 键靠近互动。旧牧场代码和测试只作为历史/可复用模块保留，不要删除，也不要把它重新接成默认流程。

已经完成的最小闭环是：第 1 日从家园进入县域地图和村卫生室，搜索后选择战利品，返回家园存储/发电/医疗/制作，通过主屋休息推进到第 4 日，按公开的电力/急救包/武器准备结算首轮袭击，并自动保存恢复。

开始修改前先运行：
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test_project.ps1

基线应为 TESTS_PASSED assertions=895。Windows 根证书库读取失败是当前不阻塞警告，但任何 TESTS_FAILED 或脚本错误都不能忽略。

你的第一项任务：先在真实 Godot 窗口完成人工视觉验收，检查左上目标板、主屋休息面板、底部真实状态栏、第 4 日结算文字是否遮挡或溢出。只修视觉问题，不改变首袭数值。之后再规划新游戏/继续游戏入口。

继续保持 UI 紧凑：480×256 内容，8–10 px 字体；不要重新做巨大菜单、巨大 Tooltip 或亮黄色热点。普通用品最多叠加 16，武器不叠加，家园仓储按格数不计负重。B=背包，Esc/P=菜单，S=保存。

每次只做一个可验证小目标；修改前说明原因、文件和结果；修改后运行全量测试。不要把无头节点测试描述成人工视觉验收，也不要声称完整 7 日内容已经完成。
```
