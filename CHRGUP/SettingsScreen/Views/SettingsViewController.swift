//
//  SettingsViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 29/03/25.
//

import UIKit
import SDWebImage

class SettingsViewController: UIViewController {

    @IBOutlet weak var backViewTop: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    var userData : UserProfile?
    var viewModel : settingsViewModelInterface?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userData = UserDefaultManager.shared.getUserProfile()
        setUpUi()
    }
    override func viewWillAppear(_ animated: Bool) {
        userData = UserDefaultManager.shared.getUserProfile()
    }
    @IBAction func logoutButtonPressed(_ sender: Any) {
        showAlert(title: "Logout", message: "Are you sure you want to logout?",actions: [AlertActions.logoutAction(),UIAlertAction(title: AppStrings.Alert.cancel, style: .default, handler: nil)])
        
    }
    @IBAction func deleteButtonPressed(_ sender: Any) {
        showAlert(title: "Delete Account", message: "Do you want to delete your user account?",actions: [UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            if let mobileNumber = self.userData?.phoneNumber {
                self.viewModel?.deletUserAccount(mobileNumber: mobileNumber, completion: { [weak self] result in
                    guard let self = self else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        switch result{
                        case .success(let response):
                            if response.success == false {
                                DispatchQueue.main.async {
                                    self.showAlert(title: "Failed to Delete", message: response.message)
                                }
                            }else{
                                DispatchQueue.main.async {
                                    ToastManager.shared.showToast(message: response.message)
                                    let welcomeVc = WelcomeViewController(nibName: "WelcomeViewController", bundle: nil)
                                    let navigationController = UINavigationController(rootViewController: welcomeVc)
                                    navigationController.modalPresentationStyle = .fullScreen
                                    navigationController.navigationBar.tintColor = ColorManager.buttonColorwhite
                                    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                                    sceneDelegate?.window?.rootViewController = navigationController
                                }
                            }
                        case .failure(let error):
                            DispatchQueue.main.async{
                                self.showAlert(title: "Error", message: error.localizedDescription)}
                        }
                    }
                })
            }
        }),UIAlertAction(title: AppStrings.Alert.cancel, style: .default, handler: nil)])
        
    }
    @IBAction func editButtonPressed(_ sender: Any) {
        let editVc = EditProfileViewController()
        editVc.viewModel = EditProfileViewModel(networkManager: NetworkManager())
        navigationController?.pushViewController(editVc, animated: true)
    }
    func setUpUi() {
        let attributes : [NSAttributedString.Key : Any] = [.underlineStyle : NSUnderlineStyle.single.rawValue]
        view.backgroundColor = ColorManager.backgroundColor
        
        backViewTop.backgroundColor = ColorManager.secondaryBackgroundColor
        backViewTop.layer.cornerRadius = 8
        
        let editText = AppStrings.Settings.editProfileText
        let attributeEditText = NSAttributedString(string: editText, attributes: attributes)
        editButton.setAttributedTitle(attributeEditText, for: .normal)
        editButton.setTitleColor(ColorManager.primaryColor, for: .normal)
        editButton.titleLabel?.font = FontManager.light()
        
        let deleteText = AppStrings.Settings.deleteAccountText
        let attributeTitle = NSAttributedString(string: deleteText, attributes: attributes)
        deleteButton.setAttributedTitle(attributeTitle, for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        
        logoutButton.setTitle(AppStrings.Settings.logoutText, for: .normal)
        logoutButton.setTitleColor(ColorManager.textColor, for: .normal)
        logoutButton.imageView?.tintColor = ColorManager.textColor
        logoutButton.backgroundColor = ColorManager.secondaryBackgroundColor
        logoutButton.layer.cornerRadius = 8
        
        titleLabel.font = FontManager.bold(size: 18)
        if let userName = userData?.phoneNumber {
            titleLabel.text = userName
        }
        titleLabel.textColor = ColorManager.textColor
        
        navigationItem.title = AppStrings.Settings.settings
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.tintColor = ColorManager.textColor
        if let profilePic = userData?.profilePic{
            profileImageView.sd_setImage(with: URL(string: profilePic),placeholderImage: UIImage(systemName: "person.crop.circle"))
        }
        
    }
    
}
