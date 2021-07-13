//
//  RecommandCollectionViewCell.swift
//  AppStoreDemo
//
//  Created by Patrick Tang on 10/7/2021.
//

import UIKit

class RecommandCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var appIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        appIconImageView.backgroundColor = .gray
        appIconImageView.addRoundedCorners()
    }
    
    func setDetail(for grossingApp: AppRecord) {
        titleLabel.text = grossingApp.title
        categoryLabel.text = grossingApp.category
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        appIconImageView.image = nil
    }

}
