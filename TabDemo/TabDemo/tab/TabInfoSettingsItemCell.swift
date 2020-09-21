//
//  TabInfoSettingsItemCell.swift
//  TabDemo
//
//  Created by guest2 on 10/09/2020.
//  Copyright © 2020 yocto. All rights reserved.
//

import UIKit

class TabInfoSettingsItemCell: UICollectionViewCell {

    @IBOutlet weak var circleView: UIView!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var reorderImageView: UIImageView!
    
    var delegate: TabInfoSettingsItemCellDelegate?
    
    var reorderDelegate: ReorderDelegate?
    
    @IBAction func crossButtonClick(_ sender: Any) {
        delegate?.crossButtonClick(sender as! UIButton)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        circleView.asCircle()
        
        reorderImageView.isUserInteractionEnabled = true
        let gesture = UILongPressGestureRecognizer(target:self, action: #selector(longPressGesture))
        gesture.minimumPressDuration = 0
        reorderImageView.addGestureRecognizer(gesture)
    }
    
    @objc func longPressGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case UIGestureRecognizerState.began:
            reorderDelegate?.began(gesture)
        case UIGestureRecognizerState.changed:
            reorderDelegate?.changed(gesture)
        case UIGestureRecognizerState.ended:
            reorderDelegate?.end(gesture)
        default:
            reorderDelegate?.cancel(gesture)
        }
    }
}
