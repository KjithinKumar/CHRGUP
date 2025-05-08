//
//  TrackTicketViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 01/05/25.
//

import UIKit

class TrackTicketViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel : TrackTicketViewModelInterface?
    var isLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }
    override func viewWillAppear(_ animated: Bool) {
        isLoading = true
        setUpUi()
    }
    func setUpUi(){
        navigationItem.title = "Track Ticket"
        view.backgroundColor = ColorManager.backgroundColor
        
        viewModel?.getAllTickets(completeion: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result{
                case .success(let response):
                    if response.success{
                        self.isLoading = false
                        self.tableView.reloadData()
                    }else{
                        self.showAlert(title: "Error", message: response.message)
                    }
                case .failure(let error):
                    AppErrorHandler.handle(error, in: self)
                }
            }
        })
    }

}
extension TrackTicketViewController:UITableViewDelegate,UITableViewDataSource{
    func setUpTableView(){
        tableView.register(UINib(nibName: "TrackTicketTableViewCell", bundle: nil), forCellReuseIdentifier: TrackTicketTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = ColorManager.backgroundColor
        tableView.separatorStyle = .none
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoading ? 10 : viewModel?.userTickets?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackTicketTableViewCell.identifier) as? TrackTicketTableViewCell else {
            return UITableViewCell()
        }
        if isLoading{
            cell.setShimmering(isShimmering: true)
        }else{
            cell.setShimmering(isShimmering: false)
            if let ticket = viewModel?.userTickets?[indexPath.row]{
                cell.configure(ticket: ticket)
            }
        }
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVc = TicketChatViewController()
        chatVc.viewModel = TrackTicketViewModel(networkManager: NetworkManager())
        chatVc.ticket = viewModel?.userTickets?[indexPath.row]
        navigationController?.pushViewController(chatVc, animated: true)
    }
}
