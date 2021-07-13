//
//  TopFreeTableViewCell.swift
//  AppStoreDemo
//
//  Created by Patrick Tang on 9/7/2021.
//

import UIKit

class TopFreeTableViewCell: UITableViewCell {
    
    enum AppIconCorner {
        case rounded
        case circle
    }
    
    @IBOutlet weak var rankingLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var appIconImageView: UIImageView!
    @IBOutlet weak var starView: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        starView.settings.updateOnTouch = false
        starView.backgroundColor = .clear
        starView.settings.starSize = 15
        starView.settings.starMargin = 2
        
        appIconImageView.backgroundColor = .gray
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    
    override func prepareForReuse() {
        super.prepareForReuse()

        appIconImageView.image = nil
        setRatingView(rating: 0, ratingCount: 0)
    }
    
    func setCorner(for type: AppIconCorner) {
        switch type {
        case .rounded:
            appIconImageView.addRoundedCorners()
        case .circle:
            appIconImageView.addCircleCorners()
        }
    }
    
    func setDetail(for freeApp: AppRecord & AppWithRating) {
        rankingLabel.text = "\(freeApp.ranking + 1)"
        titleLabel.text = freeApp.title
        categoryLabel.text = freeApp.category
        
        setRatingView(rating: freeApp.rating, ratingCount: Int(freeApp.ratingCount))
    }
    
    private func setRatingView(rating: Double, ratingCount: Int) {
        starView.rating = rating
        starView.text = "(\(ratingCount))"
    }
    
}
