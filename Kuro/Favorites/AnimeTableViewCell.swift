//
//  AnimeTableViewCell.swift
//  Kuro
//
//  Created by Talha Rahman on 11/4/20.
//

import UIKit

class AnimeTableViewCell: UITableViewCell {
    @IBOutlet weak var animeImage: UIImageView!
    @IBOutlet weak var animeName: UILabel!
    @IBOutlet weak var animeScore: UILabel!
    @IBOutlet weak var animeType: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
