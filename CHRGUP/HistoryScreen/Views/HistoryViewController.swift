//
//  HistoryViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 15/04/25.
//

import UIKit
import Lottie

class HistoryViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var acButton: UIButton!
    @IBOutlet weak var dcButton: UIButton!
    private var animationView: LottieAnimationView?
    var viewModel : HistoryViewModelInterface?
    private var isLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpTableView()
        fetchData()
        configureButtonState(uiButton: allButton)
        setupLottieAnimation()
        animationView?.isHidden = true
    }
    @IBAction func allButtonPressed(_ sender: Any) {
        configureButtonState(uiButton: allButton)
        viewModel?.currentFilter = .all
    }
    @IBAction func acButtonPresseed(_ sender: Any) {
        configureButtonState(uiButton: acButton)
        viewModel?.currentFilter = .ac
    }
    @IBAction func dcButtonPressed(_ sender: Any) {
        configureButtonState(uiButton: dcButton)
        viewModel?.currentFilter = .dc
    }
    func setUpUI(){
        view.backgroundColor = ColorManager.backgroundColor

        navigationItem.title = "History"
        let acBullet = UIView()
        acBullet.backgroundColor = ColorManager.acbulletColor
        acBullet.layer.cornerRadius = 5
        acBullet.clipsToBounds = true
        acBullet.translatesAutoresizingMaskIntoConstraints = false
        acButton.addSubview(acBullet)
        NSLayoutConstraint.activate([
            acBullet.leadingAnchor.constraint(equalTo: acButton.leadingAnchor, constant: 10),
            acBullet.centerYAnchor.constraint(equalTo: acButton.centerYAnchor),
            acBullet.widthAnchor.constraint(equalToConstant: 10),
            acBullet.heightAnchor.constraint(equalToConstant: 10)
        ])
        acButton.setTitle("       AC Charger   ", for: .normal)
        acButton.setTitleColor(ColorManager.subtitleTextColor, for: .normal)
        acButton.backgroundColor = ColorManager.secondaryBackgroundColor
        acButton.layer.cornerRadius = 10
        acButton.clipsToBounds = true
        acButton.layer.borderColor = ColorManager.acbulletColor.cgColor
        acButton.titleLabel?.font = FontManager.light()
        
        let dcBullet = UIView()
        dcBullet.backgroundColor = ColorManager.dcbulletColor
        dcBullet.layer.cornerRadius = 5
        dcBullet.clipsToBounds = true
        dcBullet.translatesAutoresizingMaskIntoConstraints = false
        dcButton.addSubview(dcBullet)
        NSLayoutConstraint.activate([
            dcBullet.leadingAnchor.constraint(equalTo: dcButton.leadingAnchor, constant: 10),
            dcBullet.centerYAnchor.constraint(equalTo: dcButton.centerYAnchor),
            dcBullet.widthAnchor.constraint(equalToConstant: 10),
            dcBullet.heightAnchor.constraint(equalToConstant: 10)
        ])
        dcButton.setTitle("       DC Charger   ", for: .normal)
        dcButton.setTitleColor(ColorManager.subtitleTextColor, for: .normal)
        dcButton.backgroundColor = ColorManager.secondaryBackgroundColor
        dcButton.layer.cornerRadius = 10
        dcButton.clipsToBounds = true
        dcButton.layer.borderColor = ColorManager.dcbulletColor.cgColor
        dcButton.titleLabel?.font = FontManager.light()
        
        allButton.setTitle("    All    ", for: .normal)
        allButton.layer.cornerRadius = 10
        allButton.backgroundColor = ColorManager.secondaryBackgroundColor
        allButton.setTitleColor(ColorManager.subtitleTextColor, for: .normal)
        allButton.clipsToBounds = true
        allButton.layer.borderColor = ColorManager.textColor.cgColor
        allButton.titleLabel?.font = FontManager.light()
    }

    func configureButtonState(uiButton: UIButton){
        if uiButton == allButton{
            dcButton.layer.borderWidth = 0
            acButton.layer.borderWidth = 0
            allButton.layer.borderWidth = 1
        }else if uiButton == acButton{
            allButton.layer.borderWidth = 0
            dcButton.layer.borderWidth = 0
            acButton.layer.borderWidth = 1
        }else if uiButton == dcButton{
            allButton.layer.borderWidth = 0
            acButton.layer.borderWidth = 0
            dcButton.layer.borderWidth = 1
        }
    }
    func fetchData(){
        viewModel?.onDataChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.tableView.reloadData()
                self?.checkForEmptyState()
            }
        }
        viewModel?.fetchHistory { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case.success(let response):
                    if response.status{
                        self.isLoading = false
                        self.tableView.reloadData()
                    }else{
                        self.checkForEmptyState()
                        self.showAlert(title: "Error", message: response.message)
                    }
                case.failure(let error):
                    AppErrorHandler.handle(error, in: self)
                }
            }
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
       
    func checkForEmptyState() {
        if viewModel?.filteredChargers.count == 0 {
            tableView.isHidden = true
            animationView?.isHidden = false
        } else {
            tableView.isHidden = false
            animationView?.isHidden = true
        }
    }
}
extension HistoryViewController : UITableViewDataSource, UITableViewDelegate {
    func setUpTableView(){
        tableView.backgroundColor = ColorManager.backgroundColor
        tableView.register(UINib(nibName: "HistoryTableViewCell", bundle: nil), forCellReuseIdentifier: HistoryTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoading ? 10 : viewModel?.filteredChargers.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.identifier, for: indexPath) as? HistoryTableViewCell else {return UITableViewCell()}
        if isLoading{
            cell.setShimmer(isShimmering: true)
        }else{
            if let data = viewModel?.filteredChargers[indexPath.row] {
                cell.setShimmer(isShimmering: false)
                cell.configure(chargingInfo: data)
            }
        }
        cell.backgroundColor = ColorManager.backgroundColor
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .none)
        if let data = viewModel?.filteredChargers[indexPath.row] {
            let infoVc = HistoryInfoViewController()
            infoVc.historyInfo = data
            navigationController?.pushViewController(infoVc, animated: true)
        }
    }
}
