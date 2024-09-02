//
//  UserCollectionViewCell.swift
//  Pixora
//
//  Created by İrem Sever on 2.09.2024.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleUsername: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func configure(with storyResponse: StoryResponse) {
        titleUsername.text = storyResponse.user
        
        if let imageName = storyResponse.storyDetails.first?.image {
            imgUser.image = UIImage(named: imageName) ?? UIImage(named: "placeholder")
        } else {
            imgUser.image = UIImage(named: "placeholder")
        }
    }
    
    private func setupUI() {
        titleUsername.font = UIFont.systemFont(ofSize: 16)
        titleUsername.textColor = .black
        imgUser.contentMode = .scaleAspectFill
        imgUser.clipsToBounds = true
    }
}
