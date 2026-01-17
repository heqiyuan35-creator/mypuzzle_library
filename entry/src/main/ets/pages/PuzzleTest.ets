/**
 * 拼图游戏组件库测试页面
 */
import { router } from '@kit.ArkUI';
import { PuzzleGame, PuzzleGameConfig, PuzzleImageInfo, PuzzleThemeConfig } from 'puzzle-game';

@Entry
@Component
struct PuzzleTestPage {
  @StorageProp('statusBarHeight') statusBarHeight: number = 0;

  build() {
    Column() {
      Row() {
        Row() {
          Text('‹').fontSize(24).fontColor('#333333')
        }
        .width(36).height(36).borderRadius(18)
        .backgroundColor('#FFFFFF')
        .justifyContent(FlexAlign.Center)
        .onClick(() => router.back())

        Text('组件库测试')
          .fontSize(18).fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1).textAlign(TextAlign.Center)

        Row().width(36).height(36)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: this.getUIContext().px2vp(this.statusBarHeight), bottom: 8 })
      .backgroundColor('#E3F2FD')

      PuzzleGame({
        config: {
          images: [
            { id: '1', name: '初音未来1', imagePath: $r("app.media.miku") } as PuzzleImageInfo,
            { id: '2', name: '初音未来2', imagePath: $r("app.media.miku1") } as PuzzleImageInfo,
            { id: '3', name: '初音未来3', imagePath: $r("app.media.miku2") } as PuzzleImageInfo,
          ],
          theme: {
            primaryColor: '#2196F3',
            backgroundColor: '#E3F2FD',
            gridGap: 3,
          } as PuzzleThemeConfig,
          gridSizes: [3, 4, 5],
          defaultGridSize: 3,
        } as PuzzleGameConfig
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#E3F2FD')
  }
}
