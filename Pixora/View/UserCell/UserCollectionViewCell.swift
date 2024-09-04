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
        
        
        imgUser.layer.cornerRadius = imgUser.frame.height / 2
        imgUser.layer.masksToBounds = true
 
        titleUsername.textColor = .lightGray
        
        addBorderLines(to: imgUser, count: 3)
   

    }
    
    private func addBorderLines(to imageView: UIImageView, count: Int) {
        imageView.superview?.layer.sublayers?.removeAll(where: { $0 is CAShapeLayer })
        
        let lineWidth: CGFloat = 5.0
        let gap: CGFloat = 50
        let lineGap: CGFloat = 10
        let radius = (imageView.bounds.width) / 2
        let arcLength = 2 * CGFloat.pi / CGFloat(count)
        
        for i in 0..<count {
            let startAngle = CGFloat(i) * arcLength
            let endAngle = startAngle + arcLength - lineGap / radius
            
            let path = UIBezierPath(arcCenter: CGPoint(x: (imageView.frame.width + gap) / 2, y: (imageView.frame.height + 16) / 2), radius: radius + lineWidth / 2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.strokeColor = UIColor(red: 246/255, green: 173/255, blue: 0/255, alpha: 1).cgColor
            shapeLayer.lineWidth = lineWidth
            shapeLayer.fillColor = UIColor.clear.cgColor
            
            imageView.superview?.layer.addSublayer(shapeLayer)
        }
    }
    
    private func setupUI() {
        titleUsername.font = UIFont.systemFont(ofSize: 16)
        titleUsername.textColor = .black
        imgUser.contentMode = .scaleAspectFill
        imgUser.clipsToBounds = true
    }
}
