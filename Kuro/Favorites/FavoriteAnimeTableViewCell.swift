//
//  FavoriteAnimeTableViewCell.swift
//  Kuro
//
//  Created by Talha Rahman on 11/24/20.
//

import UIKit

class FavoriteAnimeTableViewCell: UITableViewCell {
    static let identifier = "favoriteAnimeTableViewCell"
    @IBOutlet weak var animeImage: UIImageView!
    @IBOutlet weak var animeName: UILabel!
    @IBOutlet weak var animeScore: UILabel!
    @IBOutlet weak var animeType: UILabel!
    
    static func nib() -> UINib {
        return UINib(nibName: "FavoriteAnimeTableViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        animeImage.frame = frame(forAlignmentRect: CGRect(x: 10, y: 10, width: 115, height: 170))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
