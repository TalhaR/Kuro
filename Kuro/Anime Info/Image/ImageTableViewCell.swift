//
//  ImageTableViewCell.swift
//  Kuro
//
//  Created by Talha Rahman on 11/20/20.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    static let identifier = "imageTableViewCell"

    @IBOutlet weak var animeImage: UIImageView!
    @IBOutlet weak var animeFormatLabel: UILabel!
    @IBOutlet weak var animeAiringStatusLabel: UILabel!
    @IBOutlet weak var animeSeasonLabel: UILabel!
    @IBOutlet weak var animeEpisodeLabel: UILabel!
    @IBOutlet weak var animeRatingLabel: UILabel!
    @IBOutlet weak var animePopularityLabel: UILabel!
    @IBOutlet weak var animeScoreLabel: UILabel!
    

    static func nib() -> UINib {
        return UINib(nibName: "ImageTableViewCell", bundle: nil)
    }
    
    public func configure(with image: UIImage) {
        animeImage.image = image
        print(animeImage.frame.width)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
