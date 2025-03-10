//
//  SetRangeViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 07/03/25.
//

import UIKit
import SDWebImage

class SetRangeViewController: UIViewController {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var setRangeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var reangeTextField: UITextField!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var araitextLabel: UILabel!
    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var claimedNumberLabel: UILabel!
    @IBOutlet weak var claimedTextLabel: UILabel!
    @IBOutlet weak var araiRangeNumberLabel: UILabel!
    
    var userData : UserProfile?
    var selectedVehicleVariant : Variant?
    var viewModel : UserRegistrationViewModelnterface?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        observeKeyboardNotifications()
    }
    func setUpUI(){
        guard let selectedVehicleVariant = selectedVehicleVariant else { return }
        popUpView.layer.cornerRadius = 10
        popUpView.backgroundColor = ColorManager.backgroundColor
        
        setRangeLabel.textColor = ColorManager.textColor
        setRangeLabel.font = FontManager.regular()
        
        carNameLabel.textColor = ColorManager.textColor
        carNameLabel.font = FontManager.regular()
        
        araitextLabel.textColor = ColorManager.textColor
        araitextLabel.font = FontManager.regular(size: 12)
        
        
        araiRangeNumberLabel.textColor = ColorManager.textColor
        araiRangeNumberLabel.font = FontManager.regular()
        araiRangeNumberLabel.text = selectedVehicleVariant.ARAI_range
        
        claimedTextLabel.textColor = ColorManager.textColor
        claimedTextLabel.font = FontManager.regular(size: 12)
        
        claimedNumberLabel.textColor = ColorManager.textColor
        claimedNumberLabel.font = FontManager.regular()
        claimedNumberLabel.text = selectedVehicleVariant.claimed_range
        
        reangeTextField.placeholder = "Enter Range"
        reangeTextField.backgroundColor = ColorManager.secondaryBackgroundColor
        reangeTextField.delegate = self
        reangeTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = FontManager.bold(size: 17)
        doneButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
        doneButton.backgroundColor = ColorManager.secondaryBackgroundColor
        doneButton.isEnabled = false
        doneButton.layer.cornerRadius = 10
        
        closeButton.tintColor = ColorManager.textColor
        
        carNameLabel.text = selectedVehicleVariant.variant
        carNameLabel.textColor = ColorManager.textColor
        carNameLabel.font = FontManager.regular()
        
        let imageString = selectedVehicleVariant.image
        let fullUrlSting = URLs.baseUrls3 + imageString
        let imageUrl = URL(string: fullUrlSting)
        
        imageView.sd_setImage(with: imageUrl)
    
    }
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func doneButtonPressed(_ sender: Any) {
        userData?.userVehicle[0].range = reangeTextField.text ?? "0"
        guard let userData = userData else { return }
        UserDefaultManager.shared.saveUserProfile(userData)
        viewModel?.saveUserProfile(userProfile: userData)
        
    }
    override func moveViewForKeyboard(yOffset: CGFloat) {
        popUpView.transform = CGAffineTransform(translationX: 0, y: yOffset + self.view.safeAreaInsets.bottom + 75)
    }
}
extension SetRangeViewController : UITextFieldDelegate {
    @objc func textFieldDidChange(_ textField: UITextField) {
        doneButton.isEnabled = !(textField.text?.isEmpty ?? true)
        if doneButton.isEnabled {
            doneButton.backgroundColor = ColorManager.primaryColor
        }
    }
   
}

extension SetRangeViewController : UserRegistrationViewModelDelegate{
    func didSaveUserProfileSuccessfully(token: String?) {
        print(UserDefaultManager.shared.getUserProfile())
        UserDefaultManager.shared.setJWTToken(token ?? "")
        
        DispatchQueue.main.async{
            let vc = SetupSuccessViewController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
    func didFailToSaveUserProfile(error: String) {
        debugPrint(error)
    }
    
    
}
