//
//  HelpandSupportViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 15/03/25.
//

import UIKit

class HelpandSupportViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    let fields : [HelpAndSupportModel] = [HelpAndSupportModel(title: "Frequently Asked Questions", image: "questionmark.circle", type: .faq),
                                          HelpAndSupportModel(title: "Call Us", image: "phone.connection", type: .contactUs)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpTableView()
    }
    func setUpUI(){
        tableView.backgroundColor = ColorManager.backgroundColor
        view.backgroundColor = ColorManager.backgroundColor
        navigationItem.title = "Help & Support"
    }

}

extension HelpandSupportViewController: UITableViewDataSource, UITableViewDelegate{
    func setUpTableView(){
        tableView.register(UINib(nibName: "HelpandSupportTableViewCell", bundle: nil), forCellReuseIdentifier: HelpandSupportTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HelpandSupportTableViewCell.identifier) as? HelpandSupportTableViewCell
        let title = fields[indexPath.row].title
        let imageName = fields[indexPath.row].image
        let type = fields[indexPath.row].type
        cell?.configure(title: title, image: imageName, type: type,delegate: self)
        cell?.backgroundColor = ColorManager.backgroundColor
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 175
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = fields[indexPath.row].type
        switch type{
        case .faq:
            let faqCategoryVc = FaqCategoryTableViewController()
            faqCategoryVc.viewModel = HelpAndSupportViewModel(networkManager: NetworkManager(), delegate: faqCategoryVc)
            navigationController?.pushViewController(faqCategoryVc, animated: true)
        case .contactUs:
            print()
        }
    }
    
}
extension HelpandSupportViewController: HelpandSupportDelegate{
    func didSelectHelpandSupport(type: HelpAndSupportType) {
        switch type{
        case .faq:
            let faqCategoryVc = FaqCategoryTableViewController()
            faqCategoryVc.viewModel = HelpAndSupportViewModel(networkManager: NetworkManager(), delegate: faqCategoryVc)
            navigationController?.pushViewController(faqCategoryVc, animated: true)
        case .contactUs:
            print()
        }
    }
}
