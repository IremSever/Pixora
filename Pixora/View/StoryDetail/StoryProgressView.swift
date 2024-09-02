//
//  StoryProgressView.swift
//  TurkuvazSDK
//
//  Created by İrem Sever on 28.07.2024.
//

import Foundation
import UIKit

protocol SegmentedProgressBarDelegate: AnyObject {
    func segmentedProgressBarChangedIndex(index: Int)
    func segmentedProgressBarsFinished()
}

final class StoryProgressView: UIView {
    weak var delegate: SegmentedProgressBarDelegate?
    private var arrayBars: [UIProgressView] = []
    private var padding: CGFloat = 10.0
    private var leftRightSpace: CGFloat = 8.0
    private var hasDoneLayout = false
    private var currentAnimationIndex = 0
    private var timer: Timer?
    private var isPaused = false
    private var timerRunning = false
    private var storiesCompleted: [Bool] = []
    private var durations: [TimeInterval] = []
    
    
    init(arrayStories: Int, durations: [TimeInterval]) {
        super.init(frame: .zero)
        self.durations = durations
        for _ in 0..<arrayStories {
            let bar = UIProgressView()
            arrayBars.append(bar)
            addSubview(bar)
            storiesCompleted.append(false)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("INIT HASN'T BEEN IMPLEMENTED")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if hasDoneLayout { return }
        
        let barPadding = padding * CGFloat(arrayBars.count - 1)
        let leftSpace = leftRightSpace * 2
        let frameWidth = frame.width - barPadding - leftSpace
        let width = frameWidth / CGFloat(arrayBars.count)
        
        for (index, progressBar) in arrayBars.enumerated() {
            let segFrame = CGRect(x: (CGFloat(index) * (width + padding)) + leftRightSpace, y: 0, width: width, height: 20)
            progressBar.frame = segFrame
            progressBar.progress = 0.0
            progressBar.transform = progressBar.transform.scaledBy(x: 1, y: 1)
            progressBar.tintColor = .orange
            progressBar.backgroundColor = UIColor.white
            progressBar.layer.cornerRadius = progressBar.frame.height / 2
        }
        
        hasDoneLayout = true
    }
    
    func animate(index: Int) {
        resetCurrentProgress()
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.025, target: self, selector: #selector(updateProgressBar(_:)), userInfo: index, repeats: true)
        
        currentAnimationIndex = index
        for i in 0..<currentAnimationIndex {
            arrayBars[i].progress = 1.0
        }
    }
    
    private func resetCurrentProgress() {
        if currentAnimationIndex < arrayBars.count {
            arrayBars[currentAnimationIndex].progress = 0.0
        }
    }
    
    @objc private func updateProgressBar(_ timer: Timer) {
        guard let index = timer.userInfo as? Int else { return }
        
        let totalDuration: TimeInterval = durations[index]
        let timeInterval: TimeInterval = 0.025
        let progressIncrement = Float(timeInterval / totalDuration)
        
        if arrayBars[index].progress < 1.0 {
            arrayBars[index].progress += progressIncrement
        } else {
            timer.invalidate()
            storiesCompleted[index] = true
            delegate?.segmentedProgressBarsFinished()
        }
    }
    
    func pause() {
        if !isPaused {
            isPaused = true
            timer?.invalidate()
        }
    }
    
    func resume() {
        if isPaused {
            isPaused = false
            
            let remainingProgress = 1.0 - arrayBars[currentAnimationIndex].progress
            let remainingProgressAsDouble = Double(remainingProgress)
            let remainingDuration = remainingProgressAsDouble * durations[currentAnimationIndex]
            
            timer = Timer.scheduledTimer(timeInterval: 0.025, target: self, selector: #selector(updateProgressBar(_:)), userInfo: currentAnimationIndex, repeats: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + remainingDuration) {
                if self.arrayBars[self.currentAnimationIndex].progress >= 1.0 {
                    self.timer?.invalidate()
                    self.storiesCompleted[self.currentAnimationIndex] = true
                    self.delegate?.segmentedProgressBarsFinished()
                }
            }
        }
    }

    func resetBar() {
        for progressBar in arrayBars {
            progressBar.progress = 0.0
        }
        
        timer?.invalidate()
        timer = nil
        timerRunning = false
        currentAnimationIndex = 0
        isPaused = false
    }
    
    func rewind() {
        isPaused = false
        guard currentAnimationIndex > 0 else { return }
        
        let newIndex = currentAnimationIndex - 1
        timer?.invalidate()
        timer = nil
        arrayBars[currentAnimationIndex].progress = 0.0
        arrayBars[newIndex].progress = 0.0
        currentAnimationIndex = newIndex
        
        for i in 0..<newIndex {
            arrayBars[i].progress = 1.0
        }
        
        resetBar()
        animate(index: newIndex)
        delegate?.segmentedProgressBarChangedIndex(index: newIndex)
    }
    
    func skip() {
        isPaused = false
        
        guard currentAnimationIndex < arrayBars.count - 1 else { return }
        
        let newIndex = currentAnimationIndex + 1
        timer?.invalidate()
        timer = nil
        arrayBars[currentAnimationIndex].progress = 1.0
        currentAnimationIndex = newIndex
        
        for i in 0..<newIndex {
            arrayBars[i].progress = 1.0
        }
        
        resetBar()
        animate(index: newIndex)
        delegate?.segmentedProgressBarChangedIndex(index: newIndex)
    }
}
