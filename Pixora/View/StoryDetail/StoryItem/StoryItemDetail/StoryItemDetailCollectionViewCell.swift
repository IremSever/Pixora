//
//  StoryItemDetailCollectionViewCell.swift
//  Pixora
//
//  Created by İrem Sever on 2.09.2024.
//

import UIKit
import AVKit
class StoryItemDetailCollectionViewCell: UICollectionViewCell, VideoPlayerViewDelegate {
    
    @IBOutlet weak var collectionViewStoryItemDetail: UICollectionView!
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var imgStory: UIImageView!
    
    @IBOutlet weak var viewBg: UIView!
    
    @IBOutlet weak var paddingBgRight: NSLayoutConstraint!
    @IBOutlet weak var paddingBgLeft: NSLayoutConstraint!
    @IBOutlet weak var paddingBgBottom: NSLayoutConstraint!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var imgGradient: UIImageView!
    @IBOutlet weak var lblSpot: UILabel!
   
    private var gradientLayer: CAGradientLayer?
        
        var videoPlayerView: VideoPlayerView? {
            return viewVideo.subviews.first(where: { $0 is VideoPlayerView }) as? VideoPlayerView
        }
    
        public override func awakeFromNib() {
            super.awakeFromNib()
            paddingBgRight.constant = 0
            paddingBgLeft.constant = 0
            paddingBgBottom.constant = 0
            
            addGradientShadow()
        }
        
        func configure(with story: StoryDetail) {
            lblTitle?.text = story.title
            lblSpot?.text = story.spot

            
            if let imageName = story.image, !imageName.isEmpty {
                imgStory.isHidden = false
                viewVideo.isHidden = true
                imgStory.image = UIImage(named: imageName)
                videoPlayerView?.pauseVideo()
                videoPlayerView?.removeFromSuperview()
            } else if let videoURLString = story.video, !videoURLString.isEmpty, let videoURL = URL(string: videoURLString) {
                imgStory.isHidden = true
                viewVideo.isHidden = false
                videoPlayerView?.removeFromSuperview()
                let videoPlayer = VideoPlayerView(frame: viewVideo.bounds, url: videoURL, delegate: self)
                viewVideo.addSubview(videoPlayer)
                videoPlayer.playVideo()
            } else {
                imgStory.isHidden = true
                viewVideo.isHidden = true
            }
        }
        
        public override func prepareForReuse() {
            super.prepareForReuse()
            imgStory?.image = nil
            lblTitle?.text = nil
            lblSpot?.text = nil
            videoPlayerView?.pauseVideo()
            videoPlayerView?.removeFromSuperview()
        }

        private func addGradientShadow() {
            gradientLayer?.removeFromSuperlayer()
            gradientLayer = CAGradientLayer()
            gradientLayer?.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.9).cgColor]
            gradientLayer?.locations = [0.0, 1.0]
            gradientLayer?.frame = viewBg.bounds
            imgGradient.layer.insertSublayer(gradientLayer!, at: 0)
        }
        
        public override func layoutSubviews() {
            super.layoutSubviews()
            gradientLayer?.frame = imgGradient.bounds
            videoPlayerView?.frame = viewVideo.bounds
        }
        
        func videoLoaded() {
            print("**************************VIDEO IS LOADED*********************************")
        }
    }




