
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

  @objc var onCloseVideo : RCTDirectEventBlock?


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
        
        super.init(frame: frame)
        
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

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview != nil {
            self.frame = newSuperview!.bounds
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
        currentViewController.setOnClose(onCloseCallback: onCloseVideo)
        parentVC.addChild(currentViewController)
        addSubview(currentViewController.view)
        currentViewController.view.frame = bounds
        self.viewController = currentViewController
      }
      else {
        // some error
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
   
    private var video:VideoViewAndController? = nil
    
    private var videoUrl: String?

    private var onCloseVideo : RCTDirectEventBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black

        guard let url = URL(string:videoUrl ?? "") else { return }
        
        video = VideoViewAndController()
        video?.setupValues(viewController: self, url: url, onClose: self.onCloseVideo)
        self.view.addSubview(video!)
      
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        video?.play()
    }
    
    func setVideoUrl (url : String) {
        videoUrl = url
    }

    func setOnClose ( onCloseCallback : RCTDirectEventBlock?) {
      if let onCloseCallback = onCloseCallback {
        onCloseVideo = onCloseCallback
      }
    }

}


class VideoViewAndController : UIView {
    
    private var viewController: UIViewController? = nil
    
    private var player:AVPlayer? = nil
    private var onClose:RCTDirectEventBlock?
   
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

    func setupValues (viewController: UIViewController,  url : URL , onClose : RCTDirectEventBlock?) {
      self.viewController = viewController

        self.player = AVPlayer(url : url)

        if let onClose = onClose {
          self.onClose = onClose
        }
        
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
extension VideoViewAndController: AVPlayerViewControllerDelegate {
    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }
    
    func playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart(_ playerViewController: AVPlayerViewController) -> Bool {
        return false
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
      if let callback = self.onClose {
        let event = [AnyHashable: Any]()
        callback(event)
      }
    }
}
 
 /*


class Video : UIView, AVPictureInPictureControllerDelegate {
    
    var videoPlayer = AVPlayer()
    var playerLayer:AVPlayerLayer?


    private var viewController: UIViewController? = nil
    private var onClose:RCTDirectEventBlock?


    var videoUrl: String?
    var item:AVPlayerItem?
    private var statusContext = UnsafeMutableRawPointer(bitPattern: 0)
    var timer:Timer?
    
    var pipController: AVPictureInPictureController!
    var pipPossibleObservation: NSKeyValueObservation?
    var loadIndicator: UIActivityIndicatorView!
    // buttons
    
    var pictureInPictureButton:UIButton?
    var progressBar:UIProgressView?
    var stopPlayButton:UIButton?
    
    var buttonsView: UIView?

    // pip image
    
    let active = AVPictureInPictureController.pictureInPictureButtonStopImage
    let unactive = AVPictureInPictureController.pictureInPictureButtonStopImage
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview != nil {
            self.frame = newSuperview!.bounds
            setupVideo(newSuperview!.bounds)
            setupBar(newSuperview!.bounds)
        }
    }
   
    
    func getSuperViewBounds(view:UIView)->CGRect {
        let parent = view.superview
        print(parent as Any, "hey")
        if parent == nil {
            print("uno")
            return view.bounds
        } else {
            print("dos")
            return parent!.bounds
        }
    }
    */
    
    func play(){
        videoPlayer.play()
    }
    
    
    @IBAction func setPictureInPicture(_ sender: UIButton) {
        if pipController.isPictureInPictureActive {
            pipController.stopPictureInPicture()
        } else {
            pipController.startPictureInPicture()
            self.isHidden = true
        }
    }

    func getBarWidth () -> CGFloat {
        if(self.pictureInPictureButton?.isHidden == true) {
            return 0.13
        }
        else {
            
            return 0.2
        }
    }


    func setupPictureInPicture() {
       
        if AVPictureInPictureController.isPictureInPictureSupported() {
           
            pipController = AVPictureInPictureController(playerLayer: playerLayer!)
            pipController.delegate = self


            pipPossibleObservation = pipController.observe(\AVPictureInPictureController.isPictureInPicturePossible,
options: [.initial, .new]) { [weak self] _, change in
                
                self?.pictureInPictureButton?.isEnabled = change.newValue ?? false
            }
        } else {
            pictureInPictureButton?.isHidden = true
        }
    }
    
    func setupVideo( _ parent_bounds: CGRect, url : String){
        videoUrl = "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4"
        item = AVPlayerItem(url:URL(string: videoUrl!)!)
        videoPlayer.replaceCurrentItem(with: item)
        
        playerLayer = AVPlayerLayer(player: videoPlayer)
        playerLayer?.frame = parent_bounds
       // playerLayer?.player!.addObserver(self, forKeyPath: "status", options: [.new, .old], context: nil)
       // self.layer.addSublayer(playerLayer!)
    }
    
    func setupBar( _ parent_bounds: CGRect){
        
        buttonsView = UIView(frame: CGRect(x: 0, y: parent_bounds.height - 70, width: parent_bounds.width, height: 70))
       // addSubview(buttonsView!)
        
        // picture in picture button
        pictureInPictureButton = UIButton()
        pictureInPictureButton!.translatesAutoresizingMaskIntoConstraints = false
        pictureInPictureButton?.setImage(active, for: .normal)
        pictureInPictureButton?.setImage(unactive, for: .selected)
        pictureInPictureButton?.addTarget(self, action: #selector(setPictureInPicture), for: .touchUpInside)
        self.setupPictureInPicture()
        buttonsView!.addSubview(pictureInPictureButton!)
        NSLayoutConstraint.activate([
            pictureInPictureButton!.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            pictureInPictureButton!.centerYAnchor.constraint(equalTo: buttonsView!.centerYAnchor , constant: 0),
        ])

        // progress bar
        
        progressBar = UIProgressView(frame: CGRect(x: buttonsView!.bounds.width*0.10, y: (buttonsView!.bounds.height - 3) / 2, width: buttonsView!.bounds.width - (bounds.width * getBarWidth()), height:1))
        progressBar!.layer.backgroundColor = UIColor.black.cgColor
        progressBar?.progress = 0.0
        progressBar?.layer.opacity = 0.7
        buttonsView!.addSubview(progressBar!)

        
        // progressBar?.addTarget(self, action: #selector(seek), for: .valueChanged)
        
        
        //play stop button
        
        stopPlayButton = UIButton(type: .custom)
        stopPlayButton!.setImage(UIImage(systemName: "stop"), for: .normal)
        stopPlayButton!.translatesAutoresizingMaskIntoConstraints = false
        stopPlayButton?.isHidden = true
        buttonsView!.addSubview(stopPlayButton!)
        
        stopPlayButton?.addTarget(self, action: #selector(stopStart), for: .touchUpInside)

        NSLayoutConstraint.activate([
            stopPlayButton!.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            stopPlayButton!.centerYAnchor.constraint(equalTo: buttonsView!.centerYAnchor, constant: 0),
        ])
        
        videoPlayer.addObserver(self, forKeyPath: "timeControlStatus", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.videoDidFinish), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem)
        
        // load indicator
        loadIndicator = UIActivityIndicatorView(style: .medium)
        loadIndicator.color = .blue
        loadIndicator.translatesAutoresizingMaskIntoConstraints = false
        buttonsView!.addSubview(loadIndicator)
        NSLayoutConstraint.activate([
            loadIndicator!.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            loadIndicator!.centerYAnchor.constraint(equalTo: buttonsView!.centerYAnchor, constant: 0),
        ])
    
        loadIndicator.startAnimating()
      //  toggleBar(visible: false)
    }
    
    func toggleBar(visible: Bool){
        buttonsView?.isHidden = !visible
        loadIndicator.isHidden = !visible
        if AVPictureInPictureController.isPictureInPictureSupported(){
            pictureInPictureButton?.isHidden = !visible
        }
        stopPlayButton?.isHidden = !visible
        progressBar?.isHidden = !visible
    }
    
    @objc private func seek(sender: UISlider){
        let durationInMilliseconds = Float(getMillisecondsFromCMTime((videoPlayer.currentItem?.duration)!))
        let timeToSeekInMilliseconds = (sender.value * durationInMilliseconds)
        videoPlayer.seek(to: getCMTimeFromMilliseconds(Int(timeToSeekInMilliseconds)))
    }
    
    func updateProgressBar(){
        
        if loadIndicator.isAnimating == true {
            loadIndicator.stopAnimating()
        }
        
        if stopPlayButton?.isHidden == true {
            stopPlayButton?.isHidden = false
        }
       
        guard let player = playerLayer?.player else { return }
        if player.rate == 1 && player.currentItem?.duration != nil {
            let currentTime = getMillisecondsFromCMTime(player.currentTime())
            let duration = getMillisecondsFromCMTime(player.currentItem!.duration)
            if duration != 0 {
                let percent = (currentTime * 100) / duration
                progressBar!.progress = Float(percent)/100
            }
            
        }
    }
    
    @objc func videoDidFinish(){
        self.progressBar?.progress = 1
    }
    
    
    
    @objc func stopStart(){
        if videoPlayer.rate == 1 {
            videoPlayer.pause()
            stopPlayButton?.setImage(UIImage(systemName: "play"), for: .normal)
        }
        else {
            videoPlayer.play()
            stopPlayButton?.setImage(UIImage(systemName: "stop"), for: .normal)
        }
    }
    
    func getMillisecondsFromCMTime(_ cmTime: CMTime) -> Int {
        let seconds = CMTimeGetSeconds(cmTime)
        if !seconds.isNaN {
            let milliseconds = Int(seconds * 1000)
            return milliseconds
        } else {
            return 0
        }
    }
    
    func getCMTimeFromMilliseconds(_ milliseconds: Int, timescale: Int32 = 1000) -> CMTime {
        let seconds = Double(milliseconds / 1000)
        let cmTime = CMTime(seconds: seconds, preferredTimescale: timescale)
        return cmTime
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus" {
            let timeStatus  = AVPlayer.TimeControlStatus(rawValue: change![.newKey] as! Int)!
            switch timeStatus {
                case .paused:
                    self.updateProgressBar()
                    self.stopLoop()
                case .waitingToPlayAtSpecifiedRate:break
                case .playing:
                    self.updateProgressBar()
                    self.startLoop()
                   
                @unknown default: break
            }
        }
        
    }
    
    private func startLoop(){
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            self.updateProgressBar()
        }
    }
    
    private func stopLoop(){
        timer?.invalidate()
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        self.isHidden = false
    }

    func setupValues (viewController: UIViewController,  url : URL , onClose : RCTDirectEventBlock?) {


        self.viewController = viewController

        self.player = AVPlayer(url : url)

        if let onClose = onClose {
          self.onClose = onClose
        }

        self.setupVideo()

        
    }

    func mount (){
      self.viewController?.addChild(playerController)
      self.addSubview(self.playerController.view)
      player?.play()
    }
    
}


*/