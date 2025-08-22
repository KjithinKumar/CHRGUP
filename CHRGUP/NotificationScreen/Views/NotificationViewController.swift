//
//  NotificationViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 24/07/25.
//

import UIKit
import Lottie

class NotificationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var viewModel : NotificationViewModelInterface?
    var isLoading : Bool = true
    private var animationView: LottieAnimationView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setupLottieAnimation()
        fetchData()
        setUpTableView()
        animationView?.isHidden = true
    }
    
    func setUpUI(){
        view.backgroundColor = ColorManager.backgroundColor
        navigationItem.title = "Notifications"
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
    
    func checkForData(){
        if viewModel?.notifications?.count ?? 0 == 0{
            tableView.isHidden = true
            animationView?.isHidden = false
        } else {
            tableView.isHidden = false
            animationView?.isHidden = true
        }
    }
    
    func fetchData(){
        isLoading = true
        Task {
            do {
                if let response = try await self.viewModel?.fetchNotification() {
                    if response.status{
                        self.isLoading = false
                        self.tableView.reloadData()
                    }
                }
            }catch(let error){
                AppErrorHandler.handle(error, in: self)
            }
            checkForData()
        }
    }
}

extension NotificationViewController : UITableViewDataSource{
    func setUpTableView(){
        tableView.dataSource = self
        tableView.register(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: NotificationTableViewCell.identifier)
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoading ? 10 : viewModel?.notifications?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier) as? NotificationTableViewCell else { return UITableViewCell()}
        if isLoading {
            cell.setShimmering(isShimmering: true)
        }else{
            cell.setShimmering(isShimmering: false)
            if let notifications = viewModel?.notifications?[indexPath.row]{
                cell.configure(with: notifications)
            }
        }
        return cell
    }
}
