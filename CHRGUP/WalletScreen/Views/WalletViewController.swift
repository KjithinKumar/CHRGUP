//
//  WalletViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 23/09/25.
//

import UIKit
import Razorpay

class WalletViewController: UIViewController {
    @IBOutlet weak var walletView: UIView!
    @IBOutlet weak var walletImage: UIImageView!
    @IBOutlet weak var walletBalanceLabel: UILabel!
    @IBOutlet weak var availableBalanceLabel: UILabel!
    @IBOutlet weak var addMoneyLabel: UILabel!
    @IBOutlet weak var moneyTextField: UITextField!
    @IBOutlet var addMoneyButtonCollection: [UIButton]!
    @IBOutlet weak var addMoneyButton: UIButton!
    @IBOutlet var filterButtonCollection: [UIButton]!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var historyLabel: UILabel!
    
    private var amount = 0
    var viewModel : WalletViewModelInterface?
    var razorpay: RazorpayCheckout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        configureButtonState(selectedButton: filterButtonCollection[0])
        setUpTableView()
        razorpay = RazorpayCheckout.initWithKey(AppIdentifications.RazorPay.key, andDelegate: self)
        viewModel?.onDataChanged = { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        walletView.startShimmering()
    }
    override func viewDidAppear(_ animated: Bool) {
        fetchWalletStatus(transaction: true, page: 1, limit: 5, refund: false)
    }
    func fetchWalletStatus(transaction : Bool,page: Int,limit : Int,refund : Bool){
        Task{
            do{
                let data = try await viewModel?.fetchWalletStatus(transaction: transaction, page: page, limit: limit, refund: refund)
                let balace = data?.data.balance
                configureBalance(balance: balace ?? 0)
            }catch(let error){
                AppErrorHandler.handle(error, in: self)
            }
            walletView.stopShimmering()
        }
        
    }
    func configureBalance(balance : Int){
        let money = balance / 100
        walletBalanceLabel.text = "₹ \(money)"
        if balance > 0{
            walletBalanceLabel.textColor = ColorManager.primaryTextColor
        }else if balance < 0{
            walletBalanceLabel.textColor = ColorManager.redColor
        }else{
            walletBalanceLabel.textColor = ColorManager.textColor
        }
    }
    
    func setUpUI(){
        navigationItem.title = AppStrings.Wallet.title
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(gesture)
        
        walletView.backgroundColor = ColorManager.secondaryBackgroundColor
        walletView.layer.cornerRadius = 10
        
        walletImage.tintColor = ColorManager.textColor
        
        walletBalanceLabel.text = "₹ 0.00"
        walletBalanceLabel.textColor = ColorManager.textColor
        walletBalanceLabel.font = FontManager.bold(size: 20)
        
        availableBalanceLabel.text = AppStrings.Wallet.availableBalance
        availableBalanceLabel.textColor = ColorManager.subtitleTextColor
        availableBalanceLabel.font = FontManager.light()
        
        addMoneyLabel.text = AppStrings.Wallet.addToWallet
        addMoneyLabel.textColor = ColorManager.textColor
        addMoneyLabel.font = FontManager.regular()
        
        addMoneyButton.setTitle(AppStrings.Wallet.addwalletButtonText, for: .normal)
        addMoneyButton.layer.cornerRadius = 20
        addMoneyButton.setTitleColor(ColorManager.buttonTextColor, for: .normal)
        addMoneyButton.titleLabel?.font = FontManager.bold(size: 17)
        changeButtonState(isEnabled: false)
        
        for button in addMoneyButtonCollection{
            button.backgroundColor = ColorManager.thirdBackgroundColor
            button.layer.cornerRadius = 8
            button.setTitleColor(ColorManager.textColor, for: .normal)
        }
        
        historyLabel.text = AppStrings.Wallet.history
        historyLabel.textColor = ColorManager.textColor
        historyLabel.font = FontManager.regular()
        
        for button in filterButtonCollection{
            button.layer.cornerRadius = 8
            button.backgroundColor = ColorManager.secondaryBackgroundColor
            button.setTitleColor(ColorManager.subtitleTextColor, for: .normal)
            button.layer.borderColor = ColorManager.primaryColor.cgColor
            if button.tag == 1{
                button.layer.borderColor = ColorManager.cancelledColor.cgColor
            }
            if button.tag == 3{
                button.layer.borderColor = ColorManager.reservedColor.cgColor
            }
            button.titleLabel?.font = FontManager.light()
        }
        
        
        moneyTextField.layer.cornerRadius = 8
        moneyTextField.clipsToBounds = true
        moneyTextField.placeholder = AppStrings.Wallet.enterAmount
        moneyTextField.textColor = ColorManager.primaryTextColor
        moneyTextField.tintColor = ColorManager.primaryTextColor
        moneyTextField.keyboardType = .numberPad
        moneyTextField.addTarget(self, action: #selector(textFieldTextChanged), for: .editingChanged)
        moneyTextField.font = FontManager.bold(size: 20)
        
    }
    func configureButtonState(selectedButton: UIButton) {
        for button in filterButtonCollection {
            if button == selectedButton {
                button.layer.borderWidth = 1
            } else {
                button.layer.borderWidth = 0
            }
        }
    }
    func changeButtonState(isEnabled : Bool){
        if isEnabled{
            addMoneyButton.backgroundColor = ColorManager.primaryColor
            addMoneyButton.setTitleColor(ColorManager.buttonTextColor, for: .normal)
            addMoneyButton.isEnabled = true
        }else{
            addMoneyButton.backgroundColor = ColorManager.thirdBackgroundColor
            addMoneyButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
            addMoneyButton.isEnabled = false
        }
    }
    @IBAction func customAmountPressed(_ sender: UIButton) {
        switch sender.tag{
        case 0:
            amount += 50
        case 1:
            amount += 100
        case 2:
            amount += 200
        case 3:
            amount += 300
        case 4:
            amount += 500
        default:
            break
        }
        moneyTextField.text = "\(amount)"
        textFieldTextChanged()
    }
    
    @IBAction func addMoneyButtonPressed(_ sender: Any) {
        disableButtonWithActivityIndicator(addMoneyButton)
        let amountInPaise = amount * 100
        let currency = "INR"
        viewModel?.createOder(amount: amountInPaise,currency: currency) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let amount = response.amount, let orderId = response.id, let responseCurreny = response.currency{
                        self.openCheckout(amount: String(amount),currency: responseCurreny, orderId: orderId)
                    }
                case .failure(let error):
                    AppErrorHandler.handle(error, in: self)
                    self.enableButtonAndRemoveIndicator(self.addMoneyButton)
                }
            }
        }
    }
    @IBAction func filterButtonPressed(_ sender: UIButton) {
        switch sender.tag{
        case 0:
            configureButtonState(selectedButton: filterButtonCollection[0])
            viewModel?.currentFilter = .all
        case 1:
            configureButtonState(selectedButton: filterButtonCollection[1])
            viewModel?.currentFilter = .charged
        case 2:
            configureButtonState(selectedButton: filterButtonCollection[2])
            viewModel?.currentFilter = .added
        case 3:
            configureButtonState(selectedButton: filterButtonCollection[3])
            viewModel?.currentFilter = .refund
        default :
            break
        }
    }
    
    @objc func textFieldTextChanged(){
        if moneyTextField.text != ""{
            changeButtonState(isEnabled: true)
            if let value = moneyTextField.text{
                self.amount = Int(value) ?? 0
            }
        }else{
            changeButtonState(isEnabled: false)
            amount = 0
        }
    }
}
extension WalletViewController : UITableViewDataSource,UITableViewDelegate{
    func setUpTableView(){
        tableView.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: NoDataTableViewCell.identifier)
        tableView.register(UINib(nibName: "LoadingTableViewCell", bundle: nil), forCellReuseIdentifier: LoadingTableViewCell.idenytifier)
        tableView.register(UINib(nibName: "TransactionTableViewCell", bundle: nil), forCellReuseIdentifier: TransactionTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = viewModel?.filteredTransactions?.count{
            if count == 0{
                return 1
            }
            if let curPage = viewModel?.currentPage,let totPage = viewModel?.totalPage,
               curPage < totPage {
                return count + 1 
            } else {
                return count
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let count = viewModel?.filteredTransactions?.count, !(viewModel?.isLoading ?? false) else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.idenytifier) as? LoadingTableViewCell{
                cell.spinner.startAnimating()
                return cell
            }
            
            return UITableViewCell()
        }
        if count == 0{
            if let cell = tableView.dequeueReusableCell(withIdentifier: NoDataTableViewCell.identifier) as? NoDataTableViewCell{
                return cell
            }
        }
        if indexPath.row < count{
            if let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier) as? TransactionTableViewCell{
                if let transaction = viewModel?.filteredTransactions?[indexPath.row]{
                    cell.configure(with: transaction)
                }
                return cell
            }
        }else{
            if let cell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.idenytifier) as? LoadingTableViewCell{
                cell.spinner.startAnimating()
                return cell
            }
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if viewModel?.isLoading == true { return }
        let transactionCount = viewModel?.filteredTransactions?.count ?? 0
        if indexPath.row == transactionCount - 1 {
            if let curPage = viewModel?.currentPage,let totalPage = viewModel?.totalPage,curPage < totalPage {
                self.fetchWalletStatus(transaction: true,page: curPage + 1,limit: 5,refund: false)
            }
        }
    }
}
extension WalletViewController: RazorpayPaymentCompletionProtocol{
    func openCheckout(amount : String,currency : String, orderId : String) {
        let mobileNumber = UserDefaultManager.shared.getUserProfile()?.phoneNumber ?? ""
        let email = UserDefaultManager.shared.getUserProfile()?.email ?? ""
        let options: [String:Any] = [
            "key" : AppIdentifications.RazorPay.key,
            "amount": amount,
            "currency": currency,
            "description": "Purchase Description",
            "order_id": orderId,
            "name": "CHRGUP",
            "prefill": [
                "contact": mobileNumber,
                "email": email
            ]
        ]
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.razorpay.open(options, displayController: self)
        }
    }
    func onPaymentSuccess(_ payment_id: String) {
        print("Success: \(payment_id)")
        fetchPaymentDetails(paymentId: payment_id)
        enableButtonAndRemoveIndicator(addMoneyButton)
    }
    
    func onPaymentError(_ code: Int32, description str: String) {
        print("Error: \(code) | \(str)")
        enableButtonAndRemoveIndicator(addMoneyButton)
    }
    func fetchPaymentDetails(paymentId : String) {
        viewModel?.fetchPaymentDetails(paymentId: paymentId) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.status == "authorized" {
                        let amount = self.amount * 100
                        self.viewModel?.capturePayment(paymentId: paymentId, amount: amount) { [weak self] result in
                            guard let self = self else { return }
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let response):
                                    self.postPaymentToServer(details: response)
                                case .failure(let error):
                                    AppErrorHandler.handle(error, in: self)
                                }
                            }
                        }
                    }else if response.status == "captured"{
                        self.postPaymentToServer(details: response)
                    }
                case .failure(let error):
                    AppErrorHandler.handle(error, in: self)
                }
            }
        }
    }
    func postPaymentToServer(details : PaymentDetails){
        if let userId = UserDefaultManager.shared.getUserProfile()?.id{
            self.viewModel?.createPaymentOnServer(userId: userId, details: details) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        if response.status{
                            self.moneyTextField.text = ""
                            self.textFieldTextChanged()
                            self.fetchWalletStatus(transaction: true, page: 1, limit: 5, refund: false)
                        }else{
                            self.showAlert(title: "Error", message: response.message)
                        }
                    case .failure(let error):
                        AppErrorHandler.handle(error, in: self)
                    }
                }
            }
        }
    }
}
