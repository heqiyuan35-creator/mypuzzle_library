/**
 * 拼图游戏组件 - HarmonyOS ArkUI 组件库
 * 支持自定义图片、网格大小、主题配置
 */

// ==================== 导出接口 ====================

/** 图片信息配置 */
export interface PuzzleImageInfo {
  id: string;
  name: string;
  imagePath: string | Resource;
}

/** 主题配置 */
export interface PuzzleThemeConfig {
  primaryColor?: string;
  backgroundColor?: string;
  gridGap?: number;
}

/** 组件配置 */
export interface PuzzleGameConfig {
  images: PuzzleImageInfo[];
  theme?: PuzzleThemeConfig;
  gridSizes?: number[];
  defaultGridSize?: number;
  onComplete?: (imageName: string) => void;
}

// ==================== 内部实现 ====================

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

@Component
export struct PuzzleGame {
  @Require @Prop @Watch('onConfigChange') config: PuzzleGameConfig;
  @State private isInitialized: boolean = false;
  @State currentImageIndex: number = 0;
  @State gridSize: number = 3;
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

  private getPrimaryColor(): string {
    return this.config.theme?.primaryColor ?? '#4CAF50';
  }

  private getBackgroundColor(): string {
    return this.config.theme?.backgroundColor ?? '#E8F5E9';
  }

  private getGridGap(): number {
    return this.config.theme?.gridGap ?? 3;
  }

  private getGridSizes(): number[] {
    return this.config.gridSizes ?? [3, 4, 5];
  }

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

  private getCurrentImageSrc(): string | Resource {
    if (this.config.images.length === 0) return '';
    return this.config.images[this.currentImageIndex].imagePath;
  }

  private getCurrentImageName(): string {
    if (this.config.images.length === 0) return '';
    return this.config.images[this.currentImageIndex].name;
  }

  aboutToAppear(): void {
    this.tryInit();
  }

  private onConfigChange(): void {
    this.tryInit();
  }

  private tryInit(): void {
    if (!this.isInitialized && this.config && this.config.images && this.config.images.length > 0) {
      this.gridSize = this.config.defaultGridSize ?? 3;
      this.initGame();
      this.isInitialized = true;
    }
  }

  private initGame(): void {
    this.currentImageIndex = Math.floor(Math.random() * this.config.images.length);
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
    if (this.config.images.length > 1) {
      let newIndex: number;
      do {
        newIndex = Math.floor(Math.random() * this.config.images.length);
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
      setTimeout(() => {
        this.showSuccess = true;
        if (this.config.onComplete) {
          this.config.onComplete(this.getCurrentImageName());
        }
      }, 300);
    }
  }

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
    const cellSize = pSize + this.getGridGap();
    const totalSize = pSize * this.gridSize + this.getGridGap() * (this.gridSize - 1);
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
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [[this.getBackgroundColor(), 0], ['#FFFFFF', 0.5], [this.getBackgroundColor(), 1]]
        })

      if (this.isInitialized) {
        Column({ space: 12 }) {
          this.PuzzleGrid()
          this.GameInfo()
          this.PiecesArea()
          this.ActionButtons()
        }
        .width('100%')
        .padding(16)
      } else {
        Text('加载中...')
          .fontSize(16)
          .fontColor('#999999')
      }

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
    .border({ width: 3, color: this.getPrimaryColor() })
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
      .columnsGap(this.getGridGap())
      .rowsGap(this.getGridGap())
      .width(this.getPieceSize() * this.gridSize + this.getGridGap() * (this.gridSize - 1))
      .height(this.getPieceSize() * this.gridSize + this.getGridGap() * (this.gridSize - 1))
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
        .backgroundColor(this.highlightIndex === gridIndex ? this.getPrimaryColor() + '30' : 'rgba(0, 0, 0, 0.05)')
        .borderRadius(6)
        .border({
          width: 2,
          color: this.highlightIndex === gridIndex ? this.getPrimaryColor() : 'transparent',
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
      color: this.highlightIndex === gridIndex ? this.getPrimaryColor() : (pieceId === gridIndex ? '#4CAF50' : '#FF5252')
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
        .fontSize(14).fontColor(this.completedCount === this.getTotalPieces() ? '#4CAF50' : this.getPrimaryColor())
    }
  }

  @Builder
  PiecesArea() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        if (this.bottomPieces.length === 0) {
          Text('碎片已全部放入上方').fontSize(13).fontColor('#999999')
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
    .border({ width: 2, color: this.getPrimaryColor() + '80' })
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
      Row({ space: 8 }) {
        Text('难度:').fontSize(13).fontColor('#666666')
        ForEach(this.getGridSizes(), (size: number) => {
          Button(`${size}x${size}`)
            .fontSize(12)
            .fontColor(this.gridSize === size ? '#FFFFFF' : this.getPrimaryColor())
            .backgroundColor(this.gridSize === size ? this.getPrimaryColor() : this.getPrimaryColor() + '20')
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
          .fontSize(13).fontColor(this.getPrimaryColor())
          .backgroundColor(this.getPrimaryColor() + '20')
          .borderRadius(16).height(32).layoutWeight(1)
          .onClick(() => this.createAndShufflePieces())

        Button('换图')
          .fontSize(13).fontColor('#FFFFFF')
          .backgroundColor(this.getPrimaryColor())
          .borderRadius(16).height(32).layoutWeight(1)
          .onClick(() => this.changeImage())
      }
      .width('100%')

      Column({ space: 4 }) {
        Text('拖动下方碎片到网格中还原图片').fontSize(12).fontColor('#333333')
        Text('绿框表示位置正确 · 红框表示位置错误').fontSize(11).fontColor('#666666')
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
      Column().width('100%').height('100%').backgroundColor('rgba(0, 0, 0, 0.7)')

      Column({ space: 16 }) {
        Image(this.getCurrentImageSrc())
          .width(200).height(200)
          .objectFit(ImageFit.Cover).borderRadius(12)
          .shadow({ radius: 16, color: 'rgba(0,0,0,0.4)', offsetY: 8 })

        Text('🎉 完成!').fontSize(22).fontWeight(FontWeight.Bold).fontColor(Color.White)
        Text(this.getCurrentImageName()).fontSize(18).fontColor(Color.White)

        Row({ space: 12 }) {
          Button('再来一局')
            .fontSize(13).fontColor(this.getPrimaryColor())
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
}
