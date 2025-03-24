//
//  SetRangeViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 07/03/25.
//

import UIKit
import SDWebImage

protocol setRangeViewControllerDelegate : AnyObject {
    func addedNewVehicle(message: String)
    func failedToAddNewVehicle(_ error : String,_ code : Int)
}

class SetRangeViewController: UIViewController {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var setRangeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var rangeTextField: UITextField!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var araitextLabel: UILabel!
    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var claimedNumberLabel: UILabel!
    @IBOutlet weak var claimedTextLabel: UILabel!
    @IBOutlet weak var araiRangeNumberLabel: UILabel!
    
    weak var delegate : setRangeViewControllerDelegate?
    
    var userData : UserProfile?
    var selectedVehicleVariant : Variant?
    var newVehicle : VehicleModel?
    var viewModel : UserRegistrationViewModelnterface?
    var setRangeScreenType : UserVehicleInfoScreenType?
    
    
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
        
        rangeTextField.placeholder = "Enter Range"
        rangeTextField.backgroundColor = ColorManager.secondaryBackgroundColor
        rangeTextField.delegate = self
        rangeTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
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
        
        let imageUrlSting = URLs.imageUrl(selectedVehicleVariant.image)
        let imageUrl = URL(string: imageUrlSting)
        
        imageView.sd_setImage(with: imageUrl)
    
    }
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func doneButtonPressed(_ sender: Any) {
        switch setRangeScreenType {
        case .registerNew:
            userData?.userVehicle[0].range = rangeTextField.text ?? "0"
            guard let userData = userData else { return }
            UserDefaultManager.shared.saveUserProfile(userData)
            UserDefaultManager.shared.saveSelectedVehicle(userData.userVehicle[0])
            viewModel?.saveUserProfile(userProfile: userData)
        case .addNew:
            guard let mobileNumeber = userData?.phoneNumber else { return }
            newVehicle?.range = rangeTextField.text ?? "0"
            guard let newVehicle = newVehicle else { return }
            viewModel?.addNewVehicle(vehicle: newVehicle,mobileNumber: mobileNumeber)
        case .edit:
            guard let mobileNumber = UserDefaultManager.shared.getUserProfile()?.phoneNumber else {
                debugPrint("Mobile Number not found")
                return }
            newVehicle?.range = rangeTextField.text ?? "0"
            guard let vehicleId = newVehicle?.id else {return}
            guard let newVehicle = newVehicle else {return}
            viewModel?.updateVehicle(vehicle: newVehicle, mobileNumber: mobileNumber, vehicleId: vehicleId)
        case nil:
            print("nil")
        }
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
        }else{
            doneButton.backgroundColor = ColorManager.secondaryBackgroundColor
        }
    }
}

extension SetRangeViewController : UserRegistrationViewModelDelegate{
    func didSaveUserProfileSuccessfully(token: String?) {
        UserDefaultManager.shared.setJWTToken(token ?? "")        
        DispatchQueue.main.async{
            let vc = SetupSuccessViewController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    func didAddedNewVehicleSuccessfully(message: String?) {
        DispatchQueue.main.async{
            self.dismiss(animated: true)
            self.delegate?.addedNewVehicle(message: message ?? "Added Vehicle Successfully")
        }
    }
    func didFailToSaveUserProfile(error: String) {
        debugPrint(error)
    }
    func failedToAddNewVehicle(_ error: String, _ code: Int) {
        DispatchQueue.main.async{
            self.dismiss(animated: true)
            self.delegate?.failedToAddNewVehicle(error, code)
        }
        
    }
    func didUpdateVehicleSuccessfully(message: String?) {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
            self.delegate?.addedNewVehicle(message: message ?? "Updated Vehicle Successfully")
        }
    }
    
    
}
