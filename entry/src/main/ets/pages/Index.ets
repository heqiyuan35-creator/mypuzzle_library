/**
 * 拼图游戏 - 完全独立单文件版本
 * 可直接复制到任意 HarmonyOS 项目中使用，无需任何外部依赖
 *
 * 使用方法:
 * 1. 复制此文件到项目的 ets/pages/ 目录
 * 2. 在 main_pages.json 中注册页面路由
 * 3. 修改下方 IMAGE_LIST 为你自己的图片
 * 4. 图片放在 rawfile/images/ 目录下
 */
import { router } from '@kit.ArkUI';

// ==================== 配置区域 - 修改这里的数据 ====================

// 图片列表 - 替换为你自己的图片
// 使用 $r("app.media.xxx") 引用 media 资源
// 使用 $rawfile("images/xxx.jpg") 引用 rawfile 资源
const IMAGE_LIST: ImageInfo[] = [
  { id: '1', name: '示例图片1', imagePath: $r("app.media.miku") },
  { id: '2', name: '示例图片2', imagePath: $r("app.media.miku1") },
  { id: '3', name: '示例图片3', imagePath: $r("app.media.miku2") },
];

// 主题配置
interface GeneratedObjectLiteralInterface_1 {
  primaryColor: string;
  backgroundColor: string;
  title: string;
  gridGap: number;
}

const THEME: GeneratedObjectLiteralInterface_1 = {
  primaryColor: '#4CAF50',      // 主题色
  backgroundColor: '#E8F5E9',   // 背景色
  title: '拼图游戏',             // 页面标题
  gridGap: 3,                   // 格子间距
};

// 网格大小配置
const GRID_SIZES: number[] = [3, 4, 5];  // 支持的网格大小选项

// ==================== 以下代码无需修改 ====================

interface ImageInfo {
  id: string;
  name: string;
  imagePath: string | Resource;  // string 用于在线URL，Resource 用于本地资源
}

class PuzzlePiece {
  id: number;
  correctPosition: number;
  rotation: number;
  offsetX: number;
  offsetY: number;

  constructor(id: number) {
    this.id = id;
    this.correctPosition = id;
    this.rotation = (Math.random() - 0.5) * 30;
    this.offsetX = (Math.random() - 0.5) * 20;
    this.offsetY = (Math.random() - 0.5) * 20;
  }
}

@Entry
@Component
struct PuzzleGameStandalone {
  @State currentImageIndex: number = 0;
  @State gridSize: number = 3;  // 当前网格大小 (3=3x3, 4=4x4, 5=5x5)
  @State bottomPieces: PuzzlePiece[] = [];
  @State gridState: number[] = [];
  @State completedCount: number = 0;
  @State isDragging: boolean = false;
  @State draggingPieceId: number = -1;
  @State draggingFromGrid: number = -1;
  @State highlightIndex: number = -1;
  @State showSuccess: boolean = false;
  @State dragX: number = 0;
  @State dragY: number = 0;
  @State gridAreaX: number = 0;
  @State gridAreaY: number = 0;

  @StorageProp('statusBarHeight') statusBarHeight: number = 0;

  // 计算方法 - 替代 getter 以支持响应式
  private getTotalPieces(): number {
    return this.gridSize * this.gridSize;
  }

  private getPieceSize(): number {
    if (this.gridSize === 3) return 85;
    if (this.gridSize === 4) return 70;
    return 58;
  }

  private getSmallPieceSize(): number {
    if (this.gridSize === 3) return 60;
    if (this.gridSize === 4) return 50;
    return 42;
  }

  private getGridIndices(): number[] {
    const indices: number[] = [];
    const total = this.gridSize * this.gridSize;
    for (let i = 0; i < total; i++) {
      indices.push(i);
    }
    return indices;
  }

  private getGridTemplate(): string {
    const arr: string[] = [];
    for (let i = 0; i < this.gridSize; i++) {
      arr.push('1fr');
    }
    return arr.join(' ');
  }

  // 获取当前图片源，支持 string (URL) 和 Resource
  private getCurrentImageSrc(): string | Resource {
    if (IMAGE_LIST.length === 0) return '';
    return IMAGE_LIST[this.currentImageIndex].imagePath;
  }

  private getCurrentImageName(): string {
    if (IMAGE_LIST.length === 0) return '';
    return IMAGE_LIST[this.currentImageIndex].name;
  }

  aboutToAppear(): void {
    this.initGame();
  }

  private initGame(): void {
    if (IMAGE_LIST.length > 0) {
      this.currentImageIndex = Math.floor(Math.random() * IMAGE_LIST.length);
    }
    this.createAndShufflePieces();
  }

  private createAndShufflePieces(): void {
    const total = this.getTotalPieces();
    const newPieces: PuzzlePiece[] = [];
    for (let i = 0; i < total; i++) {
      newPieces.push(new PuzzlePiece(i));
    }
    for (let i = newPieces.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      const temp = newPieces[i];
      newPieces[i] = newPieces[j];
      newPieces[j] = temp;
    }
    this.bottomPieces = newPieces;
    // 初始化网格状态
    const newGridState: number[] = [];
    for (let i = 0; i < total; i++) {
      newGridState.push(-1);
    }
    this.gridState = newGridState;
    this.completedCount = 0;
    this.showSuccess = false;
  }

  private changeGridSize(size: number): void {
    this.gridSize = size;
    this.createAndShufflePieces();
  }

  private changeImage(): void {
    if (IMAGE_LIST.length > 1) {
      let newIndex: number;
      do {
        newIndex = Math.floor(Math.random() * IMAGE_LIST.length);
      } while (newIndex === this.currentImageIndex);
      this.currentImageIndex = newIndex;
    }
    this.createAndShufflePieces();
  }

  private handleDrop(pieceId: number, targetGridIndex: number): void {
    const newGridState: number[] = this.gridState.slice();
    const targetPieceId: number = newGridState[targetGridIndex];

    if (this.draggingFromGrid !== -1) {
      if (targetPieceId !== -1) {
        newGridState[this.draggingFromGrid] = targetPieceId;
      } else {
        newGridState[this.draggingFromGrid] = -1;
      }
      newGridState[targetGridIndex] = pieceId;
    } else {
      if (targetPieceId !== -1) {
        const displacedPiece: PuzzlePiece = new PuzzlePiece(targetPieceId);
        const filtered: PuzzlePiece[] = this.bottomPieces.filter((p: PuzzlePiece) => p.id !== pieceId);
        const newBottomPieces: PuzzlePiece[] = filtered.slice();
        newBottomPieces.push(displacedPiece);
        this.bottomPieces = newBottomPieces;
      } else {
        this.bottomPieces = this.bottomPieces.filter((p: PuzzlePiece) => p.id !== pieceId);
      }
      newGridState[targetGridIndex] = pieceId;
    }

    this.gridState = newGridState;
    this.updateCompletedCount();
  }

  private moveBackToBottom(pieceId: number, fromGridIndex: number): void {
    const newGridState: number[] = this.gridState.slice();
    newGridState[fromGridIndex] = -1;
    this.gridState = newGridState;
    const piece = new PuzzlePiece(pieceId);
    const newBottomPieces: PuzzlePiece[] = this.bottomPieces.slice();
    newBottomPieces.push(piece);
    this.bottomPieces = newBottomPieces;
    this.updateCompletedCount();
  }

  private updateCompletedCount(): void {
    const total = this.getTotalPieces();
    let count = 0;
    for (let i = 0; i < total; i++) {
      if (this.gridState[i] === i) count++;
    }
    this.completedCount = count;
    if (count === total) {
      setTimeout(() => { this.showSuccess = true; }, 300);
    }
  }

  // 判断拼图是否完成
  public isCompleted(): boolean {
    return this.completedCount === this.getTotalPieces() && this.getTotalPieces() > 0;
  }

  private resetDragState(): void {
    this.isDragging = false;
    this.draggingPieceId = -1;
    this.draggingFromGrid = -1;
    this.highlightIndex = -1;
    this.dragX = 0;
    this.dragY = 0;
  }

  private calcDropTarget(): number {
    const pSize = this.getPieceSize();
    const cellSize = pSize + THEME.gridGap;
    const totalSize = pSize * this.gridSize + THEME.gridGap * (this.gridSize - 1);
    const margin = 20;
    const relX = this.dragX - this.gridAreaX + margin;
    const relY = this.dragY - this.gridAreaY + margin;

    if (relX < 0 || relX > totalSize + margin * 2 || relY < 0 || relY > totalSize + margin * 2) {
      return -1;
    }

    const col = Math.floor(relX / cellSize);
    const row = Math.floor(relY / cellSize);

    if (col < 0 || col >= this.gridSize || row < 0 || row >= this.gridSize) return -1;
    return row * this.gridSize + col;
  }

  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [
            [THEME.backgroundColor, 0],
            ['#FFFFFF', 0.5],
            [THEME.backgroundColor, 1]
          ]
        })

      Column() {
        this.TopBar()
        
        List() {
          ListItem() {
            Column({ space: 12 }) {
              this.PuzzleGrid()
              this.GameInfo()
              this.PiecesArea()
              this.ActionButtons()
            }
            .width('100%')
          }
        }
        .width('100%')
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16 })

      if (this.isDragging && this.draggingPieceId >= 0) {
        this.DraggingPiece()
      }

      if (this.showSuccess) {
        this.SuccessOverlay()
      }
    }
    .width('100%')
    .height('100%')
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

      Text(THEME.title)
        .fontSize(18).fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1).textAlign(TextAlign.Center)

      Row() {
        Text('验证').fontSize(12).fontColor('#FFFFFF')
      }
      .width(36).height(36).borderRadius(18)
      .backgroundColor(THEME.primaryColor)
      .justifyContent(FlexAlign.Center)
      .onClick(() => router.pushUrl({ url: 'pages/ImageCaptcha' }))

      Row() {
        Text('库').fontSize(12).fontColor('#FFFFFF')
      }
      .width(36).height(36).borderRadius(18)
      .backgroundColor('#2196F3')
      .justifyContent(FlexAlign.Center)
      .margin({ left: 8 })
      .onClick(() => router.pushUrl({ url: 'pages/PuzzleTest' }))
    }
    .width('100%')
    .padding({ top: this.getUIContext().px2vp(this.statusBarHeight) })
  }

  @Builder
  DraggingPiece() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image(this.getCurrentImageSrc())
        .width(this.getPieceSize() * this.gridSize)
        .height(this.getPieceSize() * this.gridSize)
        .objectFit(ImageFit.Cover)
        .margin({
          left: -(this.draggingPieceId % this.gridSize) * this.getPieceSize(),
          top: -Math.floor(this.draggingPieceId / this.gridSize) * this.getPieceSize()
        })
    }
    .width(this.getPieceSize())
    .height(this.getPieceSize())
    .clip(true)
    .borderRadius(8)
    .border({ width: 3, color: THEME.primaryColor })
    .shadow({ radius: 16, color: 'rgba(0,0,0,0.4)', offsetY: 8 })
    .position({ x: this.dragX - this.getPieceSize() / 2, y: this.dragY - this.getPieceSize() / 2 })
    .hitTestBehavior(HitTestMode.None)
  }

  @Builder
  PuzzleGrid() {
    Column() {
      Grid() {
        ForEach(this.getGridIndices(), (gridIndex: number) => {
          GridItem() {
            this.GridCell(gridIndex)
          }
        }, (index: number) => `${this.gridSize}_${index}_${this.gridState[index]}`)
      }
      .columnsTemplate(this.getGridTemplate())
      .rowsTemplate(this.getGridTemplate())
      .columnsGap(THEME.gridGap)
      .rowsGap(THEME.gridGap)
      .width(this.getPieceSize() * this.gridSize + THEME.gridGap * (this.gridSize - 1))
      .height(this.getPieceSize() * this.gridSize + THEME.gridGap * (this.gridSize - 1))
      .onAreaChange((oldArea: Area, newArea: Area) => {
        this.gridAreaX = newArea.globalPosition.x as number;
        this.gridAreaY = newArea.globalPosition.y as number;
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  GridCell(gridIndex: number) {
    Stack() {
      Column()
        .width('100%').height('100%')
        .backgroundColor(this.highlightIndex === gridIndex ? THEME.primaryColor + '30' : 'rgba(0, 0, 0, 0.05)')
        .borderRadius(6)
        .border({
          width: 2,
          color: this.highlightIndex === gridIndex ? THEME.primaryColor : 'transparent',
          style: BorderStyle.Dashed
        })

      if (this.gridState[gridIndex] !== -1) {
        this.PlacedPieceContent(this.gridState[gridIndex], gridIndex)
      }
    }
    .width(this.getPieceSize())
    .height(this.getPieceSize())
  }

  @Builder
  PlacedPieceContent(pieceId: number, gridIndex: number) {
    Stack({ alignContent: Alignment.TopStart }) {
      Image(this.getCurrentImageSrc())
        .width(this.getPieceSize() * this.gridSize)
        .height(this.getPieceSize() * this.gridSize)
        .objectFit(ImageFit.Cover)
        .margin({
          left: -(pieceId % this.gridSize) * this.getPieceSize(),
          top: -Math.floor(pieceId / this.gridSize) * this.getPieceSize()
        })
    }
    .width(this.getPieceSize())
    .height(this.getPieceSize())
    .clip(true)
    .borderRadius(6)
    .border({
      width: this.highlightIndex === gridIndex ? 3 : 2,
      color: this.highlightIndex === gridIndex ? THEME.primaryColor :
        (pieceId === gridIndex ? '#4CAF50' : '#FF5252')
    })
    .opacity(this.draggingPieceId === pieceId && this.draggingFromGrid === gridIndex ? 0.3 : 1)
    .gesture(
      PanGesture({ fingers: 1, direction: PanDirection.All, distance: 1 })
        .onActionStart((event: GestureEvent) => {
          const realPieceId = this.gridState[gridIndex];
          this.isDragging = true;
          this.draggingPieceId = realPieceId;
          this.draggingFromGrid = gridIndex;
          const finger = event.fingerList[0];
          this.dragX = finger.globalX;
          this.dragY = finger.globalY;
        })
        .onActionUpdate((event: GestureEvent) => {
          const finger = event.fingerList[0];
          this.dragX = finger.globalX;
          this.dragY = finger.globalY;
          this.highlightIndex = this.calcDropTarget();
        })
        .onActionEnd(() => {
          const target = this.highlightIndex;
          const fromGrid = this.draggingFromGrid;
          const draggedPieceId = this.draggingPieceId;
          if (target >= 0 && target < this.getTotalPieces() && target !== fromGrid) {
            this.handleDrop(draggedPieceId, target);
          } else if (this.dragY > 500) {
            this.moveBackToBottom(draggedPieceId, fromGrid);
          }
          setTimeout(() => { this.resetDragState(); }, 50);
        })
    )
  }

  @Builder
  GameInfo() {
    Row({ space: 12 }) {
      Text(this.getCurrentImageName())
        .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
      Text(`${this.completedCount}/${this.getTotalPieces()}`)
        .fontSize(14).fontColor(this.completedCount === this.getTotalPieces() ? '#4CAF50' : THEME.primaryColor)
    }
  }

  @Builder
  PiecesArea() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        if (this.bottomPieces.length === 0) {
          Text('碎片已全部放入上方')
            .fontSize(13).fontColor('#999999')
        }
        ForEach(this.bottomPieces, (piece: PuzzlePiece, index: number) => {
          this.StackedPiece(piece, index)
        }, (piece: PuzzlePiece) => `${this.gridSize}_${piece.id}`)
      }
      .width('100%')
      .height(this.gridSize <= 3 ? 140 : (this.gridSize === 4 ? 180 : 220))
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
    }
    .width('100%')
  }

  @Builder
  StackedPiece(piece: PuzzlePiece, index: number) {
    Stack({ alignContent: Alignment.TopStart }) {
      Image(this.getCurrentImageSrc())
        .width(this.getSmallPieceSize() * this.gridSize)
        .height(this.getSmallPieceSize() * this.gridSize)
        .objectFit(ImageFit.Cover)
        .margin({
          left: -(piece.id % this.gridSize) * this.getSmallPieceSize(),
          top: -Math.floor(piece.id / this.gridSize) * this.getSmallPieceSize()
        })
    }
    .width(this.getSmallPieceSize())
    .height(this.getSmallPieceSize())
    .clip(true)
    .borderRadius(6)
    .border({ width: 2, color: THEME.primaryColor + '80' })
    .position({
      x: 15 + (index % 7) * (this.getSmallPieceSize() + 2) + piece.offsetX,
      y: 10 + Math.floor(index / 7) * (this.getSmallPieceSize() + 2) + piece.offsetY
    })
    .rotate({ angle: piece.rotation })
    .opacity(this.draggingPieceId === piece.id ? 0.3 : 1)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.15)', offsetY: 2 })
    .gesture(
      PanGesture({ fingers: 1, direction: PanDirection.All, distance: 1 })
        .onActionStart((event: GestureEvent) => {
          this.isDragging = true;
          this.draggingPieceId = piece.id;
          this.draggingFromGrid = -1;
          const finger = event.fingerList[0];
          this.dragX = finger.globalX;
          this.dragY = finger.globalY;
        })
        .onActionUpdate((event: GestureEvent) => {
          const finger = event.fingerList[0];
          this.dragX = finger.globalX;
          this.dragY = finger.globalY;
          this.highlightIndex = this.calcDropTarget();
        })
        .onActionEnd(() => {
          const target = this.highlightIndex;
          if (target >= 0 && target < this.getTotalPieces()) {
            this.handleDrop(piece.id, target);
          }
          setTimeout(() => { this.resetDragState(); }, 50);
        })
    )
  }

  @Builder
  ActionButtons() {
    Column({ space: 8 }) {
      // 难度选择
      Row({ space: 8 }) {
        Text('难度:').fontSize(13).fontColor('#666666')
        ForEach(GRID_SIZES, (size: number) => {
          Button(`${size}x${size}`)
            .fontSize(12)
            .fontColor(this.gridSize === size ? '#FFFFFF' : THEME.primaryColor)
            .backgroundColor(this.gridSize === size ? THEME.primaryColor : THEME.primaryColor + '20')
            .borderRadius(14)
            .height(28)
            .width(55)
            .onClick(() => this.changeGridSize(size))
        }, (size: number) => size.toString())
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Row({ space: 12 }) {
        Button('重来')
          .fontSize(13).fontColor(THEME.primaryColor)
          .backgroundColor(THEME.primaryColor + '20')
          .borderRadius(16).height(32).layoutWeight(1)
          .onClick(() => this.createAndShufflePieces())

        Button('换图')
          .fontSize(13).fontColor('#FFFFFF')
          .backgroundColor(THEME.primaryColor)
          .borderRadius(16).height(32).layoutWeight(1)
          .onClick(() => this.changeImage())
      }
      .width('100%')

      Column({ space: 4 }) {
        Text('拖动下方碎片到网格中还原图片')
          .fontSize(12).fontColor('#333333')
        Text('绿框表示位置正确 · 红框表示位置错误')
          .fontSize(11).fontColor('#666666')
      }
      .width('100%')
      .padding(12)
      .backgroundColor('rgba(255, 255, 255, 0.85)')
      .borderRadius(12)
    }
    .width('100%')
  }

  @Builder
  SuccessOverlay() {
    Column() {
      Column()
        .width('100%').height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.7)')

      Column({ space: 16 }) {
        Image(this.getCurrentImageSrc())
          .width(200).height(200)
          .objectFit(ImageFit.Cover).borderRadius(12)
          .shadow({ radius: 16, color: 'rgba(0,0,0,0.4)', offsetY: 8 })

        Text('🎉 完成!').fontSize(22).fontWeight(FontWeight.Bold).fontColor(Color.White)
        Text(this.getCurrentImageName()).fontSize(18).fontColor(Color.White)

        Row({ space: 12 }) {
          Button('再来一局')
            .fontSize(13).fontColor(THEME.primaryColor)
            .backgroundColor(Color.White).borderRadius(16).height(36).width(100)
            .onClick(() => { this.showSuccess = false; this.changeImage(); })
        }
      }
      .position({ x: '50%', y: '50%' })
      .translate({ x: '-50%', y: '-50%' })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%').height('100%')
    .position({ x: 0, y: 0 })
  }

  pageTransition() {
    PageTransitionEnter({ type: RouteType.Push, duration: 350 }).slide(SlideEffect.Right)
    PageTransitionEnter({ type: RouteType.Pop, duration: 350 }).slide(SlideEffect.Left)
    PageTransitionExit({ type: RouteType.Push, duration: 350 }).slide(SlideEffect.Left)
    PageTransitionExit({ type: RouteType.Pop, duration: 350 }).slide(SlideEffect.Right)
  }
}
