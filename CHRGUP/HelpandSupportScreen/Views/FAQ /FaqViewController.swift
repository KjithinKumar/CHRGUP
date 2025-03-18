//
//  FaqViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 16/03/25.
//

import UIKit

class FaqViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var viewModel : FAQViewModelInterface?
    private var isLoading : Bool = true
    private var expandedIndexSet: Set<Int> = []
    
    var selectedCategory : String?
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        setUpTableView()
        
    }
    func setUpUI() {
        view.backgroundColor = ColorManager.backgroundColor
        if let selectedCategory = selectedCategory {
            navigationItem.title = selectedCategory
            viewModel?.loadFAQs(category: selectedCategory)
        }
    }
}
extension FaqViewController : UITableViewDelegate, UITableViewDataSource {
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "FaqTableViewCell", bundle: nil), forCellReuseIdentifier: FaqTableViewCell.identifier)
        tableView.backgroundColor = ColorManager.backgroundColor
        tableView.separatorStyle = .none
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoading ? 10 : viewModel?.FAQs?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FaqTableViewCell.identifier) as? FaqTableViewCell else
        {return UITableViewCell()}
        if isLoading {
            cell.setShimmer(isShimmer: true)
        }else{
            if let question = viewModel?.FAQs?[indexPath.row].question, let answer = viewModel?.FAQs?[indexPath.row].answer {
                let isExpanded = expandedIndexSet.contains(indexPath.row)
                cell.configure(question: question, answer: answer, isExpanded: isExpanded)
                cell.setShimmer(isShimmer: false)
            }
            
        }
        cell.backgroundColor = ColorManager.backgroundColor
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if expandedIndexSet.contains(indexPath.row) {
            expandedIndexSet.remove(indexPath.row) // Collapse
        } else {
            expandedIndexSet.insert(indexPath.row) // Expand
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
}
extension FaqViewController : FAQViewModelDelegate {
    func loadedFAQs() {
        DispatchQueue.main.async {
            self.isLoading = false
            self.tableView.reloadData()
        }
    }
}
