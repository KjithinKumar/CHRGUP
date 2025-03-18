//
//  FaqCategoryTableViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 16/03/25.
//

import UIKit

class FaqCategoryTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var viewModel : HelpAndSupportViewModelProtocolInterface?
    private var isLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpTableView()
        viewModel?.getFAQCategories()
    }
    func setUpUI(){
        viewModel?.getFAQCategories()
        view.backgroundColor = ColorManager.backgroundColor
        navigationItem.title = "FAQs"
    }

}
extension FaqCategoryTableViewController : UITableViewDataSource, UITableViewDelegate{
    func setUpTableView(){
        tableView.separatorStyle = .none
        tableView.backgroundColor = ColorManager.backgroundColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "FaqCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: FaqCategoryTableViewCell.identifier)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoading ? 5 : viewModel?.faqCategories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard  let cell = tableView.dequeueReusableCell(withIdentifier: FaqCategoryTableViewCell.identifier) as? FaqCategoryTableViewCell else { return UITableViewCell()}
        if isLoading{
            cell.setShimmering(isShimmering: true)
        }else{
            if let title = viewModel?.faqCategories?[indexPath.row]{
                cell.setShimmering(isShimmering: false)
                cell.configure(title: title, indexpath: indexPath)
                
            }
        }
        cell.backgroundColor = ColorManager.backgroundColor
        cell.selectionStyle = .none
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let faqVc = FaqViewController()
        faqVc.viewModel = FAQViewModel(delegate: faqVc, networkManager: NetworkManager())
        faqVc.selectedCategory = viewModel?.faqCategories?[indexPath.row]
        navigationController?.pushViewController(faqVc, animated: true)
    }
}

extension FaqCategoryTableViewController : HelpandSupportViewModelDelegate{
    func faqLoaded() {
        DispatchQueue.main.async{
            self.isLoading = false
            self.tableView.reloadData()
        }
    }
}
