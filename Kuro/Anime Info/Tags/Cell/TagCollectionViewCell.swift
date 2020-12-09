//
//  TagCollectionViewCell.swift
//  Kuro
//
//  Created by Talha Rahman on 11/20/20.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    static let identifier = "tagCollectionViewCell"
    
    @IBOutlet weak var genreLabel: UILabel!
    
    static func nib() -> UINib {
        return UINib(nibName: "TagCollectionViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func configure(with name: String) {
        genreLabel.text = name
        contentView.backgroundColor = .darkGray
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
    }

}
