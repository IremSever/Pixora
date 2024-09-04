//
//  ViewController.swift
//  Pixora
//
//  Created by İrem Sever on 2.09.2024.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var userCollectionView: UICollectionView!
    
    var storyResponse: [StoryResponse] = []
    private let viewModel = StoryViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        userCollectionView.dataSource = self
        userCollectionView.delegate = self
        userCollectionView.isPagingEnabled = true
        
        registerCell()
        loadStoryDetails()
    }
    
    private func registerCell() {
        userCollectionView.register(UINib(nibName: "UserCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "UserCollectionViewCell")
    }
    
    private func loadStoryDetails() {
        viewModel.parseJSON(resourceName: "app") { [weak self] success in
            guard let self = self, success else { return }
            
            self.storyResponse = self.viewModel.storyData
            
            DispatchQueue.main.async {
                self.userCollectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storyResponse.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCollectionViewCell", for: indexPath) as? UserCollectionViewCell else {
            fatalError("Unable to dequeue UserCollectionViewCell")
        }
        
        let story = storyResponse[indexPath.item]
        cell.configure(with: story)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedStory = storyResponse[indexPath.item]
        
        print("Selected index: \(indexPath.item)")
        
        let storyDetailVC = StoryDetailVC(nibName: "StoryDetailVC", bundle: nil)
        
        storyDetailVC.selectedStory = selectedStory
        storyDetailVC.selectedIndex = indexPath.item
        storyDetailVC.modalPresentationStyle = .fullScreen
        self.present(storyDetailVC, animated: true, completion: nil)
       
    }
}
