/**
 * 图片验证组件 - 类似 reCAPTCHA 的图片选择验证
 * 可直接复制到任意 HarmonyOS 项目中使用
 *
 * 使用方法:
 * 1. 复制此文件到项目的 ets/pages/ 目录
 * 2. 在 main_pages.json 中注册页面路由
 * 3. 修改下方 CHALLENGE_LIST 配置你的题库
 */
import { router } from '@kit.ArkUI';

// ==================== 配置区域 ====================

// 题库配置 - 替换为你自己的题目
const CHALLENGE_LIST: CaptchaChallenge[] = [
  {
    id: '1',
    question: '选择所有包含猫的图片',
    correctImages: [
      { id: 'cat1', imagePath: $r("app.media.startIcon") },
    ],
    distractorImages: [
      { id: 'dog1', imagePath: $r("app.media.startIcon") },
      { id: 'dog2', imagePath: $r("app.media.startIcon") },
      { id: 'bird1', imagePath: $r("app.media.startIcon") },
    ]
  },
  {
    id: '2',
    question: '选择所有包含红色的图片',
    correctImages: [
      { id: 'red1', imagePath: $r("app.media.startIcon") },
      { id: 'red2', imagePath: $r("app.media.startIcon") },
    ],
    distractorImages: [
      { id: 'blue1', imagePath: $r("app.media.startIcon") },
      { id: 'green1', imagePath: $r("app.media.startIcon") },
    ]
  },
];

// 主题配置接口
interface CaptchaTheme {
  primaryColor: string;
  successColor: string;
  errorColor: string;
  backgroundColor: string;
  gridSize: number;
}

// 主题配置
const CAPTCHA_THEME: CaptchaTheme = {
  primaryColor: '#1976D2',
  successColor: '#4CAF50',
  errorColor: '#F44336',
  backgroundColor: '#F5F5F5',
  gridSize: 3,  // 默认 3x3
};

// ==================== 以下代码无需修改 ====================

// 单张图片
interface CaptchaImage {
  id: string;
  imagePath: Resource | string;
}

// 验证题目
interface CaptchaChallenge {
  id: string;
  question: string;
  correctImages: CaptchaImage[];
  distractorImages: CaptchaImage[];
}

@Entry
@Component
struct ImageCaptchaPage {
  @State currentChallenge: CaptchaChallenge | null = null;
  @State displayImages: CaptchaImage[] = [];
  @State selectedIds: string[] = [];
  @State isSubmitted: boolean = false;
  @State verifyResult: boolean | null = null;
  @State gridSize: number = CAPTCHA_THEME.gridSize;

  @StorageProp('statusBarHeight') statusBarHeight: number = 0;

  aboutToAppear(): void {
    this.loadRandomChallenge();
  }

  // 加载随机题目
  private loadRandomChallenge(): void {
    if (CHALLENGE_LIST.length === 0) return;

    const randomIndex = Math.floor(Math.random() * CHALLENGE_LIST.length);
    this.currentChallenge = CHALLENGE_LIST[randomIndex];
    this.shuffleImages();
    this.selectedIds = [];
    this.isSubmitted = false;
    this.verifyResult = null;
  }

  // 打乱图片顺序
  private shuffleImages(): void {
    if (!this.currentChallenge) return;

    const allImages: CaptchaImage[] = [
      ...this.currentChallenge.correctImages,
      ...this.currentChallenge.distractorImages
    ];

    // Fisher-Yates 洗牌
    for (let i = allImages.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      const temp = allImages[i];
      allImages[i] = allImages[j];
      allImages[j] = temp;
    }

    this.displayImages = allImages;
  }

  // 切换选择状态
  private toggleSelect(id: string): void {
    if (this.isSubmitted) return;

    const index = this.selectedIds.indexOf(id);
    if (index === -1) {
      this.selectedIds = [...this.selectedIds, id];
    } else {
      this.selectedIds = this.selectedIds.filter(item => item !== id);
    }
  }

  // 验证选择是否正确
  public verify(): boolean {
    if (!this.currentChallenge) return false;

    const correctIds = this.currentChallenge.correctImages.map(img => img.id);

    // 数量不同直接返回 false
    if (this.selectedIds.length !== correctIds.length) {
      return false;
    }

    // 检查每个选中的是否都在正确答案中
    for (const id of this.selectedIds) {
      if (!correctIds.includes(id)) {
        return false;
      }
    }

    return true;
  }

  // 检查是否已验证成功
  public isVerified(): boolean {
    return this.verifyResult === true;
  }

  // 提交验证
  private submitVerify(): void {
    const result = this.verify();
    this.verifyResult = result;
    this.isSubmitted = true;
  }

  // 刷新/换题
  public refresh(): void {
    this.loadRandomChallenge();
  }

  // 计算图片尺寸
  private getImageSize(): number {
    return Math.floor((320 - (this.gridSize - 1) * 4) / this.gridSize);
  }

  // 生成网格模板
  private getGridTemplate(): string {
    const arr: string[] = [];
    for (let i = 0; i < this.gridSize; i++) {
      arr.push('1fr');
    }
    return arr.join(' ');
  }

  build() {
    Column() {
      this.TopBar()

      Column({ space: 16 }) {
        // 题目
        if (this.currentChallenge) {
          Text(this.currentChallenge.question)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .textAlign(TextAlign.Center)
            .padding(16)
        }

        // 图片网格
        this.ImageGrid()

        // 结果反馈
        if (this.isSubmitted) {
          this.ResultFeedback()
        }

        // 操作按钮
        this.ActionButtons()
      }
      .width('100%')
      .layoutWeight(1)
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CAPTCHA_THEME.backgroundColor)
  }

  @Builder
  TopBar() {
    Row() {
      Row() {
        Text('‹').fontSize(24).fontColor('#333333')
      }
      .width(36).height(36).borderRadius(18)
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center)
      .onClick(() => router.back())

      Text('图片验证')
        .fontSize(18).fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1).textAlign(TextAlign.Center)

      Row().width(36).height(36)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: this.getUIContext().px2vp(this.statusBarHeight), bottom: 8 })
  }

  @Builder
  ImageGrid() {
    Column() {
      Grid() {
        ForEach(this.displayImages, (image: CaptchaImage) => {
          GridItem() {
            this.ImageCell(image)
          }
        }, (image: CaptchaImage) => image.id)
      }
      .columnsTemplate(this.getGridTemplate())
      .rowsTemplate(this.getGridTemplate())
      .columnsGap(4)
      .rowsGap(4)
      .width(320)
      .height(320)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  ImageCell(image: CaptchaImage) {
    Stack() {
      Image(image.imagePath)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .borderRadius(8)

      // 选中遮罩
      if (this.selectedIds.includes(image.id)) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(25, 118, 210, 0.3)')
          .borderRadius(8)

        // 勾选图标
        Text('✓')
          .fontSize(24)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
      }

      // 提交后显示正确/错误标记 - 漏选的正确答案
      if (this.isSubmitted && this.currentChallenge &&
          this.currentChallenge.correctImages.some(img => img.id === image.id) &&
          !this.selectedIds.includes(image.id)) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(76, 175, 80, 0.5)')
          .borderRadius(8)
      }

      // 提交后显示正确/错误标记 - 错选的干扰项
      if (this.isSubmitted && this.currentChallenge &&
          !this.currentChallenge.correctImages.some(img => img.id === image.id) &&
          this.selectedIds.includes(image.id)) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(244, 67, 54, 0.5)')
          .borderRadius(8)
      }
    }
    .width(this.getImageSize())
    .height(this.getImageSize())
    .borderRadius(8)
    .border({
      width: this.selectedIds.includes(image.id) ? 3 : 1,
      color: this.selectedIds.includes(image.id) ? CAPTCHA_THEME.primaryColor : '#E0E0E0'
    })
    .onClick(() => this.toggleSelect(image.id))
  }

  @Builder
  ResultFeedback() {
    Row({ space: 8 }) {
      Text(this.verifyResult ? '✓' : '✗')
        .fontSize(20)
        .fontColor(this.verifyResult ? CAPTCHA_THEME.successColor : CAPTCHA_THEME.errorColor)

      Text(this.verifyResult ? '验证成功！' : '验证失败，请重试')
        .fontSize(16)
        .fontColor(this.verifyResult ? CAPTCHA_THEME.successColor : CAPTCHA_THEME.errorColor)
    }
    .padding(12)
    .backgroundColor(this.verifyResult ? 'rgba(76, 175, 80, 0.1)' : 'rgba(244, 67, 54, 0.1)')
    .borderRadius(8)
  }

  @Builder
  ActionButtons() {
    Row({ space: 12 }) {
      Button('换一题')
        .fontSize(14)
        .fontColor(CAPTCHA_THEME.primaryColor)
        .backgroundColor(CAPTCHA_THEME.primaryColor + '20')
        .borderRadius(20)
        .height(40)
        .layoutWeight(1)
        .onClick(() => this.refresh())

      Button(this.isSubmitted ? '重新验证' : '提交验证')
        .fontSize(14)
        .fontColor('#FFFFFF')
        .backgroundColor(CAPTCHA_THEME.primaryColor)
        .borderRadius(20)
        .height(40)
        .layoutWeight(1)
        .onClick(() => {
          if (this.isSubmitted) {
            this.refresh();
          } else {
            this.submitVerify();
          }
        })
    }
    .width('100%')
    .padding({ top: 16 })
  }
}
