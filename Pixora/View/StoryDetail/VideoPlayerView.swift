//
//  VideoPlayerView.swift
//  TurkuvazSDK
//
//  Created by İrem Sever on 12.08.2024.
//

import Foundation
import AVKit

protocol VideoPlayerViewDelegate: AnyObject {
    func videoLoaded()
}

final class VideoPlayerView: UIView {
    private let timeObserverKeyPath: String = "timeControlStatus"
    private var avPlayer: AVPlayer?
    private var avLayer: AVPlayerLayer?
    private weak var delegate: VideoPlayerViewDelegate?
    
    func getPlayerDuration() -> TimeInterval? {
        return avPlayer?.currentItem?.duration.seconds
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avLayer?.frame = self.bounds
    }
    
    init(frame: CGRect, url: URL, delegate: VideoPlayerViewDelegate) {
        super.init(frame: frame)
        self.delegate = delegate
        
        avPlayer = AVPlayer(url: url)
        guard let vplayer = avPlayer else { return }
        
        avLayer = AVPlayerLayer(player: vplayer)
        avLayer?.videoGravity = .resizeAspectFill
        guard let vl = avLayer else { return }
        layer.addSublayer(vl)
        
        avPlayer?.addObserver(self, forKeyPath: timeObserverKeyPath, options: [.old, .new], context: nil)
        vplayer.play()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        if avPlayer?.observationInfo != nil {
            NotificationCenter.default.removeObserver(self)
        }
        avPlayer?.pause()
        avLayer?.player = nil
        avLayer?.removeFromSuperlayer()
        avPlayer = nil
        avLayer = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let avPlayer = avPlayer, avPlayer.observationInfo != nil else { return }
        
        if keyPath == timeObserverKeyPath,
           let change = change,
           let newValue = change[NSKeyValueChangeKey.newKey] as? Int,
           let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                if newStatus == .playing {
                    avPlayer.seek(to: .zero)
                    avPlayer.removeObserver(self, forKeyPath: timeObserverKeyPath)
                    delegate?.videoLoaded()
                }
            }
        }
    }
    
    func playVideo() {
        avPlayer?.play()
    }
    
    func pauseVideo() {
        avPlayer?.pause()
    }
}
