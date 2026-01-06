# puzzle-game

一款专为 HarmonyOS 打造的 ArkUI 拼图游戏组件库，让开发者能够快速在应用中集成有趣的拼图游戏功能。无论是用于休闲娱乐、儿童教育还是用户互动场景，puzzle-game 都能提供开箱即用的解决方案。

## 为什么选择 puzzle-game？

- 🚀 **零配置快速集成** - 只需几行代码即可在应用中添加完整的拼图游戏
- 🎯 **专为 HarmonyOS 优化** - 原生 ArkUI 组件，完美适配鸿蒙生态
- 🔧 **高度可定制** - 从主题颜色到难度级别，一切皆可配置
- � **轻量无交依赖** - 纯 ArkTS 实现，无第三方依赖

## 功能特性

### 🎮 游戏玩法
- 支持 3x3、4x4、5x5 等多种网格大小，满足不同难度需求
- 智能打乱算法，确保每局游戏都可解
- 实时显示拼图进度，绿框/红框直观反馈位置正确性

### 🖼️ 图片管理
- 支持自定义图片列表，可配置多张图片轮换
- 兼容本地资源 (Resource) 和网络图片路径
- 一键换图功能，增加游戏趣味性

### 🎨 主题定制
- 自定义主题色、背景色
- 可调节格子间距
- 渐变背景效果，视觉体验更佳

### 📱 交互体验
- 流畅的拖拽交互，支持从碎片区拖入网格
- 网格内碎片可互换位置
- 碎片可拖回底部区域重新放置
- 拖拽时实时高亮目标位置

### 🎉 完成反馈
- 精美的完成动画和弹窗
- 完成回调函数，方便业务逻辑处理
- 支持连续游戏，完成后可立即开始下一局

## 安装方式

### 方式1：从 GitHub 安装

在项目的 `oh-package.json5` 中添加依赖：

```json5
{
  "dependencies": {
    "puzzle-game": "git+https://github.com/heqiyuan35-creator/mypuzzle_library.git"
  }
}
```

然后执行：

```bash
ohpm install
```

### 方式2：本地安装

1. 克隆仓库：
```bash
git clone https://github.com/heqiyuan35-creator/mypuzzle_library.git
```

2. 将 library 目录复制到你的项目中

3. 在 `oh-package.json5` 中添加本地依赖：
```json5
{
  "dependencies": {
    "puzzle-game": "file:./library"
  }
}
```

## 快速开始

```typescript
import { PuzzleGame, PuzzleGameConfig, PuzzleImageInfo, PuzzleThemeConfig } from 'puzzle-game';

@Entry
@Component
struct MyPage {
  build() {
    Column() {
      PuzzleGame({
        config: {
          images: [
            { id: '1', name: '图片1', imagePath: $r("app.media.image1") } as PuzzleImageInfo,
            { id: '2', name: '图片2', imagePath: $r("app.media.image2") } as PuzzleImageInfo,
          ],
          theme: {
            primaryColor: '#4CAF50',
            backgroundColor: '#E8F5E9',
          } as PuzzleThemeConfig,
          onComplete: (imageName: string) => {
            console.log(`完成拼图: ${imageName}`);
          }
        } as PuzzleGameConfig
      })
    }
    .width('100%')
    .height('100%')
  }
}
```

## API

### PuzzleGameConfig

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| images | PuzzleImageInfo[] | 是 | 图片列表 |
| theme | PuzzleThemeConfig | 否 | 主题配置 |
| gridSizes | number[] | 否 | 可选网格大小，默认 [3, 4, 5] |
| defaultGridSize | number | 否 | 默认网格大小，默认 3 |
| onComplete | (imageName: string) => void | 否 | 完成回调 |

### PuzzleImageInfo

| 属性 | 类型 | 说明 |
|------|------|------|
| id | string | 图片唯一标识 |
| name | string | 图片名称 |
| imagePath | string \| Resource | 图片路径 |

### PuzzleThemeConfig

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| primaryColor | string | #4CAF50 | 主题色 |
| backgroundColor | string | #E8F5E9 | 背景色 |
| gridGap | number | 3 | 格子间距 |

## 许可证

Apache-2.0

## 应用场景

- **休闲游戏应用** - 作为独立小游戏或游戏合集的一部分
- **儿童教育应用** - 通过拼图锻炼儿童的观察力和空间思维
- **电商/营销活动** - 完成拼图解锁优惠券或奖励
- **相册应用** - 将用户照片变成拼图游戏
- **品牌互动** - 用品牌图片制作拼图，增加用户参与度

## 组件架构

```
PuzzleGame
├── PuzzleGrid          // 拼图网格区域
│   └── GridCell        // 单个格子（含已放置碎片）
├── GameInfo            // 游戏信息（图片名称、进度）
├── PiecesArea          // 底部碎片堆叠区
│   └── StackedPiece    // 单个待拖拽碎片
├── ActionButtons       // 操作按钮（难度选择、重来、换图）
├── DraggingPiece       // 拖拽中的碎片（浮层）
└── SuccessOverlay      // 完成弹窗
```

## 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

## 联系方式

如有问题或建议，请通过 GitHub Issues 联系我们。
