/*------------------------------------------------------------------------------
AppDelegate.swift

Property
 window: NSWindow! (Outlet)
 view: UAView! (Outlet)
 comboLineWidth :NSComboBox! (Outlet)
 comboLinColor :NSComboBox! (Outlet)
 
Instance Method
 func applicationDidFinishLaunching(_:)
 func selectFile(_:)
 func lineWidth(_:)
 func lineColor(_:)
 func clear(_:)
 func createFile(_:)
------------------------------------------------------------------------------*/
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var view: UAView!
    @IBOutlet weak var comboLineWidth :NSComboBox!
    @IBOutlet weak var comboLinColor :NSComboBox!
 
    //--------------------------------------------------------------------------
    // アプリケーション開始時
    //--------------------------------------------------------------------------
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        comboLineWidth.selectItem(at: 0)
        self.view.lineWidth = 0
        comboLinColor.selectItem(at: 0)
    }
    //--------------------------------------------------------------------------
    // ファイルからイメージを読み込む
    //--------------------------------------------------------------------------
    @IBAction func selectFile(_ sender: NSButton){
        let openPanel = NSOpenPanel.init()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.message = "イメージファイルを選択する"
        let url = NSURL.fileURL(withPath: NSHomeDirectory() + "/Pictures")
        //最初に位置付けるディレクトリパス
        openPanel.directoryURL = url
        //オープンパネルを開く
        openPanel.beginSheetModal(for: self.window, completionHandler: { (result) in
            if result == .OK{
                //ディレクトリの選択
                let url: URL = openPanel.urls[0]
                /*
                if let nsImage = NSImage.init(contentsOf: url){
                    self.view.displayImage(image: nsImage)
                }
                */
                if let cgImageSource = CGImageSourceCreateWithURL(url as CFURL, nil){
                    if let cgImage = CGImageSourceCreateImageAtIndex(cgImageSource, 0, nil){
                        self.view.displayImage(image: cgImage)
                    }
                }
            }
        })
    }
    //--------------------------------------------------------------------------
    //線の太さを変える
    //--------------------------------------------------------------------------
    @IBAction func lineWidth(_ sender: NSComboBox){
        self.view.lineWidth = CGFloat(sender.indexOfSelectedItem)
    }
    //--------------------------------------------------------------------------
    //線の色を変える
    //--------------------------------------------------------------------------
    @IBAction func lineColor(_ sender: NSComboBox){
        self.view.setLineColor(sender.indexOfSelectedItem)
    }
    //--------------------------------------------------------------------------
    // 描画をクリアする
    //--------------------------------------------------------------------------
    @IBAction func clear(_ sender: NSButton){
        self.view.clearLines()
    }
    //--------------------------------------------------------------------------
    // イメージを出力する
    //--------------------------------------------------------------------------
    @IBAction func createFile(_ sender: NSButton){
        guard let data = self.view.createImageData() else{
            return
        }
        let savaPanel = NSSavePanel.init()
        savaPanel.title = "ファイルを保存する"
        savaPanel.nameFieldStringValue = "savefile.png"
        savaPanel.beginSheetModal(for: self.window, completionHandler: {(result) in
            if result == .OK{
                if let url = savaPanel.url{
                    do {
                        try data.write(to:url)
                    }catch{
                        print(error.localizedDescription)
                    }
                }
            }
        })
    }
}

