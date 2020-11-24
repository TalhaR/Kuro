//
//  DescriptionTableViewCell.swift
//  Kuro
//
//  Created by Talha Rahman on 11/20/20.
//

import UIKit

class DescriptionTableViewCell: UITableViewCell {
    static let identifier = "descriptionTableViewCell"

    @IBOutlet weak var animeDescription: UILabel!

    static func nib() -> UINib {
        return UINib(nibName: "DescriptionTableViewCell", bundle: nil)
    }
    
    public func configure(with text: NSAttributedString) {
        animeDescription.attributedText = text
        animeDescription.font = UIFont(name: "Comic Sans MS", size: 20)
        animeDescription.textColor = UIColor.gray
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
