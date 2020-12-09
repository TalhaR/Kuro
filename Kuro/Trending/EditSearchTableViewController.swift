//
//  EditSearchTableViewController.swift
//  Kuro
//
//  Created by Talha Rahman on 11/26/20.
//

import UIKit

// https://stackoverflow.com/questions/29117759/how-to-create-radio-buttons-and-checkbox-in-swift-ios
// checkbox animation code from here
extension UIButton {
    //MARK:- Animate check mark
    func checkboxAnimation(){
        guard let image = self.imageView else {return}
        
        UIView.animate(withDuration: 0.1, delay: 0.05, options: .curveLinear, animations: {
            image.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { (success) in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                self.isSelected = !self.isSelected
                image.transform = .identity
            }, completion: nil)
        }
    }
}

protocol EditSearchTableViewControllerDelegate {
    func editQuery(isAdult: Bool, sort: String)
}

class EditSearchTableViewController: UITableViewController {
    var delegate: EditSearchTableViewControllerDelegate!
    
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var matureContentButton: UIButton!
    @IBOutlet weak var popularityRadioButton: UIButton!
    @IBOutlet weak var ratingRadioButton: UIButton!
    @IBOutlet weak var trendingRadioButton: UIButton!
    var radioButtons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        radioButtons = [popularityRadioButton, ratingRadioButton, trendingRadioButton]
    }
    
    @IBAction func apply(_ sender: UIButton) {
        var choice: String!, sort: String!
        
        for button in radioButtons {
            if button.isSelected {
                choice = button.titleLabel!.text!
                break
            }
        }
        
        switch choice!.trimmingCharacters(in: .whitespaces) {
        case "Popularity":
            sort = "POPULARITY_DESC"
        case "Rating":
            sort = "SCORE_DESC"
        case "Trending":
            sort = "TRENDING_DESC"
        default:
            print("Error: invalid choice")
        }
        
        delegate.editQuery(isAdult: !matureContentButton.isSelected, sort: sort)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func checkbox(_ sender: UIButton){
        sender.checkboxAnimation()
    }
    
    @IBAction func pick(_ sender: UIButton) {
        sender.isSelected = true
        // deselects other radio Buttons
        for button in radioButtons where button != sender {
            button.isSelected = false
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            pick(radioButtons[indexPath.row])
        }
    }
}
