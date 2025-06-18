//
//  AttachImageTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 29/04/25.
//

import UIKit
protocol AttachImageCellDelegate: AnyObject {
    func attachImageButtonPressed(indexpath : IndexPath)
}

class AttachImageTableViewCell: UITableViewCell {

    @IBOutlet weak var attachImageButton: UIButton!
    @IBOutlet weak var attachedImageView: UIImageView!
    @IBOutlet weak var deleteImageButton: UIButton!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    static let identifier: String = "AttachImageTableViewCell"
    var indexpath : IndexPath?
    weak var delegate : AttachImageCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func deleteImageButtonPressed(_ sender: Any) {
        imageViewState(isHidden: true)
    }
    @IBAction func attachImageButtonPressed(_ sender: Any) {
        if let indexpath = indexpath{
            delegate?.attachImageButtonPressed(indexpath: indexpath)
        }
        
    }
    func configure(indexpath : IndexPath, image : UIImage?, delegate : AttachImageCellDelegate?){
        self.indexpath = indexpath
        self.delegate = delegate
        attachImageButton.setTitle("  Attach Image", for: .normal)
        attachImageButton.setTitleColor(ColorManager.textColor, for: .normal)
        attachImageButton.imageView?.tintColor = ColorManager.primaryTextColor
        attachImageButton.backgroundColor = .clear
        
        deleteImageButton.imageView?.tintColor = .red
        
        attachedImageView.tintColor = ColorManager.subtitleTextColor
        attachedImageView.layer.borderWidth = 1
        attachedImageView.layer.borderColor = ColorManager.primaryTextColor.cgColor
        attachedImageView.layer.cornerRadius = 8
        attachedImageView.clipsToBounds = true
        
        if image != nil{
            imageViewState(isHidden: false)
            attachedImageView.image = image
        }else {
            imageViewState(isHidden: true)
        }
        
    }
    func imageViewState(isHidden : Bool){
        attachedImageView.isHidden = isHidden
        deleteImageButton.isHidden = isHidden
        attachImageButton.isHidden = !isHidden
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
