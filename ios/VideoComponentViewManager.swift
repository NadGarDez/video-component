
import Foundation
import UIKit
import AVFoundation
import AVKit


@objc(VideoComponentViewManager)
class VideoComponentViewManager: RCTViewManager {

  override func view() -> (VideoComponentView) {
    let video = VideoComponentView()
    return video
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

  var _urlVideo  : String = ""

  @objc var source: NSString = "" {
    didSet {
      _urlVideo = source as String
    }
  }




  weak var viewController: UIViewController?

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
        
    }
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    func onClose () {

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if viewController == nil {
            embed()
        } else {
            viewController?.view.frame = bounds
        }
    }

    private func embed () {
      guard
            let parentVC = parentViewController else {
            return
      }
      
      if(_urlVideo.count > 0){
        let currentViewController = VideoViewController()
        currentViewController.setVideoUrl(url:_urlVideo)
        parentVC.addChild(currentViewController)
        addSubview(currentViewController.view)
        currentViewController.view.frame = bounds
        self.viewController = currentViewController
      }
      
    }
}

extension UIView {
  var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

class VideoViewController : UIViewController {
    
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
        
        video = VideoController()
        video?.setupValues(viewController: self, url: url, onClose: self.onClose)
        self.view.addSubview(video!)
      
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        video?.play()
    }
    
    func setVideoUrl (url : String) {
        videoUrl = url
    }

}


class VideoController : UIView {
    
    private var viewController: UIViewController? = nil
    
    private var player:AVPlayer? = nil
    private var onClose:(()->Void?)? = nil
   
    private lazy var playerController: AVPlayerViewController = {
            let playerController = AVPlayerViewController()
            playerController.player = player
            playerController.delegate = self
            playerController.allowsPictureInPicturePlayback = true
            return playerController
    }()
    override init (frame: CGRect){

        super.init(frame: frame)
    }


    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupValues (viewController: UIViewController,  url : URL , onClose : @escaping () -> Void) {
      self.viewController = viewController

        self.player = AVPlayer(url : url)
        self.onClose = onClose
    }

    func mount (){
      self.viewController?.addChild(playerController)
      self.addSubview(self.playerController.view)
      player?.play()
    }

    func play () {
        player?.play()
        viewController?.present(playerController, animated: true, completion: nil)
    }
    
    
}


// MARK: - AVPlayerViewControllerDelegate -
extension VideoController: AVPlayerViewControllerDelegate {
    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }
    
    func playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart(_ playerViewController: AVPlayerViewController) -> Bool {
        return false
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
       // self.onClose()
    }
}
 
