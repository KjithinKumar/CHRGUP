//
//  ReservationTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 03/06/25.
//

import UIKit
protocol ReservationTableViewCellDelegate: AnyObject {
    func didTapCancelButton(for cell: ReservationTableViewCell)
}

class ReservationTableViewCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    weak var delegate : ReservationTableViewCellDelegate?
    var reservationTime : String?
    
    static let identifier = "ReservationTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        locationLabel.updateShimmerLayout()
        timeLabel.updateShimmerLayout()
        statusLabel.updateShimmerLayout()
    }
    @IBAction func cancelButtonPressed(_ sender: Any) {
        delegate?.didTapCancelButton(for: self)
    }
    
    func configure(reservation : Reservation,delegate : ReservationTableViewCellDelegate?){
        self.delegate = delegate
        
        locationLabel.text = reservation.locationName
        locationLabel.font = FontManager.bold(size: 17)
        
        timeLabel.text = formatDate(reservation.startTimeIST)
        reservationTime = formatDate(reservation.startTimeIST)
        timeLabel.font = FontManager.regular(size: 14)
        
        statusLabel.text = reservation.status
        statusLabel.font = FontManager.regular(size: 14)
        
        if reservation.status == "Reserved"{
            statusView.backgroundColor = ColorManager.reservedColor
            cancelButton.isHidden = false
        }else if reservation.status == "Completed"{
            statusView.backgroundColor = ColorManager.completedColor
            cancelButton.isHidden = true
        }else{
            statusView.backgroundColor = ColorManager.cancelledColor
            cancelButton.isHidden = true
        }
        
    }
    
    func setShimmering(isShimmer : Bool){
        configureUI()
        if isShimmer{
            locationLabel.backgroundColor = .label.withAlphaComponent(0.5)
            locationLabel.layer.cornerRadius = 8
            locationLabel.textColor = .clear
            locationLabel.startShimmering()
            
            timeLabel.backgroundColor = .label.withAlphaComponent(0.5)
            timeLabel.layer.cornerRadius = 8
            timeLabel.textColor = .clear
            timeLabel.startShimmering()
            
            statusLabel.backgroundColor = .label.withAlphaComponent(0.5)
            statusLabel.layer.cornerRadius = 8
            statusLabel.textColor = .clear
            statusLabel.startShimmering()
            cancelButton.isHidden = true
        }else{
            locationLabel.backgroundColor = .clear
            locationLabel.textColor = ColorManager.textColor
            locationLabel.stopShimmering()
            
            timeLabel.backgroundColor = .clear
            timeLabel.textColor = ColorManager.subtitleTextColor
            timeLabel.stopShimmering()
            
            statusLabel.backgroundColor = .clear
            statusLabel.textColor = ColorManager.subtitleTextColor
            statusLabel.stopShimmering()
            cancelButton.isHidden = false
        }
    }
    func configureUI(){
        backView.backgroundColor = ColorManager.secondaryBackgroundColor
        backView.layer.cornerRadius = 8
        backView.clipsToBounds = true
        
        cancelButton.setImage(UIImage(systemName: "minus.circle"), for: .normal)
        cancelButton.imageView?.tintColor = .red
    }
    func formatDate(_ input: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = inputFormatter.date(from: input) else {
            return input // fallback if parsing fails
        }

        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        displayFormatter.locale = Locale(identifier: "en_US_POSIX")

        return displayFormatter.string(from: date)
    }
    
}
