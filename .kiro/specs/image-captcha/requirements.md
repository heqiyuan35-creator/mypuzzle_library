# Requirements Document

## Introduction

图片验证组件 - 类似 reCAPTCHA 的图片选择验证功能。通过预设题库的方式实现，每道题包含正确图片和干扰图片，用户需要选出所有符合条件的图片，提交后返回验证结果。

## Glossary

- **Challenge**: 一道验证题目，包含问题描述、正确图片列表、干扰图片列表
- **Image_Captcha**: 图片验证组件，负责展示题目和处理用户交互
- **Question**: 题目描述，如"选择所有包含猫的图片"
- **Correct_Images**: 符合题目条件的正确图片集合
- **Distractor_Images**: 不符合条件的干扰图片集合
- **Selection**: 用户当前选中的图片集合

## Requirements

### Requirement 1: 题库配置

**User Story:** As a developer, I want to configure a question bank with predefined challenges, so that the component can randomly select questions for verification.

#### Acceptance Criteria

1. THE Image_Captcha SHALL support configuring multiple Challenge items in a question bank
2. WHEN a Challenge is configured, THE Image_Captcha SHALL require a question text, at least 1 correct image, and at least 2 distractor images
3. THE Image_Captcha SHALL support both Resource type and string URL for image paths

### Requirement 2: 题目展示

**User Story:** As a user, I want to see a clear question and a grid of images, so that I can understand what to select.

#### Acceptance Criteria

1. WHEN the component loads, THE Image_Captcha SHALL randomly select one Challenge from the question bank
2. THE Image_Captcha SHALL display the question text prominently at the top
3. THE Image_Captcha SHALL display images in a grid layout (3x3 by default)
4. WHEN displaying images, THE Image_Captcha SHALL randomly shuffle the order of correct and distractor images
5. THE Image_Captcha SHALL support configurable grid size (e.g., 2x2, 3x3, 4x4)

### Requirement 3: 图片选择交互

**User Story:** As a user, I want to tap images to select or deselect them, so that I can mark which images match the question.

#### Acceptance Criteria

1. WHEN a user taps an unselected image, THE Image_Captcha SHALL add it to the Selection and show a visual indicator (e.g., checkmark, border highlight)
2. WHEN a user taps a selected image, THE Image_Captcha SHALL remove it from the Selection and remove the visual indicator
3. THE Image_Captcha SHALL allow selecting multiple images simultaneously
4. THE Image_Captcha SHALL provide clear visual distinction between selected and unselected images

### Requirement 4: 提交验证

**User Story:** As a user, I want to submit my selection and get immediate feedback, so that I know if I passed the verification.

#### Acceptance Criteria

1. THE Image_Captcha SHALL display a submit button below the image grid
2. WHEN the user clicks submit, THE Image_Captcha SHALL compare Selection with Correct_Images
3. WHEN Selection exactly matches Correct_Images (no more, no less), THE Image_Captcha SHALL return true
4. WHEN Selection does not exactly match Correct_Images, THE Image_Captcha SHALL return false
5. WHEN verification completes, THE Image_Captcha SHALL display visual feedback (success or failure)
6. IF verification fails, THEN THE Image_Captcha SHALL allow the user to retry with a new challenge

### Requirement 5: 重置与换题

**User Story:** As a user, I want to refresh and get a new challenge, so that I can try again if I'm stuck.

#### Acceptance Criteria

1. THE Image_Captcha SHALL provide a refresh/change button
2. WHEN the user clicks refresh, THE Image_Captcha SHALL randomly select a new Challenge from the question bank
3. WHEN a new Challenge is loaded, THE Image_Captcha SHALL clear the current Selection
4. WHEN a new Challenge is loaded, THE Image_Captcha SHALL re-shuffle the image order

### Requirement 6: 回调与结果获取

**User Story:** As a developer, I want to get the verification result programmatically, so that I can integrate it into my application flow.

#### Acceptance Criteria

1. THE Image_Captcha SHALL expose a public method `verify(): boolean` that returns the verification result
2. THE Image_Captcha SHALL support an optional callback `onVerify(result: boolean)` when verification completes
3. THE Image_Captcha SHALL expose a method `isVerified(): boolean` to check if the current challenge has been successfully verified
