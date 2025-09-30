//
//  HelpandSupportViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 15/03/25.
//

import UIKit

protocol textFieldsdidChangeDelegate : AnyObject {
    func textFieldDidChange(in cell: UITableViewCell, newText: String?)
}

class HelpandSupportViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var trackTiccketButton: UIButton!
    @IBOutlet weak var raiseTicketButton: UIButton!

    var viewModel : HelpAndSupportViewModelInterface?
    var attachImageIndexPath : IndexPath?
    var attachedImages: UIImage?
    var textFieldValues: [String : String] = [:]
    var selectedHistory : HistoryModel?
    var selectedTransaction : transactionModel?
    var selectedCategory : String?
    var selectedChargerId : String?
    var requiredFields = 4
    var subject : String?
    var message : String?
    
    var cameraManager: CameraManager?
    
    private var showSessionCell = true
    private var showChargerCell = true
    private var showTransactionCell = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeKeyboardNotifications()
        setUpUI()
        setUpTableView()
    }
    deinit {
        removeKeyboardNotifications()

    }
    override func viewWillDisappear(_ animated: Bool) {
        enableButtonAndRemoveIndicator(raiseTicketButton,titleColor: ColorManager.backgroundColor)
    }
    
    func setUpUI(){
        view.backgroundColor = ColorManager.backgroundColor
        navigationItem.title = "Help & Support"
        
        trackTiccketButton.backgroundColor = ColorManager.backgroundColor
        trackTiccketButton.setTitleColor(ColorManager.subtitleTextColor, for: .normal)
        trackTiccketButton.imageView?.tintColor = ColorManager.primaryTextColor
        
        raiseTicketButtonState(isEnabled: false)
        
        viewModel?.getTicketCategories { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                break
            case .failure(let error):
                AppErrorHandler.handle(error, in: self)
            }
        }
        viewModel?.fetchHistory { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                break
            case .failure(let error):
                AppErrorHandler.handle(error, in: self)
            }
        }
        Task{
            do{
                let _ = try await viewModel?.fetchWalletStatus(transaction: true, page: 1, limit: 100, refund: true)
            }catch(let error){
                AppErrorHandler.handle(error, in: self)
            }
        }
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        gesture.cancelsTouchesInView = false
        view.addGestureRecognizer(gesture)
    }

    @IBAction func raiseTicketButtonPressed(_ sender: Any) {
        raiseTicketButton.isUserInteractionEnabled = false
        raiseTicketButton.setTitleColor(ColorManager.primaryColor, for: .normal)
        disableButtonWithActivityIndicator(raiseTicketButton)
        viewModel?.createTicket(parameters: textFieldValues, image: attachedImages , imageFieldName: "screenshots") { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.status{
                        ToastManager.shared.showToast(message: response.message ?? "")
                        let trackTicketVc = TrackTicketViewController()
                        trackTicketVc.viewModel = TrackTicketViewModel(networkManager: NetworkManager.shared)
                        self.resetData()
                        self.navigationController?.pushViewController(trackTicketVc, animated: true)
                    }else{
                        self.showAlert(title: "Error", message: response.message)
                    }
                case .failure(let error) :
                    AppErrorHandler.handle(error, in: self)
                }
            }
        }
    }
    func resetData(){
        requiredFields = 4
        attachImageIndexPath = nil
        attachedImages = nil
        textFieldValues.removeAll()
        selectedHistory = nil
        selectedTransaction = nil
        selectedCategory = nil
        selectedChargerId = nil
        viewModel?.reset()
        subject = nil
        message = nil
        tableView.reloadData()
    }
    @IBAction func trackTicketButtonPressed(_ sender: Any) {
        let trackTicketVc = TrackTicketViewController()
        trackTicketVc.viewModel = TrackTicketViewModel(networkManager: NetworkManager.shared)
        navigationController?.pushViewController(trackTicketVc, animated: true)
    }
    
    func raiseTicketButtonState(isEnabled: Bool){
        raiseTicketButton.isEnabled = isEnabled
        raiseTicketButton.setTitle("Raise ticket", for: .normal)
        raiseTicketButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
        raiseTicketButton.titleLabel?.font = FontManager.bold(size: 18)
        raiseTicketButton.layer.cornerRadius = 20
        if isEnabled{
            raiseTicketButton.backgroundColor = ColorManager.primaryColor
            raiseTicketButton.setTitleColor(ColorManager.buttonTextColor, for: .normal)
        }else{
            raiseTicketButton.backgroundColor = ColorManager.secondaryBackgroundColor
            raiseTicketButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
        }
    }
}

extension HelpandSupportViewController: UITableViewDataSource, UITableViewDelegate{
    func setUpTableView(){
        tableView.register(UINib(nibName: "HelpandSupportTableViewCell", bundle: nil), forCellReuseIdentifier: HelpandSupportTableViewCell.identifier)
        tableView.register(UINib(nibName: "CustomerServiceTitleTableViewCell", bundle: nil), forCellReuseIdentifier: CustomerServiceTitleTableViewCell.identifier)
        tableView.register(UINib(nibName: "DropDownViewTableViewCell", bundle: nil), forCellReuseIdentifier: DropDownViewTableViewCell.identifier)
        tableView.register(UINib(nibName: "SubjectTableViewCell", bundle: nil), forCellReuseIdentifier: SubjectTableViewCell.identifier)
        tableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: MessageTableViewCell.identifier)
        tableView.register(UINib(nibName: "AttachImageTableViewCell", bundle: nil), forCellReuseIdentifier: AttachImageTableViewCell.identifier)
        tableView.register(UINib(nibName: "CategoryDropDownTableViewCell", bundle: nil), forCellReuseIdentifier: CategoryDropDownTableViewCell.identifier)
        tableView.register(UINib(nibName: "SessionDropDownTableViewCell", bundle: nil), forCellReuseIdentifier: SessionDropDownTableViewCell.identifier)
        tableView.register(UINib(nibName: "EnterChargerTableViewCell", bundle: nil), forCellReuseIdentifier: EnterChargerTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = ColorManager.backgroundColor
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.fields.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = viewModel?.fields[indexPath.row]
        switch field {
        case .generalFaq(let title,let image,let type) :
            let cell = tableView.dequeueReusableCell(withIdentifier: HelpandSupportTableViewCell.identifier) as? HelpandSupportTableViewCell
            cell?.configure(title: title, image: image, type: type, delegate: self)
            cell?.backgroundColor = .clear
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()
        case .customerServiceTitle(let title,let subTitle):
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomerServiceTitleTableViewCell.identifier) as? CustomerServiceTitleTableViewCell
            cell?.configure(title: title, subtitle: subTitle)
            cell?.backgroundColor = .clear
            return cell ?? UITableViewCell()
        case .selectCategory(let title,let placeHolder,let image):
            let cell = tableView.dequeueReusableCell(withIdentifier: DropDownViewTableViewCell.identifier) as? DropDownViewTableViewCell
            cell?.configure(title: title, placeholder: placeHolder, image: image)
            if let selectedCategory = selectedCategory{
                cell?.setDropdownValue(selectedCategory)
                textFieldValues["category"] = selectedCategory
            }else{
                cell?.setDropdownValue("")
                textFieldValues["category"] = ""
            }
            cell?.backgroundColor = .clear
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()
        case .selectSession(let title,let placeHolder,let image):
            let cell = tableView.dequeueReusableCell(withIdentifier: DropDownViewTableViewCell.identifier) as? DropDownViewTableViewCell
            cell?.configure(title: title, placeholder: placeHolder, image: image)
            if let history = selectedHistory{
                let text = history.locationName + " | " + history.vehicle + " | " + formatDate(history.createdAt) + "  "
                cell?.setDropdownValue(text)
                textFieldValues["categoryId"] = selectedHistory?.sessionId
            }else{
                cell?.setDropdownValue("")
                textFieldValues["categoryId"] = ""
            }
            cell?.backgroundColor = .clear
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()
        case .subject(let title,let placeHolder):
            let cell = tableView.dequeueReusableCell(withIdentifier: SubjectTableViewCell.identifier) as? SubjectTableViewCell
            cell?.configure(title: title, placeHolder: placeHolder,delegate: self)
            cell?.subjectTextfield.text = subject ?? ""
            cell?.selectionStyle = .none
            cell?.backgroundColor = .clear
            return cell ?? UITableViewCell()
        case .message(let title,let placeHolder):
            let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.identifier) as? MessageTableViewCell
            cell?.configure(title: title, placeHolder: placeHolder, delegate: self)
            cell?.messageTextView.text = message ?? ""
            cell?.selectionStyle = .none
            cell?.backgroundColor = .clear
            return cell ?? UITableViewCell()
        case .attachImage:
            let cell = tableView.dequeueReusableCell(withIdentifier: AttachImageTableViewCell.identifier) as? AttachImageTableViewCell
            let image = attachedImages
            cell?.configure(indexpath: indexPath, image: image, delegate: self)
            cell?.selectionStyle = .none
            cell?.backgroundColor = .clear
            return cell ?? UITableViewCell()
        case .dropdownOption(let title) :
            let cell = tableView.dequeueReusableCell(withIdentifier: CategoryDropDownTableViewCell.identifier) as? CategoryDropDownTableViewCell
            cell?.configure(with: title)
            cell?.selectionStyle = .none
            cell?.backgroundColor = .clear
            return cell ?? UITableViewCell()
        case .sessionDropdownOption(let history):
            let cell = tableView.dequeueReusableCell(withIdentifier: SessionDropDownTableViewCell.identifier) as? SessionDropDownTableViewCell
            cell?.configure(chargingInfo: history)
            cell?.selectionStyle = .none
            cell?.backgroundColor = .clear
            return cell ?? UITableViewCell()
        case .selectCharger(let title,let placeHolder) :
            let cell = tableView.dequeueReusableCell(withIdentifier: EnterChargerTableViewCell.identifier) as? EnterChargerTableViewCell
            cell?.configure(title: title, placeholder: placeHolder,delegate: self, scanDelegate: self)
            cell?.selectionStyle = .none
            cell?.backgroundColor = .clear
            return cell ?? UITableViewCell()
        case .selectTransaction(let title,let placeHolder,let image) :
            let cell = tableView.dequeueReusableCell(withIdentifier: DropDownViewTableViewCell.identifier) as? DropDownViewTableViewCell
            cell?.configure(title: title, placeholder: placeHolder, image: image)
            if let transaction = selectedTransaction{
                let text = transaction.transactionId + " | " + "₹ \(transaction.amount/100)"
                cell?.setDropdownValue(text)
                textFieldValues["categoryId"] = selectedTransaction?.transactionId
            }else{
                cell?.setDropdownValue("")
                textFieldValues["categoryId"] = ""
            }
            cell?.backgroundColor = .clear
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()
        case .transactionDropdownOption(let transaction) :
            let cell = tableView.dequeueReusableCell(withIdentifier: SessionDropDownTableViewCell.identifier) as? SessionDropDownTableViewCell
            cell?.configure(transactionInfo: transaction)
            cell?.selectionStyle = .none
            cell?.backgroundColor = .clear
            return cell ?? UITableViewCell()
        default : break
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fields = viewModel?.fields[indexPath.row]
        removeDropdownOptions(below: indexPath.row)
        switch fields{
        case .generalFaq(_, _,let type) :
            switch type{
            case .faq:
                let faqCategoryVc = FaqCategoryTableViewController()
                faqCategoryVc.viewModel = HelpAndSupportViewModel(networkManager: NetworkManager.shared, delegate: faqCategoryVc)
                navigationController?.pushViewController(faqCategoryVc, animated: true)
            case .contactUs:
                break
            }
        case .selectSession :
            guard let sessionOptions = viewModel?.history else { return  }
            insertSessionDropdownOptions(sessionOptions, below: indexPath.row)
        case .selectTransaction :
            guard let transactions = viewModel?.transaction else {return}
            insertTransactionDropdownOptions(transactions, below: indexPath.row)
        case .selectCategory :
            guard let options = viewModel?.categoryOptions else { return  }
            viewModel?.expandedDropdownIndex = indexPath.row
            insertDropdownOptions(options, below: indexPath.row)
        case .dropdownOption(let title):
            guard let dropDownIndex = viewModel?.expandedDropdownIndex else { return }
            removeDropdownOptions(below: dropDownIndex)
            // Set selected category
            self.selectedCategory = title
            // Decide visibility and required fields
            if title.contains("Charger Not Working") ||
               title.contains("Connector Problem") ||
               title.contains("Physical Damage") {
                showTransactionCell = false
                showSessionCell = false
                showChargerCell = true
                requiredFields = 4
                textFieldValues.removeValue(forKey: "categoryId")
                self.textFieldValues["chargerId"] = selectedChargerId
            } else if title.contains("Billing") {
                showSessionCell = true
                showChargerCell = false
                showTransactionCell = false
                requiredFields = 4
                textFieldValues.removeValue(forKey: "categoryId")
                self.textFieldValues["categoryId"] = selectedHistory?.sessionId
                textFieldValues.removeValue(forKey: "chargerId")
                removeDropdownOptions(below: dropDownIndex)
            }else if title.contains("Refund"){
                showSessionCell = false
                showChargerCell = false
                showTransactionCell = true
                requiredFields = 4
                textFieldValues.removeValue(forKey: "categoryId")
                self.textFieldValues["categoryId"] = selectedTransaction?.transactionId
                textFieldValues.removeValue(forKey: "chargerId")
                removeDropdownOptions(below: dropDownIndex)
            }else { // "Others" and other categories
                showSessionCell = false
                showChargerCell = false
                showTransactionCell = false
                requiredFields = 3
                textFieldValues.removeValue(forKey: "categoryId")
                textFieldValues.removeValue(forKey: "chargerId")
            }
            tableView.reloadRows(at: [IndexPath(row: dropDownIndex, section: 0)], with: .none)
            // Animate height changes for session/charger cells
            tableView.beginUpdates()
            tableView.endUpdates()
        case .sessionDropdownOption(let history):
            guard let index = (0..<indexPath.row).reversed().first(where: {
                if case .selectSession = viewModel?.fields[$0] { return true }
                return false
            }) else { return }
            self.selectedHistory = history
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .none)
            removeDropdownOptions(below: index)
        case .transactionDropdownOption(let transaction):
            guard let index = (0..<indexPath.row).reversed().first(where: {
                if case .selectTransaction = viewModel?.fields[$0] { return true }
                return false
            }) else { return }
            self.selectedTransaction = transaction
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .none)
            removeDropdownOptions(below: index)
        default :
            break
        }
        
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch viewModel?.fields[indexPath.row] {
        case .selectCategory, .selectSession, .dropdownOption, .generalFaq, .sessionDropdownOption,.selectTransaction,.transactionDropdownOption:
            return indexPath
        default:
            return nil
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let field = viewModel?.fields[indexPath.row]
        switch field {
        case .selectSession:
            return showSessionCell ? UITableView.automaticDimension : 0.0
        case .selectCharger:
            return showChargerCell ? UITableView.automaticDimension : 0.0
        case .selectTransaction :
            return showTransactionCell ? UITableView.automaticDimension : 0.0
        default:
            return UITableView.automaticDimension
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        checkIfAllFieldsFilled()
    }
    
}
extension HelpandSupportViewController: HelpandSupportDelegate{
    func didSelectHelpandSupport(type: HelpAndSupportType) {
        switch type{
        case .faq:
            let faqCategoryVc = FaqCategoryTableViewController()
            faqCategoryVc.viewModel = HelpAndSupportViewModel(networkManager: NetworkManager.shared, delegate: faqCategoryVc)
            navigationController?.pushViewController(faqCategoryVc, animated: true)
        case .contactUs:
            break
        }
    }
}
extension HelpandSupportViewController {
    func insertDropdownOptions(_ options: [String], below index: Int) {
        var indexPaths: [IndexPath] = []
        for (offset, option) in options.enumerated() {
            viewModel?.fields.insert(.dropdownOption(title: option), at: index + offset + 1)
            indexPaths.append(IndexPath(row: index + offset + 1, section: 0))
        }
        tableView.insertRows(at: indexPaths, with: .fade)
    }
    func removeDropdownOptions(below index: Int) {
        guard let fields = viewModel?.fields else { return }

        var indicesToRemove: [Int] = []
        // Scan all rows after the index
        for i in (index + 1)..<fields.count {
            switch fields[i] {
            case .dropdownOption, .sessionDropdownOption, .transactionDropdownOption:
                indicesToRemove.append(i)
            default:
                // stop only when we reach another "main field"
                break
            }
        }
        // Remove in reverse order to keep indices valid
        for i in indicesToRemove.reversed() {
            viewModel?.fields.remove(at: i)
        }
        // Animate removal
        let indexPaths = indicesToRemove.map { IndexPath(row: $0, section: 0) }
        tableView.deleteRows(at: indexPaths, with: .fade)
    }
    func formatDate(_ isoString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = isoFormatter.date(from: isoString) else {
            return isoString
        }
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        displayFormatter.locale = Locale(identifier: "en_US_POSIX")
        return displayFormatter.string(from: date)
    }
    func insertSessionDropdownOptions(_ sessions: [HistoryModel], below index: Int) {
        var indexPaths: [IndexPath] = []
        for (offset, session) in sessions.enumerated() {
            viewModel?.fields.insert(.sessionDropdownOption(history: session), at: index + offset + 1)
            indexPaths.append(IndexPath(row: index + offset + 1, section: 0))
        }
        tableView.insertRows(at: indexPaths, with: .fade)
    }
    func insertTransactionDropdownOptions(_ transactions: [transactionModel], below index: Int) {
        var indexPaths: [IndexPath] = []
        for (offset, transaction) in transactions.enumerated() {
            viewModel?.fields.insert(.transactionDropdownOption(transaction: transaction), at: index + offset + 1)
            indexPaths.append(IndexPath(row: index + offset + 1, section: 0))
        }
        tableView.insertRows(at: indexPaths, with: .fade)
    }
    override func moveViewForKeyboard(yOffset: CGFloat) {
        raiseTicketButton.transform = CGAffineTransform(translationX: 0, y: yOffset)
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: -yOffset, right: 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
        let rowCount = tableView.numberOfRows(inSection: 0)
        if rowCount >= 2 {
            let indexPath = IndexPath(row: rowCount - 2, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}
extension HelpandSupportViewController : AttachImageCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func attachImageButtonPressed(indexpath: IndexPath) {
        self.attachImageIndexPath  = indexpath
        showImagePickerOptions()
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.attachedImages = selectedImage
            self.tableView.reloadData()
        }
    }
    func showImagePickerOptions() {
        var actions = [UIAlertAction]()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                self?.openImagePicker(sourceType: .camera)
            }
            actions.append(cameraAction)
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let galleryAction = UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
                self?.openImagePicker(sourceType: .photoLibrary)
            }
            actions.append(galleryAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        actions.append(cancelAction)
        
        showAlert(title: "select image source", message: nil, style: .actionSheet, actions: actions)
    }
    func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }
}

extension HelpandSupportViewController : textFieldsdidChangeDelegate{
    func textFieldDidChange(in cell: UITableViewCell, newText: String?) {
        guard let indexpath = tableView.indexPath(for: cell) else { return }
        let field = viewModel?.fields[indexpath.row]
        switch field{
        case .selectCategory:
            self.textFieldValues["category"] = newText
        case .selectSession:
            self.textFieldValues["categoryId"] = selectedHistory?.sessionId
        case .subject:
            self.subject = newText
            self.textFieldValues["title"] = newText
        case .message:
            self.message = newText
            self.textFieldValues["description"] = newText
        case .selectCharger:
            self.selectedChargerId = newText
            self.textFieldValues["chargerId"] = newText
        case .selectTransaction:
            self.textFieldValues["categoryId"] = selectedTransaction?.transactionId
        default : break
        }
        checkIfAllFieldsFilled()
    }

    func checkIfAllFieldsFilled() {
        var isValid = true

        // Always required
        if (selectedCategory?.trimmingCharacters(in: .whitespaces).isEmpty ?? true) {
            isValid = false
        }
        if (subject?.trimmingCharacters(in: .whitespaces).isEmpty ?? true) {
            isValid = false
        }
        if (message?.trimmingCharacters(in: .whitespaces).isEmpty ?? true) {
            isValid = false
        }

        // Conditional required
        if showSessionCell {
            if selectedHistory?.sessionId == nil {
                isValid = false
            }
        }
        if showChargerCell {
            if (selectedChargerId?.trimmingCharacters(in: .whitespaces).isEmpty ?? true) {
                isValid = false
            }
        }
        if showTransactionCell {
            if selectedTransaction?.transactionId == nil {
                isValid = false
            }
        }

        raiseTicketButtonState(isEnabled: isValid)
    }
}
extension HelpandSupportViewController : EnterChargerCellDelegate{
    func didTapScanQRCode(cell: EnterChargerTableViewCell) {
        // Create scanner overlay
        let scannerView = UIView(frame: CGRect(x: 40, y: 150, width: view.frame.width - 80, height: 300))
        scannerView.backgroundColor = .black
        scannerView.layer.cornerRadius = 20
        scannerView.clipsToBounds = true
        view.addSubview(scannerView)
        
        
        // Initialize CameraManager
        cameraManager = CameraManager(previewView: scannerView) { [weak self] payload in
            guard let _ = self else {return}
            DispatchQueue.main.async {
                // Stop camera session
                self?.cameraManager?.stopSession()
                self?.cameraManager = nil
                // Remove overlay
                scannerView.removeFromSuperview()
                
                // Update the cell's text field
                cell.textField.text = payload.chargerId
                // Notify the text field delegate to update raise ticket button state
                cell.delegate?.textFieldDidChange(in: cell, newText: payload.chargerId)
            }
        }
        cameraManager?.startSession()
        // Add close button
        let closeButton = UIButton(frame: CGRect(x: scannerView.frame.width - 40, y: 10, width: 30, height: 30))
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.addTarget(self, action: #selector(closeScanner(_:)), for: .touchUpInside)
        scannerView.addSubview(closeButton)
    }
    @objc func closeScanner(_ sender: UIButton) {
        cameraManager?.stopSession()
        cameraManager = nil
        sender.superview?.removeFromSuperview()
    }
}
