//
//  StoryItemCollectionViewCell.swift
//  Pixora
//
//  Created by İrem Sever on 2.09.2024.
//

import UIKit
import Foundation

protocol StoryPreviewProtocol: AnyObject {
    func didStoryViewEnd()
    func didMoveToPreviousStory()
}

class StoryItemCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, SegmentedProgressBarDelegate {
    
    
    @IBOutlet weak var lblUsername: UILabel!
  
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var stackViewProgress: UIStackView!
 
    
    @IBOutlet weak var storyItemCollectionView: UICollectionView!
    
    var storyPreviewDelegate: StoryPreviewProtocol?
    var storyDetail: [StoryDetail] = []
    var currentStoryIndex: Int = 0
    var storyProgressView: StoryProgressView?
    private var videoPlayerView: VideoPlayerView?
    private var longGesture: UILongPressGestureRecognizer!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        registerCell()
        setupCollectionView()
        setupGestureRecognizers()
    }
    
    func startProgress(fromEnd: Bool = false) {
        if fromEnd {
            currentStoryIndex = storyDetail.count - 1
        }
        storyProgressView?.resetBar()
        storyProgressView?.animate(index: currentStoryIndex)
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        storyItemCollectionView.setCollectionViewLayout(layout, animated: false)
        storyItemCollectionView.delegate = self
        storyItemCollectionView.dataSource = self
        storyItemCollectionView.isPagingEnabled = true
        storyItemCollectionView.isScrollEnabled = false
    }
    
    func registerCell() {
        storyItemCollectionView.register(UINib(nibName: "StoryItemDetailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StoryItemDetailCollectionViewCell")
    }
    
    
    func configure(with story: StoryResponse) {
        lblUsername.text = story.user
        lblUsername.textColor = UIColor(red: 242/255, green: 242/255, blue: 243/255, alpha: 1.0)
        imgUser.image = UIImage(named: story.userImage)
        imgUser.layer.cornerRadius = imgUser.frame.size.width / 2
        imgUser.clipsToBounds = true
        self.storyDetail = story.storyDetails
        let durations = storyDetail.compactMap { storyDetail -> TimeInterval? in
            if let videoDurationString = storyDetail.videoDuration, let duration = TimeInterval(videoDurationString) {
                return duration
            } else {
                return 10.0
            }
        }
        storyItemCollectionView.reloadData()
        setupStoryProgressView(durations: durations)
        
    }

    private func setupStoryProgressView(durations: [TimeInterval]) {
        storyProgressView?.removeFromSuperview()
        storyProgressView = StoryProgressView(arrayStories: storyDetail.count, durations: durations)
        storyProgressView?.delegate = self
//        storyProgressView?.frame = stackViewProgress.bounds
//        stackViewProgress.addSubview(storyProgressView!)
        storyProgressView?.animate(index: currentStoryIndex)
    }

    
    private func setupStoryProgressView() {
            storyProgressView?.removeFromSuperview()
            let durations = storyDetail.compactMap { story -> TimeInterval? in
                if let videoDurationString = story.videoDuration, let duration = TimeInterval(videoDurationString) {
                    return duration
                } else {
                    return 10.0
                }
            }
            storyProgressView = StoryProgressView(arrayStories: storyDetail.count, durations: durations)
            storyProgressView?.delegate = self
            storyProgressView?.frame = stackViewProgress.bounds
            stackViewProgress.addSubview(storyProgressView!)
            storyProgressView?.animate(index: currentStoryIndex)
        }
    
    func segmentedProgressBarChangedIndex(index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        storyItemCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        currentStoryIndex = index
    }
    
    
    
    func segmentedProgressBarsFinished() {
        if currentStoryIndex < storyDetail.count - 1 {
            currentStoryIndex += 1
            storyProgressView?.animate(index: currentStoryIndex)
            
            let indexPath = IndexPath(item: currentStoryIndex, section: 0)
            storyItemCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            storyItemCollectionView.layoutIfNeeded()
            
            if let cell = storyItemCollectionView.cellForItem(at: indexPath) as? StoryItemDetailCollectionViewCell {
                cell.videoPlayerView?.playVideo()
            }
        } else {
            storyPreviewDelegate?.didStoryViewEnd()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storyDetail.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryItemDetailCollectionViewCell", for: indexPath) as? StoryItemDetailCollectionViewCell else {
            fatalError("Unable to dequeue StoryItemDetailCollectionViewCell")
        }
        
        let storyDetail = self.storyDetail[indexPath.item]
        cell.configure(with: storyDetail)
        return cell
    }

    
    override func prepareForReuse() {
        super.prepareForReuse()
        storyProgressView?.resetBar()
        currentStoryIndex = 0
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return storyItemCollectionView.frame.size
    }
    
    
    
    private func setupGestureRecognizers() {
        //pause
        longGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongGesture))
        longGesture.minimumPressDuration = 0.2
        longGesture.delegate = self
        self.addGestureRecognizer(longGesture)
        
        //previous
        let leftTap = UITapGestureRecognizer(target: self, action: #selector(didTapLeftSide))
        leftTap.delegate = self
        leftTap.cancelsTouchesInView = false
        leftTap.numberOfTapsRequired = 1
        
        //next
        let rightTap = UITapGestureRecognizer(target: self, action: #selector(didTapRightSide))
        rightTap.delegate = self
        rightTap.cancelsTouchesInView = false
        rightTap.numberOfTapsRequired = 1
        
        let leftSwipeArea = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width / 2, height: self.bounds.height))
        let rightSwipeArea = UIView(frame: CGRect(x: self.bounds.width / 2, y: 0, width: self.bounds.width / 2, height: self.bounds.height))
        
        leftSwipeArea.addGestureRecognizer(leftTap)
        rightSwipeArea.addGestureRecognizer(rightTap)
        
        addSubview(leftSwipeArea)
        addSubview(rightSwipeArea)
    }
    
    @objc private func didTapLeftSide() {
        if currentStoryIndex > 0 {
            currentStoryIndex -= 1
            storyProgressView?.rewind()
            pauseCurrentVideo()
        } else {
            storyPreviewDelegate?.didMoveToPreviousStory()
        }
    }

    @objc private func didTapRightSide() {
        if currentStoryIndex < storyDetail.count - 1 {
            currentStoryIndex += 1
            storyProgressView?.skip()
            pauseCurrentVideo()
        } else {
            storyPreviewDelegate?.didStoryViewEnd()
        }
    }
    
    private func playCurrentVideo() {
        if let visibleCell = storyItemCollectionView.visibleCells.first as? StoryItemDetailCollectionViewCell {
            visibleCell.videoPlayerView?.playVideo()
        }
    }
    private func pauseCurrentVideo() {
        if let visibleCell = storyItemCollectionView.visibleCells.first as? StoryItemDetailCollectionViewCell {
            visibleCell.videoPlayerView?.pauseVideo()
        }
    }
    
    @objc private func didLongGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            pauseCurrentVideo()
            storyProgressView?.pause()
        case .ended, .cancelled, .failed:
            playCurrentVideo()
            storyProgressView?.resume()
        default:
            break
        }
    }
    
    
    @IBAction func buttonExit(_ sender: Any) {
        if let parentVC = self.window?.rootViewController?.presentedViewController as? StoryDetailVC {
            parentVC.dismiss(animated: true, completion: nil)
        }
    }
}

extension StoryItemCollectionViewCell: VideoPlayerViewDelegate {
    func videoLoaded() {
        storyProgressView?.resume()
        self.addGestureRecognizer(longGesture)
    }
}
