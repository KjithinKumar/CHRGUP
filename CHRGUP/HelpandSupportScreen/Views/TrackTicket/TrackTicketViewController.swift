//
//  TrackTicketViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 01/05/25.
//

import UIKit
import Lottie

class TrackTicketViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel : TrackTicketViewModelInterface?
    var isLoading = true
    private var animationView: LottieAnimationView?
    
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
                self.checkIfEmpty()
                switch result{
                case .success(let response):
                    if response.success{
                        self.isLoading = false
                        self.tableView.reloadData()
                    }else{
                        guard response.message != "No tickets found for your account." else { return }
                        self.showAlert(title: "Error", message: response.message)
                    }
                case .failure(let error):
                    AppErrorHandler.handle(error, in: self)
                }
            }
        })
    }
    func checkIfEmpty(){
        if viewModel?.userTickets == nil{
            tableView.isHidden = true
            animationView?.isHidden = false
            setupLottieAnimation()
        }else{
            tableView.isHidden = false
            animationView?.isHidden = true
        }
    }
    func setupLottieAnimation() {
        animationView = LottieAnimationView(name: "no_data_anim")
        animationView?.translatesAutoresizingMaskIntoConstraints = false
        animationView?.contentMode = .scaleAspectFit
        animationView?.loopMode = .loop
        animationView?.play()
        
        view.addSubview(animationView!)
        NSLayoutConstraint.activate([
            animationView!.centerXAnchor.constraint(equalTo: view.centerXAnchor,constant: 10),
            animationView!.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: -50),
                animationView!.widthAnchor.constraint(equalToConstant: 300),
                animationView!.heightAnchor.constraint(equalToConstant: 300)
        ])
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
