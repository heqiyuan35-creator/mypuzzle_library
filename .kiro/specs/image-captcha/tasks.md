# Implementation Plan: Image Captcha

## Overview

实现图片验证组件，采用预设题库方式，用户选择符合条件的图片后提交验证，返回布尔结果。

## Tasks

- [x] 1. 创建数据接口和类型定义
  - 定义 CaptchaImage、CaptchaChallenge、CaptchaConfig 接口
  - 创建 ImageCaptcha.ets 文件
  - _Requirements: 1.1, 1.2, 1.3_

- [ ] 2. 实现核心状态管理
  - [x] 2.1 实现题目加载和随机选择逻辑
    - 从题库随机选择一道题
    - 合并正确图片和干扰图片
    - 随机打乱图片顺序
    - _Requirements: 2.1, 2.4_

  - [x] 2.2 实现图片选择状态管理
    - selectedIds 集合的添加/删除
    - toggleSelect(id) 方法
    - _Requirements: 3.1, 3.2, 3.3_

  - [ ]* 2.3 编写选择逻辑的属性测试
    - **Property 4: Selection Toggle**
    - **Property 5: Multi-Selection**
    - **Validates: Requirements 3.1, 3.2, 3.3**

- [ ] 3. 实现验证逻辑
  - [x] 3.1 实现 verify() 方法
    - 比对 selectedIds 与 correctImageIds
    - 完全匹配返回 true，否则返回 false
    - _Requirements: 4.3, 4.4_

  - [x] 3.2 实现 isVerified() 方法
    - 返回当前验证状态
    - _Requirements: 6.3_

  - [ ]* 3.3 编写验证逻辑的属性测试
    - **Property 6: Verification Correctness**
    - **Validates: Requirements 4.3, 4.4**

- [ ] 4. 实现刷新和重置功能
  - [x] 4.1 实现 refresh() 方法
    - 随机选择新题目
    - 清空选择状态
    - 重新打乱图片
    - _Requirements: 5.2, 5.3, 5.4_

  - [ ]* 4.2 编写重置逻辑的属性测试
    - **Property 7: Reset Clears Selection**
    - **Validates: Requirements 5.3**

- [ ] 5. 实现 UI 组件
  - [x] 5.1 实现题目文字显示
    - 顶部显示问题描述
    - _Requirements: 2.2_

  - [x] 5.2 实现图片网格布局
    - 支持可配置的网格大小（默认3x3）
    - 图片点击选择/取消
    - 选中状态视觉反馈（边框高亮、勾选图标）
    - _Requirements: 2.3, 2.5, 3.4_

  - [x] 5.3 实现操作按钮区域
    - 刷新按钮
    - 提交验证按钮
    - _Requirements: 4.1, 5.1_

  - [x] 5.4 实现验证结果反馈
    - 成功/失败的视觉提示
    - 失败后允许重试
    - _Requirements: 4.5, 4.6_

- [ ] 6. 实现回调机制
  - [ ] 6.1 实现 onVerify 回调
    - 验证完成时调用回调函数
    - 传递验证结果
    - _Requirements: 6.2_

  - [ ]* 6.2 编写回调的属性测试
    - **Property 8: Callback Invocation**
    - **Validates: Requirements 6.2**

- [ ] 7. Checkpoint - 确保所有测试通过
  - 运行所有单元测试和属性测试
  - 确保组件功能完整
  - 如有问题请询问用户

- [ ] 8. 创建示例配置和演示页面
  - [ ] 8.1 创建示例题库配置
    - 至少3道不同的验证题
    - 包含不同类型的图片
    - _Requirements: 1.1_

  - [ ] 8.2 创建演示页面
    - 展示组件使用方式
    - 显示验证结果
    - _Requirements: 6.1_

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- 组件设计为独立单文件，可直接复制使用
- 图片支持 Resource 和 string URL 两种格式
- 验证逻辑为纯函数，易于测试
