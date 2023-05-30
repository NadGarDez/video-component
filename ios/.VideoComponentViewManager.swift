@objc(VideoComponentViewManager)
class VideoComponentViewManager: RCTViewManager {

  override func view() -> (VideoComponentView) {
    let videoController = Sosem()
    videoController.setVideoUrl(url: "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4?_=1")
    let video = VideoComponentView()
      return videoController.view as! VideoComponentView
  }

  @objc override static func requiresMainQueueSetup() -> Bool {
    return false
  }
}

class VideoComponentView : UIView {

  @objc var color: String = "" {
    didSet {
      self.backgroundColor = hexStringToUIColor(hexColor: color)
    }
  }

  func hexStringToUIColor(hexColor: String) -> UIColor {
    let stringScanner = Scanner(string: hexColor)

    if(hexColor.hasPrefix("#")) {
      stringScanner.scanLocation = 1
    }
    var color: UInt32 = 0
    stringScanner.scanHexInt32(&color)

    let r = CGFloat(Int(color >> 16) & 0x000000FF)
    let g = CGFloat(Int(color >> 8) & 0x000000FF)
    let b = CGFloat(Int(color) & 0x000000FF)

    return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1)
  }

  override init(frame: CGRect) {
        
        super.init(frame: UIScreen.main.bounds)
        let label = UILabel()
        label.bounds = self.bounds
        label.center = CGPoint(x: self.frame.size.width  / 2,
                               y: self.frame.size.height / 2)
        label.textAlignment = .center
        label.text = "I'm a test label"

        self.addSubview(label)
        
    }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func onClose () {

  }

  /*

  func setupVideo() {
  
    self.addSubview(videoController)

  }
  */
}

class Sosem : UIViewController {
    
    private var open : Bool = false
   
    private var video:VideoController? = nil
    
    private var videoUrl: String?
    
    private func onClose () {
        print("hello world")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
      
        guard let url = URL(string:videoUrl ?? "") else { return }
        
        video = VideoController(viewController: self, url: url, onClose: self.onClose )
        // Do any additional setup after loading the view.
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        /*
        super.viewDidAppear(animated)
        video?.play()
         */
    }
    
    func setVideoUrl (url : String) {
        videoUrl = url
    }

}
