//
//  ReceiptViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 16/04/25.
//

import UIKit

class ReceiptViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var viewModel : ReceiptViewModelInterface?
    var isLoading = true
    let indicator = UIActivityIndicatorView(style: .large)
    @IBOutlet weak var payButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchReceipt()
        setUpUI()
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
                            self.payButton.setTitle("Pay \(grandTotal)/-", for: .normal)
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
    
        payButton.setTitle("Pay ₹0.00/-", for: .normal)
        payButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
        payButton.titleLabel?.font = FontManager.bold(size: 17)
        
        payButton.backgroundColor = ColorManager.primaryColor
        payButton.layer.cornerRadius = 20
        payButton.clipsToBounds = true
    }
    @IBAction func payButtonPressed(_ sender: Any) {
    }
}
extension ReceiptViewController : UITableViewDataSource,UITableViewDelegate{
    func setUpTableView(){
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "HeaderTableViewCell", bundle: nil), forCellReuseIdentifier: HeaderTableViewCell.identifier)
        tableView.register(TitleSubtitleTableViewCell.self, forCellReuseIdentifier: TitleSubtitleTableViewCell.identifier)
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
