//
//  StoryDetailVC.swift
//  Pixora
//
//  Created by İrem Sever on 2.09.2024.
//

import UIKit
import Combine

class StoryDetailVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, StoryPreviewProtocol, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionViewStoryDetail: UICollectionView!
//    private let viewModel = StoryViewModel()
//        var selectedIndex: Int = 0
//        var storyResponse: [StoryResponse] = []
//        
//        private var isTransitioning = false
//    
//     private var initialY: CGFloat = 0
//     private let threshold: CGFloat = 50
    private let viewModel = StoryViewModel()
    var selectedIndex: Int = 0
    private var initialY: CGFloat = 0
    private let threshold: CGFloat = 50
    private var isTransitioning = false
   
 
        override func viewDidLoad() {
            super.viewDidLoad()

            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            collectionViewStoryDetail.collectionViewLayout = layout
            collectionViewStoryDetail.delegate = self
            collectionViewStoryDetail.dataSource = self
            collectionViewStoryDetail.isPagingEnabled = true
            
            registerCell()
            loadData()
            setupPanGesture()
        }
    
    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        let yOffset = translation.y
        
        if gesture.state == .began {
            initialY = view.frame.origin.y
        } else if gesture.state == .changed {
            let newY = initialY + yOffset
            if newY > 0 {
                view.frame.origin.y = newY
                view.alpha = 1 - (yOffset / view.frame.height) //opacity
            }
        } else if gesture.state == .ended {
            if yOffset > threshold || velocity.y > 500 {
                dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin.y = self.initialY
                    self.view.alpha = 1.0
                }
            }
        }
    }
    
    
    func loadData() {
        viewModel.parseJSON(resourceName: "app") { [weak self] success in
            DispatchQueue.main.async {
                self?.collectionViewStoryDetail.reloadData()
                self?.scrollToSelectedStory()
            }
        }
    }


        func registerCell() {
            collectionViewStoryDetail.register(UINib(nibName: "StoryItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StoryItemCollectionViewCell")
        }
    
    
    func scrollToSelectedStory() {
        guard selectedIndex >= 0 && selectedIndex < viewModel.storyData.count else {
            return
        }
        
        let indexPath = IndexPath(item: selectedIndex, section: 0)
        collectionViewStoryDetail.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.storyData.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryItemCollectionViewCell", for: indexPath) as? StoryItemCollectionViewCell else {
            fatalError("Unable to dequeue StoryItemCollectionViewCell")
        }
        let story = viewModel.cellForRowAt(indexPath: indexPath)
        cell.configure(with: story)
        cell.storyPreviewDelegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionViewStoryDetail.frame.size
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isTransitioning else { return }

        let currentOffset = scrollView.contentOffset.x
        let pageWidth = scrollView.frame.width
        let fractionalPage = currentOffset / pageWidth

        let targetIndex = selectedIndex + (fractionalPage > CGFloat(selectedIndex) ? 1 : -1)
        
        if fractionalPage > CGFloat(selectedIndex) && fractionalPage - CGFloat(selectedIndex) >= 1/3 && targetIndex < viewModel.storyData.count {
            isTransitioning = true
            selectedIndex += 1
            performCubeTransition(toNext: true)
        } else if fractionalPage < CGFloat(selectedIndex) && CGFloat(selectedIndex) - fractionalPage >= 1/3 && targetIndex >= 0 {
            isTransitioning = true
            selectedIndex -= 1
            performCubeTransition(toNext: false)
        }
    }
       
    func performCubeTransition(toNext: Bool) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType(rawValue: "cube")
        transition.subtype = toNext ? .fromRight : .fromLeft

        collectionViewStoryDetail.layer.add(transition, forKey: "cubeTransition")
        
        let indexPath = IndexPath(item: selectedIndex, section: 0)
        collectionViewStoryDetail.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        
        if let cell = collectionViewStoryDetail.cellForItem(at: indexPath) as? StoryItemCollectionViewCell {
            cell.storyProgressView?.resetBar()
            cell.startProgress()
        }
        
        collectionViewStoryDetail.reloadData()
        isTransitioning = false
    }
     
    func didStoryViewEnd() {
        if selectedIndex < viewModel.storyData.count - 1 {
            selectedIndex += 1
            performCubeTransition(toNext: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func didMoveToPreviousStory() {
        if selectedIndex > 0 {
            selectedIndex -= 1
            performCubeTransition(toNext: false)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
        

    }
