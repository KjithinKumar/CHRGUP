//
//  ReceiptViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 16/04/25.
//

import UIKit
import Razorpay

class ReceiptViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var viewModel : ReceiptViewModelInterface?
    var isLoading = true
    let indicator = UIActivityIndicatorView(style: .large)
    @IBOutlet weak var payButton: UIButton!
    
    
    var grandTotal: Int?
    var currencySymbol : String?
    var razorpay: RazorpayCheckout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchReceipt()
        setUpUI()
        disableButtonWithActivityIndicator(payButton)
        razorpay = RazorpayCheckout.initWithKey(AppIdentifications.RazorPay.key, andDelegate: self)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if isLoading{
            indicator.color = ColorManager.primaryColor
            indicator.startAnimating()
            view.addSubview(indicator)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
    }
    func fetchReceipt(){
        viewModel?.fetchReceiptData { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.status{
                        if let grandTotal = self.viewModel?.receiptData?.grandTotal{
                            let splitString = grandTotal.split(separator: " ")
                            self.currencySymbol = String(splitString[0])
                            self.grandTotal = Int((Double(splitString[1]) ?? 0.0) * 100)
                            self.enableButtonAndRemoveIndicator(self.payButton)
                            //self.payButton.setTitle("Pay \(grandTotal)/-", for: .normal)
                        }
                        self.isLoading = false
                        self.setUpTableView()
                        self.indicator.removeFromSuperview()
                        self.tableView.reloadData()
                    }else{
                        self.showAlert(title: "Error", message: response.message)
                    }
                case .failure(let error):
                    AppErrorHandler.handle(error, in: self)
                }
            }
        }
    }
    func setUpUI(){
        navigationItem.title = "Summary"
        view.backgroundColor = ColorManager.secondaryBackgroundColor
        tableView.backgroundColor = .clear
    
        //payButton.setTitle("Pay 0.00/-", for: .normal)
        payButton.setTitle("Done", for: .normal)
        payButton.setTitleColor(ColorManager.buttonTextColor, for: .normal)
        payButton.titleLabel?.font = FontManager.bold(size: 17)
        
        payButton.backgroundColor = ColorManager.primaryColor
        payButton.layer.cornerRadius = 20
        payButton.clipsToBounds = true
    }
    @IBAction func payButtonPressed(_ sender: Any) {
//        disableButtonWithActivityIndicator(payButton)
//        let amountInPaise = grandTotal ?? 00
//        let currency = getCurrencyFromSymbol(currencySymbol ?? "₹")
//        viewModel?.createOder(amount: amountInPaise,currency: currency) { [weak self] result in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let response):
//                    if let amount = response.amount, let orderId = response.id, let responseCurreny = response.currency{
//                        self.openCheckout(amount: String(amount),currency: responseCurreny, orderId: orderId)
//                    }
//                case .failure(let error):
//                    AppErrorHandler.handle(error, in: self)
//                    self.enableButtonAndRemoveIndicator(self.payButton)
//                }
//            }
//        }
        disableButtonWithActivityIndicator(payButton)
        checkIfReviewed()
    }
}
extension ReceiptViewController : UITableViewDataSource,UITableViewDelegate{
    func setUpTableView(){
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "HeaderTableViewCell", bundle: nil), forCellReuseIdentifier: HeaderTableViewCell.identifier)
        tableView.register(UINib(nibName: "TitleSubtitleTableViewCell", bundle: nil), forCellReuseIdentifier: TitleSubtitleTableViewCell.identifier)
        tableView.register(UINib(nibName: "EnergyTableViewCell", bundle: nil), forCellReuseIdentifier: EnergyTableViewCell.identfiier)
        tableView.register(UINib(nibName: "GrandTableViewCell", bundle: nil), forCellReuseIdentifier: GrandTableViewCell.identifier)
        tableView.register(UINib(nibName: "DividerTableViewCell", bundle: nil), forCellReuseIdentifier: DividerTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.receiptList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = viewModel?.receiptList?[indexPath.row]
        switch data{
        case .header(let headerData):
            guard let cell  = tableView.dequeueReusableCell(withIdentifier: HeaderTableViewCell.identifier, for: indexPath) as? HeaderTableViewCell else { return HeaderTableViewCell()}
            cell.configure(headerDetails: headerData)
            cell.backgroundColor = ColorManager.backgroundColor
            return cell
        case .sessionDetails(let sessiondetail):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleSubtitleTableViewCell.identifier,for: indexPath) as? TitleSubtitleTableViewCell else { return TitleSubtitleTableViewCell()}
            cell.configure(details: sessiondetail)
            cell.backgroundColor = .clear
            return cell
        case .energyDetails(let energydetail):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EnergyTableViewCell.identfiier,for: indexPath) as? EnergyTableViewCell else { return EnergyTableViewCell()}
            cell.configure(energy: energydetail)
            cell.backgroundColor = .clear
            return cell
        case .subtotalDetails(let subtotal):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleSubtitleTableViewCell.identifier,for: indexPath) as? TitleSubtitleTableViewCell else { return TitleSubtitleTableViewCell()}
            cell.configure(details: subtotal)
            cell.backgroundColor = .clear
            return cell
        case .sessionCharges(let session):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleSubtitleTableViewCell.identifier,for: indexPath) as? TitleSubtitleTableViewCell else { return TitleSubtitleTableViewCell()}
            cell.configure(details: session)
            cell.backgroundColor = .clear
            return cell
        case .taxDetails( let taxDetails):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleSubtitleTableViewCell.identifier, for: indexPath) as?
                    TitleSubtitleTableViewCell else { return TitleSubtitleTableViewCell()}
            cell.configure(details: taxDetails)
            cell.backgroundColor = .clear
            return cell
        case .grandTotal( value: let grandTotal):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: GrandTableViewCell.identifier,for: indexPath) as?
                    GrandTableViewCell else { return GrandTableViewCell()}
            cell.configure(total: grandTotal)
            cell.backgroundColor = .clear
            return cell
        case .solidDivider(let style):
            switch style {
            case .solid:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: DividerTableViewCell.identifier, for: indexPath) as?
                        DividerTableViewCell else { return DividerTableViewCell()}
                cell.configure(style: .solid)
                cell.backgroundColor = .clear
                return cell
            case .dotted:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: DividerTableViewCell.identifier, for: indexPath) as?
                        DividerTableViewCell else { return DividerTableViewCell()}
                cell.configure(style: .dotted)
                cell.backgroundColor = .clear
                return cell
            }
        default :
            return UITableViewCell()
        }
    }
    
}
extension ReceiptViewController: RazorpayPaymentCompletionProtocol{
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
    }
    
    func onPaymentError(_ code: Int32, description str: String) {
        print("Error: \(code) | \(str)")
        enableButtonAndRemoveIndicator(payButton)
    }
    func fetchPaymentDetails(paymentId : String) {
        viewModel?.fetchPaymentDetails(paymentId: paymentId) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.status == "authorized" {
                        let amount = self.grandTotal ?? 0
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
        if let sessionId = UserDefaultManager.shared.getSessionId(){
            self.viewModel?.createPaymentOnServer(sessionId: sessionId, details: details) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        if response.status{
                            self.checkIfReviewed()
                            UserDefaultManager.shared.removeChargerId()
                            UserDefaultManager.shared.deleteSessionDetails()
                            UserDefaultManager.shared.deleteSessionStartTime()
                            ToastManager.shared.showToast(message: "Payment Successful")
                            iOSWatchSessionManger.shared.sendStatusToWatch()
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
    func checkIfReviewed(){
        self.viewModel?.checkReviewforLocation { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case.success(let response):
                    if response.success{
                        if response.hasReviewed ?? true{
                            UserDefaultManager.shared.deleteScannedLocationId()
                            self.dismiss(animated: true)
                        }else{
                            let reviewVc = ReviewViewController()
                            reviewVc.viewModel = ReviewViewModel(networkManager: NetworkManager.shared)
                            self.navigationController?.setViewControllers([reviewVc], animated: true)
                        }
                    }else{
                        self.showAlert(title: "Error", message: response.message)
                    }
                case .failure(let error):
                    AppErrorHandler.handle(error, in: self)
                }
                self.enableButtonAndRemoveIndicator(self.payButton)
            }
        }
    }
    func getCurrencyFromSymbol(_ currencyCode: String = "₹") -> String {
        switch currencyCode.uppercased() {
        case "₹":
            return "INR" // Indian Rupee
        case "$":
            return "USD" // US Dollar
        case "€":
            return "EUR" // Euro
        case "£":
            return "GBP" // British Pound
        case "¥":
            return "JPY" // Japanese Yen
//        case "¥":
//            return "CNY" // Chinese Yuan
        case "AUD":
            return "A$" // Australian Dollar
        case "C$":
            return "CAD" // Canadian Dollar
        case "د.إ":
            return "AED" // UAE Dirham
        case "CHF":
            return "CHF" // Swiss Franc
        case "R":
            return "ZAR" // South African Rand
        case "S$":
            return "SGD" // Singapore Dollar
        case "₿":
            return "BTC" // Bitcoin
        default:
            return currencyCode // fallback to code itself
        }
    }
}
