# puzzle-game

HarmonyOS ArkUI 拼图游戏组件库，提供可配置的拼图游戏功能。

## 功能特性

- 🎮 支持 3x3、4x4、5x5 等多种网格大小
- 🖼️ 支持自定义图片列表
- 🎨 支持自定义主题颜色
- 📱 流畅的拖拽交互体验
- ✅ 实时显示拼图进度
- 🎉 完成动画和回调

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
