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
//        genreLabel.backgroundColor = .gray
//        genreLabel.layer.masksToBounds = true
//        genreLabel.layer.cornerRadius = genreLabel.frame.height/1.5
//        genreLabel.layer.borderWidth = 3
        
        contentView.backgroundColor = .darkGray
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        
//        contentView.heightAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
//        contentView.widthAnchor.constraint(equalToConstant: 50).isActive = true
//        contentView.widthAnchor.constraint(equalTo: genreLabel.widthAnchor, multiplier: 2.0).isActive = true
    }

}
