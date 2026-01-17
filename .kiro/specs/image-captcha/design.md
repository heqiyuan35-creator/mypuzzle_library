# Design Document

## Overview

图片验证组件（Image Captcha）是一个独立的 HarmonyOS ArkUI 组件，用于实现类似 reCAPTCHA 的图片选择验证功能。组件通过预设题库的方式工作，每道题包含问题描述、正确图片和干扰图片，用户需要选出所有符合条件的图片并提交验证。

## Architecture

```
┌─────────────────────────────────────────┐
│           ImageCaptcha Component         │
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────┐    │
│  │         Question Text            │    │
│  └─────────────────────────────────┘    │
│  ┌─────────────────────────────────┐    │
│  │         Image Grid               │    │
│  │  ┌───┐ ┌───┐ ┌───┐              │    │
│  │  │ ✓ │ │   │ │   │  ...         │    │
│  │  └───┘ └───┘ └───┘              │    │
│  └─────────────────────────────────┘    │
│  ┌─────────────────────────────────┐    │
│  │    [刷新]      [提交验证]        │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

## Components and Interfaces

### 1. 数据接口

```typescript
// 单张图片配置
interface CaptchaImage {
  id: string;                      // 图片唯一标识
  imagePath: Resource | string;    // 图片路径
}

// 单道验证题目
interface CaptchaChallenge {
  id: string;                      // 题目唯一标识
  question: string;                // 问题描述，如"选择所有包含猫的图片"
  correctImages: CaptchaImage[];   // 正确答案图片（至少1张）
  distractorImages: CaptchaImage[];// 干扰图片（至少2张）
}

// 组件配置
interface CaptchaConfig {
  challenges: CaptchaChallenge[];  // 题库
  gridSize?: number;               // 网格大小，默认3（3x3）
  onVerify?: (result: boolean) => void;  // 验证回调
}
```

### 2. 组件状态

```typescript
@State currentChallenge: CaptchaChallenge | null  // 当前题目
@State displayImages: CaptchaImage[]              // 打乱后的展示图片
@State selectedIds: Set<string>                   // 用户选中的图片ID集合
@State isSubmitted: boolean                       // 是否已提交
@State verifyResult: boolean | null               // 验证结果
```

### 3. 公开方法

```typescript
// 执行验证，返回结果
public verify(): boolean

// 检查是否已成功验证
public isVerified(): boolean

// 重置并加载新题目
public refresh(): void
```

## Data Models

### 运行时数据流

```
题库配置 (CaptchaChallenge[])
    │
    ▼ 随机选择
当前题目 (currentChallenge)
    │
    ▼ 合并 + 打乱
展示图片 (displayImages)
    │
    ▼ 用户点击
选中集合 (selectedIds)
    │
    ▼ 提交验证
比对结果 (verifyResult: boolean)
```

### 验证逻辑

```typescript
verify(): boolean {
  // 获取正确答案ID集合
  const correctIds = new Set(
    this.currentChallenge.correctImages.map(img => img.id)
  );
  
  // 完全匹配判断：选中的 === 正确的
  if (this.selectedIds.size !== correctIds.size) {
    return false;
  }
  
  for (const id of this.selectedIds) {
    if (!correctIds.has(id)) {
      return false;
    }
  }
  
  return true;
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Challenge Validation
*For any* CaptchaChallenge, it must have a non-empty question, at least 1 correct image, and at least 2 distractor images to be valid.
**Validates: Requirements 1.2**

### Property 2: Random Challenge Selection
*For any* question bank with multiple challenges, loading the component multiple times should eventually select different challenges (not always the same one).
**Validates: Requirements 2.1**

### Property 3: Image Shuffle
*For any* set of images (correct + distractor), the displayed order should be a permutation of the original set, containing all images exactly once.
**Validates: Requirements 2.4, 5.4**

### Property 4: Selection Toggle
*For any* image in the grid, tapping it should toggle its selection state: if unselected, it becomes selected; if selected, it becomes unselected.
**Validates: Requirements 3.1, 3.2**

### Property 5: Multi-Selection
*For any* sequence of image taps on distinct images, all tapped images should be in the selection set simultaneously.
**Validates: Requirements 3.3**

### Property 6: Verification Correctness
*For any* challenge and user selection:
- If selectedIds exactly equals correctImageIds (same size, same elements), verify() returns true
- Otherwise, verify() returns false
**Validates: Requirements 4.3, 4.4**

### Property 7: Reset Clears Selection
*For any* state with non-empty selection, calling refresh() should result in an empty selection set.
**Validates: Requirements 5.3**

### Property 8: Callback Invocation
*For any* verification action, if onVerify callback is configured, it should be called with the same boolean result as verify() returns.
**Validates: Requirements 6.2**

### Property 9: isVerified State Consistency
*For any* component state, isVerified() should return true only if the last verification was successful and no refresh has occurred since.
**Validates: Requirements 6.3**

## Error Handling

| 场景 | 处理方式 |
|------|----------|
| 题库为空 | 显示错误提示，禁用提交按钮 |
| 图片加载失败 | 显示占位图，不影响验证逻辑 |
| 未选择任何图片就提交 | 允许提交，返回 false（除非正确答案也是0张） |

## Testing Strategy

### 单元测试
- 验证逻辑测试：各种选择组合的正确/错误判断
- 状态管理测试：选择、取消选择、重置
- 配置验证测试：无效配置的拒绝

### 属性测试（Property-Based Testing）
使用 fast-check 或类似库：
- 生成随机题目配置，验证 Property 1（配置验证）
- 生成随机选择序列，验证 Property 4-6（选择和验证逻辑）
- 最少 100 次迭代

### 集成测试
- 完整用户流程：加载 → 选择 → 提交 → 查看结果
- 重试流程：失败 → 刷新 → 重新选择 → 提交
