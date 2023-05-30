//
//  VideoController2.swift
//  VideoComponent
//
//  Created by Nad on 29/5/23.
//  Copyright © 2023 Facebook. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

final class VideoController : UIView {
    
    private var viewController: UIViewController
    private let player:AVPlayer
    private var onClose: ()->Void
    
    private lazy var playerController: AVPlayerViewController = {
            let playerController = AVPlayerViewController()
            playerController.player = player
            playerController.delegate = self
            playerController.allowsPictureInPicturePlayback = true
            return playerController
    }()
    
    init ( url : URL , onClose : @escaping () -> Void){
        self.viewController = viewController
        self.player = AVPlayer(url : url)
        self.onClose = onClose
        super.init()
        /*
        self.viewController.addChild(playerController)
        self.addSubview(self.playerController.view)
        */
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDelegate(delegate: AVPlayerViewControllerDelegate){
        playerController.delegate = delegate
    }
    func play () {
        player.play()
        viewController.present(playerController, animated: false, completion: nil)
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
        self.onClose()
    }
}
 
