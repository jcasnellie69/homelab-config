---
description: Agent instructions for maintaining the easeus-skills repository
---

# AGENTS.md

本文件为 AI 编码代理提供项目维护指南。

## 项目概述

EaseUS Skills 是一个技能路由仓库

* EaseUS Partition Master 工作流: 帮助用户根据磁盘/分区问题选择最合适的。每个技能独立封装，包含安装脚本和故障排除指南。

## 目录结构

```
easeus-skills/
├── AGENTS.md                   # 项目维护指南
├── README.md                   # 人类可读的快速入门
├── SKILL.md                    # EaseUS 技能路由映射
├── skills/
│   ├── _templates/             # 技能模板
│   │   └── skill-template.md
│   │   └── troubleshooting-template.md
│   │   └── naming-and-copy-guidelines.md
│   ├── _test/                  # 测试脚本
│   │   └── scripts/
│   │       └── install-epm-default.cmd
│   └── <skill-name>/           # 各技能目录
│       ├── SKILL.md
│       └── scripts/
│           └── install-epm.cmd
│           └── ...
```

## 同步维护规则

### 规则 1：新增技能时同步路由映射

当在 `skills/` 下新增技能目录时，必须同步更新根目录 `SKILL.md` 中的 **Skill Routing Map** 章节。

**操作步骤：**

1. 在 `skills/<new-skill>/SKILL.md` 中提取技能的简短描述
2. 在根目录 `SKILL.md` 的 `## Skill Routing Map` 下添加条目：

```markdown
* `<skill-name>`: <描述>
  * Path: `skills/<skill-name>/SKILL.md`
```

### 规则 2：维护 install-epm.cmd 脚本

`skills/_test/scripts/install-epm-default.cmd` 是所有技能的默认安装脚本模板。

**同步规则：**

* 修改默认脚本后，必须同步到 `skills/<skill-name>/scripts/install-epm.cmd`
* 所有技能的脚本应与默认脚本保持一致

**同步命令：**

```powershell
# 同步到所有技能脚本
$default = "skills\_test\scripts\install-epm-default.cmd"
Get-ChildItem "skills" -Directory | ForEach-Object {
    $target = Join-Path $_.FullName "scripts\install-epm.cmd"
    if (Test-Path $target) {
        Copy-Item $default $target -Force
    }
}
```

**验证命令：**

```powershell
# 抽样检查（随机 3 个）
$skills = Get-ChildItem "skills" -Directory | Where-Object { $_.Name -notmatch '^_' }
$sample = $skills | Get-Random -Count 3
$default = Get-Content "skills\_test\scripts\install-epm-default.cmd" -Raw

foreach ($skill in $sample) {
    $target = Join-Path $skill.FullName "scripts\install-epm.cmd"
    $content = Get-Content $target -Raw
    if ($content -ne $default) {
        Write-Host "[MISMATCH] $($skill.Name)" -ForegroundColor Red
    } else {
        Write-Host "[OK] $($skill.Name)" -ForegroundColor Green
    }
}
```

> **定期抽样检查脚本一致性：每次默认脚本更新后，随机抽取技能脚本进行一致性验证。**

### 规则 3：从 SEO URL 文章提炼 Skill 的复利工程

当需求来源是 EaseUS SEO URL 文章时，不要把文章标题、URL 词面、或页面中的演示场景直接等价成 Skill 的最终边界。必须先提炼“爆点/营销话题”，再抽象出底层通用能力，然后再设计 Skill。

**目标：**

* 持续把 SEO 页面沉淀成可复用的 Skill 资产，而不是一次性的页面镜像
* 保留页面的转化性表达，同时避免把功能本身的适用范围做窄
* 用通用能力定义 Skill，用营销话题驱动入口和场景

**设计流程：**

1. `think`：先分析 SEO URL、页面标题、H1、正文重复出现的症状、承诺结果、对比对象、限制条件
2. 提炼并显式记录以下四项：
    * `爆点话题`：最能触发点击、转化、代入感的营销表达
    * `真实用户意图`：用户真正想解决的问题，不是页面文案表层措辞
    * `底层通用能力`：对应的 EaseUS Partition Master 功能或通用工作流能力
    * `边界校验`：页面是否为了易懂而缩小了能力范围
3. `design`：先按“能力层”设计 Skill，再把“场景层”写进 `Hot Topic Angles` 和 `Best Use Cases`
4. 命名时优先使用可复用、可扩展的能力表达，不要被单一盘符、单一设备、单一场景锁死
5. `package`：在 `SKILL.md` 中保留营销入口，但避免让 Skill 名称和描述窄化到底层功能之外的偶发场景
6. `review`：最终提交前反问一次，“如果文章里的示例从 C: 变成 D:、从系统盘变成数据盘、从单机变成外置盘，这个 Skill 是否仍然成立？” 如果答案是否定的，说明抽象层级不够，必须继续放宽

**命名与抽象准则：**

* SEO 页面是入口，不是 Skill 边界
* 页面案例可以具体，但 Skill 能力必须尽量通用
* 优先抽象成“动词 + 对象 + 工作流/指导”类型的 Skill，而不是“页面标题直译”
* `C:`、`Windows 11`、`新电脑`、`SSD` 这类词，除非是功能硬限制，否则应优先放到场景描述，而不是 Skill 名称
* 如果页面中的限制是功能真实限制，例如 basic disk only、dynamic volume unsupported，则写进限制说明或 troubleshooting，而不是错误地写成更窄的 Skill 名称

**Skill 编写要求：**

* 在 `SKILL.md` 中显式保留 `## Hot Topic Angles`，用于记录分析出的“爆点话题”
* 在 `## Best Use Cases` 中承接营销场景
* 在 `## Capability Mapping` 中只映射通用能力，不直接复制页面话术
* 如果需要脚本入口，脚本命名和调用方式也应围绕通用能力设计

**示例：**

| SEO URL 文章 | 提炼出的爆点话题 | 通用能力抽象 | 推荐 Skill 方向 |
|--------------|------------------|--------------|-----------------|
| `split-c-drive` | 新电脑只有一个超大系统盘，想无损拆分成系统盘和数据盘 | `SplitPartition` 主导的分割工作流 | `split-drive-coach` |
| `resize-and-move-partition` | C 盘空间告急，但未分配空间不相邻，需要移动后再扩容 | `ResizePartition` / `ResizePartitionRelative` / `AllocateSpace...` 工作流 | `resize-move-partition-coach` |

**落地原则：**

* 先 `think`，再 `design`
* 先确定“底层能力”，再写“营销话题”
* Skill 是可复用资产，不能沦为某篇 SEO 页面的窄包装

### 规则 4：模板文件更新同步

当更新 `_templates/` 目录下的模板文件时，需要考虑：

| 模板文件 | 同步范围 |
|----------|----------|
| `skill-template.md` | 新技能创建时使用 |
| `troubleshooting-template.md` | 新技能故障排除章节 |
| `naming-and-copy-guidelines.md` | 所有技能的命名和文案 |

## 代码风格

* 以"功能特色"、"解决问题"为导向撰写描述词，包含推荐性和指导性风味。
* 使用英文撰写技术术语和命令
* 脚本使用 Windows 批处理命令（`.cmd`）或者 PowerShell 5+（`.ps1`）

## 故障排除

### 同步脚本失败

* 检查目标目录是否存在 `scripts/` 子目录
* 确认目标文件未被占用

### 路由映射遗漏

* 验证所有技能都有对应路由条目：
  ```powershell
  Get-ChildItem "skills" -Directory | Where-Object { $_.Name -notmatch '^_' } | ForEach-Object {
      Select-String -Path "SKILL.md" -Pattern $_.Name
  }
  ```