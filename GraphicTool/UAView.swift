/*------------------------------------------------------------------------------
UAView.swift
 
Struct
 LineAttribute
 
Property
 cgImage: CGImage?
 cgImageRect: CGRect
 lineAttrList: [LineAttribute]
 lineWidth: CGFloat
 rectShape: CAShapeLayer
 startPoint: CGPoint
 lineColor: CGColor
 
Instance Method
 override func draw(_:)
 override func awakeFromNib()
 override func mouseDown(with:)
 override func mouseDragged(with:)
 override func rightMouseDown(with:)
 override func rightMouseDragged(with:)
 func displayImage(image:)
 func createImageData()
 func clearLines()
------------------------------------------------------------------------------*/
import Cocoa
import QuartzCore
class UAView: NSView {
    //「線」構造体
    struct LineAttribute{
        var pointList: [CGPoint]    //点の集合
        var lineWidth: CGFloat      //線の太さ
        var lineColor: CGColor      //線の色
    }
    var cgImage: CGImage? = nil             //イメージファイルから読み込んだイメージ
    var cgImageRect = CGRect.init()         //イメージの縮小サイズ
    var lineAttrList = [LineAttribute]()    //「線」構造体の配列
    //線の太さ
    var lineWidth: CGFloat = 0{
        //メニューのインデックス値+1とする
        didSet{ lineWidth += 1 }
    }
    var rectShape = CAShapeLayer.init()                 //クリア領域の矩形
    var startPoint: CGPoint = CGPoint.init(x: 0, y: 0)  //クリア領域の開始点
    var lineColor: CGColor = NSColor.black.cgColor      //線の色
    
    //--------------------------------------------------------------------------
    // 線の色を変える
    //--------------------------------------------------------------------------
    func setLineColor(_ index: Int){
        switch index {
        case 1:
            lineColor = NSColor.white.cgColor
        case 2:
            lineColor = NSColor.red.cgColor
        default:
            lineColor = NSColor.black.cgColor
        }
    }
    //--------------------------------------------------------------------------
    // ビューの再描画・グラフィックコンテキストに直接書き出す
    //--------------------------------------------------------------------------
    override func draw(_ dirtyRect: NSRect) {
        if let context = NSGraphicsContext.current?.cgContext{
            if let image = self.cgImage{
                //イメージファイルのイメージを表示する
                context.draw(image, in: self.cgImageRect)
            }
            //線を描画する
            for i in 0 ..< lineAttrList.count{
                if lineAttrList[i].pointList.count < 2 {
                    continue //点が一つしかない
                }
                //点と点の間に線を引く
                for j in 0 ..< (lineAttrList[i].pointList.count - 1){
                    if lineAttrList[i].pointList.count > 1{
                        context.setLineWidth(lineAttrList[i].lineWidth)
                        context.setStrokeColor(lineAttrList[i].lineColor)
                        context.move(to: lineAttrList[i].pointList[j])
                        context.addLine(to: lineAttrList[i].pointList[j+1])
                        context.strokePath()
                    }
                }
            }
        }
    }
    //--------------------------------------------------------------------------
    // 初期処理・オブジェクトロード時
    //--------------------------------------------------------------------------
    override func awakeFromNib() {
        self.wantsLayer = true
        self.layer?.borderWidth = 1
        //トラッキングエリアの設定：補足したいイベントを指定する
        let options:NSTrackingArea.Options = [
            .mouseMoved,
            .mouseEnteredAndExited,
            .activeAlways
        ]
        let trackingArea = NSTrackingArea.init(rect: self.bounds,
                                               options: options,
                                               owner: self,
                                               userInfo: nil)
        self.addTrackingArea(trackingArea)
        self.rectShape.fillColor = NSColor.black.cgColor
        self.rectShape.opacity = 0.2
        self.layer?.addSublayer(self.rectShape)
    
    }
    //--------------------------------------------------------------------------
    // マウスダウン
    //--------------------------------------------------------------------------
    override func mouseDown(with event: NSEvent) {
        
        //1ラインの空オブジェクトを作成する
        let attr = LineAttribute(pointList: [CGPoint](),
                                 lineWidth: self.lineWidth,
                                 lineColor: self.lineColor)
        self.lineAttrList.append(attr)
        //クリア領域の消去
        let bezier = NSBezierPath.init(rect: NSZeroRect)
        self.rectShape.path = bezier.cgPath
    }
    //--------------------------------------------------------------------------
    // マウスドラッグ
    //--------------------------------------------------------------------------
    override func mouseDragged(with event: NSEvent) {
        let point = self.convert(event.locationInWindow, from: nil)
        //点を追加する
        self.lineAttrList[lineAttrList.count - 1].pointList.append(point)
        self.needsDisplay = true
        /****** 線を1ピクセルの長さに分割 too late
        var pointList = self.lineAttrList[lineAttrList.count - 1].pointList
        if pointList.count == 0{
            self.lineAttrList[lineAttrList.count - 1].pointList.append(point)
        }else{
            let fromPoint = pointList[pointList.count - 1]
            let xLen = pow((fromPoint.x - point.x), 2.0)
            let yLen = pow((fromPoint.y - point.y), 2.0)
            let length = sqrt(xLen + yLen)
            var unitPoint = CGPoint.init()
            unitPoint.x = (point.x - fromPoint.x) / length
            unitPoint.y = (point.y - fromPoint.y) / length
            
            var prePoint = fromPoint
            
            let intLength: Int = Int(length) //小数点以下切り捨て
            if intLength > 0{
                for _ in 0 ..< intLength - 1{
                    var newPoint = CGPoint.init()
                    newPoint.x = prePoint.x + unitPoint.x
                    newPoint.y = prePoint.y + unitPoint.y
                    self.lineAttrList[lineAttrList.count - 1].pointList.append(newPoint)
                    prePoint = newPoint
                }
            }
            self.lineAttrList[lineAttrList.count - 1].pointList.append(point)
         }
        ********/
    }
    //--------------------------------------------------------------------------
    // （右）マウスダウン
    //--------------------------------------------------------------------------
    override func rightMouseDown(with event: NSEvent) {
        startPoint = self.convert(event.locationInWindow, from: nil)
        //クリア領域の消去
        let bezier = NSBezierPath.init(rect: NSZeroRect)
        self.rectShape.path = bezier.cgPath
    }
    //--------------------------------------------------------------------------
    // （右）マウスドラッグ
    //--------------------------------------------------------------------------
    override func rightMouseDragged(with event: NSEvent) {

        let endPoint = self.convert(event.locationInWindow, from: nil)
        let width  = fabs(startPoint.x - endPoint.x)
        let height  = fabs(startPoint.y - endPoint.y)

        var xPos: CGFloat = 0.0;
        var yPos: CGFloat = 0.0;
        var flg: Bool = false;
        if startPoint.x < endPoint.x && startPoint.y < endPoint.y{
            xPos = startPoint.x
            yPos = startPoint.y
            //print("左下から右上")
            flg = true
        }
        if startPoint.x > endPoint.x && startPoint.y < endPoint.y{
            xPos = endPoint.x
            yPos = startPoint.y
            //print("右下から左上")
            flg = true
        }
        if startPoint.x > endPoint.x && startPoint.y > endPoint.y{
            xPos = endPoint.x
            yPos = endPoint.y
            //print("右上から左下")
            flg = true
        }
        if startPoint.x < endPoint.x && startPoint.y > endPoint.y{
            xPos = startPoint.x
            yPos = endPoint.y
            //print("左上から右下")
            flg = true
        }
        if !flg{
            return
        }
        //クリア領域の作成
        let rect = NSRect.init(origin: CGPoint.init(x: xPos, y: yPos),
                               size: CGSize.init(width: width, height: height))
        let bezier = NSBezierPath.init(rect: rect)
        self.rectShape.path = bezier.cgPath
    
    }
    //インスタンスメソッド
    //--------------------------------------------------------------------------
    // イメージの表示位置の計算
    //--------------------------------------------------------------------------
    func displayImage(image: CGImage){
        
        self.cgImage = image
        let maxSize = CGSize.init(width: self.frame.width, height: self.frame.height)
        var origin = CGPoint.init(x: 0, y: 0)
        
        var newSize = CGSize.init(width: 0, height: 0)
        if ( CGFloat(image.height) / CGFloat(image.width) < maxSize.height / maxSize.height) {
            //横長・上下に余白
            newSize.width = maxSize.width
            newSize.height = floor(maxSize.width * CGFloat(image.height) / CGFloat(image.width))
            origin.y = floor((maxSize.height - newSize.height) / 2) //余白
        }else{
            //縦長。左右に余白
            newSize.width = floor(maxSize.height * CGFloat(image.width) / CGFloat(image.height))
            newSize.height = maxSize.height
            origin.x = floor((maxSize.width - newSize.width) / 2) //余白
        }
        self.cgImageRect = CGRect.init(x: origin.x, y: origin.y,
                                       width: newSize.width, height: newSize.height)
        self.needsDisplay = true
    }
    
    //--------------------------------------------------------------------------
    // イメージファイル(png)の作成と出力
    //--------------------------------------------------------------------------
    func createImageData() -> Data?{
        //出力用コンテキストの作成
        let imageColorSpace = CGColorSpace(name: CGColorSpace.sRGB)
        guard let newContext = CGContext.init(
            data: nil,
            width: Int(self.frame.width),
            height: Int(self.frame.height),
            bitsPerComponent: 8,
            bytesPerRow: Int(self.frame.width) * 4,
            space: imageColorSpace!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else{
            return nil
        }
        //ビューイメージをコンテキストに描き出す
        self.layer!.render(in: newContext)
        //コンテキストからCGImageオブジェクトを取得する
        guard let cgImage = newContext.makeImage() else {
            return nil
        }
        //ビットマップイメージに変換する
        let bitmap = NSBitmapImageRep.init(cgImage: cgImage)
        //png形式のDataオブジェクトに変換する
        let exporttData = bitmap.representation(using: .png,
                                                properties: [:])
        return exporttData
    }
    //--------------------------------------------------------------------------
    // 描画した線のクリア
    //--------------------------------------------------------------------------
    func clearLines(){
        //self.lineAttrList = [LineAttribute]() //全部消去
        //クリア対象の点を特定する
        for i in 0 ..< lineAttrList.count{
            for j in 0 ..< lineAttrList[i].pointList.count{
                if let path = self.rectShape.path{
                    if path.boundingBox.isInside(lineAttrList[i].pointList[j]){
                        lineAttrList[i].pointList[j] = CGPoint.init(x: -1, y: -1)
                    }
                }                
            }
        }
        //線の集合の再作成
        var tempLineAttrList = [LineAttribute]()
        for line in lineAttrList{
            var tempPointList = [CGPoint]()
            for point in line.pointList{
                if point.x < 0 {
                    //クリアされた点があれば、そこまでの点で一つの線とする
                    if tempPointList.count > 0 {
                        var newLine = line
                        newLine.pointList = tempPointList
                        tempLineAttrList.append(newLine)
                        tempPointList = [CGPoint]()
                    }
                }else{
                    tempPointList.append(point)
                }
            }
            if tempPointList.count > 0 {
                var newLine = line
                newLine.pointList = tempPointList
                tempLineAttrList.append(newLine)
                tempPointList = [CGPoint]()
            }
        }
        lineAttrList = tempLineAttrList
        self.needsDisplay = true
    }
}


