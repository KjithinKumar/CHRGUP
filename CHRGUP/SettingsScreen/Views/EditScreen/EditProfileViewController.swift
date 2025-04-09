//
//  EditProfileViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 29/03/25.
//

import UIKit
enum TextFieldType {
    case textField(title : String,placeholder : String)
    case datePicker(title : String, placeholder : String)
    case dropDown(title : String, placeholder : String)
}

class EditProfileViewController: UIViewController {
    
    var viewModel : EditProfileViewModelInterface?
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    var fields : [TextFieldType]?
    var userData : UserProfile?
    var modifiedUserData : UserProfile?
    override func viewDidLoad() {
        super.viewDidLoad()
        fields = [.textField(title: AppStrings.EditProfile.firstNameText, placeholder: AppStrings.EditProfile.firstNamePlaceholderText),
                  .textField(title: AppStrings.EditProfile.lastnameText, placeholder: AppStrings.EditProfile.lastnamePlaceholderText),
                  .textField(title: AppStrings.EditProfile.emailText, placeholder: AppStrings.EditProfile.emailPlaceholderText),
                  .dropDown(title: AppStrings.EditProfile.genderText, placeholder: AppStrings.EditProfile.genderPlaceholderText),
                  .datePicker(title: AppStrings.EditProfile.dob, placeholder: AppStrings.EditProfile.dobPlaceholderText)]
        userData = UserDefaultManager.shared.getUserProfile()
        modifiedUserData = userData
        setUpTableView()
        view.backgroundColor = ColorManager.backgroundColor
        navigationItem.title = "Edit Profile"
        updateButton.setTitle("Update Details", for: .normal)
        updateButton.titleLabel?.font = FontManager.bold(size: 18)
        updateButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
        updateButtonState()
        updateButton.layer.cornerRadius = 10
        observeKeyboardNotifications()
    }
    deinit {
        removeKeyboardNotifications()
    }
    @IBAction func updateButtonPressed(_ sender: Any) {
        guard let modifiedUserData = modifiedUserData else { return }
        viewModel?.updateUserProfile(userData: modifiedUserData, completion: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async{
                switch result{
                case .success(let response):
                    if response.success == false {
                        self.showAlert(title: "Failed to Update", message: response.message)
                    }else{
                        UserDefaultManager.shared.saveUserProfile(modifiedUserData)
                        ToastManager.shared.showToast(message: response.message ?? "User profile Updated")
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)}
            }
        })
    }
    func updateButtonState(){
        let dataChanged = modifiedUserData?.firstName != userData?.firstName || modifiedUserData?.lastName != userData?.lastName || modifiedUserData?.email != userData?.email || modifiedUserData?.gender != userData?.gender || modifiedUserData?.dob != userData?.dob
        if dataChanged{
            updateButton.isEnabled = true
            updateButton.backgroundColor = ColorManager.primaryColor
        }else{
            updateButton.isEnabled = false
            updateButton.backgroundColor = ColorManager.secondaryBackgroundColor
        }
    }
}
extension EditProfileViewController: UITableViewDataSource, EditProfileTableViewCellDelegate {
   
    func setUpTableView() {
        tableView.register(UINib(nibName: "EditProfileTableViewCell", bundle: nil), forCellReuseIdentifier: EditProfileTableViewCell.identifier)
        tableView.backgroundColor = ColorManager.backgroundColor
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let userData = userData else {return UITableViewCell()}
        let cell = tableView.dequeueReusableCell(withIdentifier: EditProfileTableViewCell.identifier) as? EditProfileTableViewCell ??  EditProfileTableViewCell()
        if let fields = fields {cell.configure(type: fields[indexPath.row],userdata: userData, delegate: self)}
        cell.backgroundColor = ColorManager.backgroundColor
        return cell
    }
    override func moveViewForKeyboard(yOffset: CGFloat) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -(yOffset - self.view.safeAreaInsets.bottom - 75), right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
        updateButton.transform = CGAffineTransform(translationX: 0, y: yOffset)
    }
    
    func didChangeText(text: String, cell: EditProfileTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell), let fields = fields else { return }
                switch fields[indexPath.row] {
                case .textField(title: let title, _):
                    if title == AppStrings.EditProfile.firstNameText {
                        modifiedUserData?.firstName = text
                    } else if title == AppStrings.EditProfile.lastnameText {
                        modifiedUserData?.lastName = text
                    }
                    
                case .dropDown(title: let title, _):
                    if title == AppStrings.EditProfile.genderText {
                        modifiedUserData?.gender = text
                    }
                    
                case .datePicker(title: let title, _):
                    if title == AppStrings.EditProfile.dob {
                        modifiedUserData?.dob = text
                    }
                }
        updateButtonState()
    }
    
}

