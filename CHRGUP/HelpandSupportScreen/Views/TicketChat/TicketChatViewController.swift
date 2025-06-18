//
//  TicketChatViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 02/05/25.
//

import UIKit

class TicketChatViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topBackView: UIView!
    @IBOutlet weak var bottomBackView: UIView!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var ticketNumberLabel: UILabel!
    @IBOutlet weak var messageTextViewHeightConstraint: NSLayoutConstraint!
    
    var viewModel : TrackTicketViewModelInterface?
    var ticket : TicketModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpTableView()
        observeKeyboardNotifications()
        setUpTopViewData()
        fetchData()
        connectToSocket()
    }
    deinit {
        removeKeyboardNotifications()
        ChatSocketManager.shared.closeConnection()
    }
    
    func setUpUI(){
        navigationItem.title = "Chat"
        
        topBackView.layer.cornerRadius = 8
        topBackView.layer.masksToBounds = true
        topBackView.backgroundColor = ColorManager.secondaryBackgroundColor
        
        view.backgroundColor = ColorManager.backgroundColor
        
        bottomBackView.backgroundColor = .clear
        bottomBackView.translatesAutoresizingMaskIntoConstraints = false
        
        messageTextView.layer.cornerRadius = 20
        messageTextView.layer.masksToBounds = true
        messageTextView.font = FontManager.regular()
        messageTextView.textColor = ColorManager.primaryTextColor
        messageTextView.delegate = self
        messageTextViewHeightConstraint.constant = 40
        messageTextView.backgroundColor = ColorManager.secondaryBackgroundColor
        messageTextView.tintColor = ColorManager.primaryColor
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.textContainerInset = UIEdgeInsets(top: 11, left: 12, bottom: 11, right: 12)
        messageTextView.isScrollEnabled = false
        
        sendMessageButton.imageView?.tintColor = ColorManager.primaryTextColor
        sendMessageButton.backgroundColor = ColorManager.secondaryBackgroundColor
        sendMessageButton.layer.cornerRadius = sendMessageButton.frame.height/2
        sendMessageButton.clipsToBounds = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(gesture)
    }
    func setUpTopViewData(){
        statusLabel.text = ticket?.status
        statusLabel.textColor = ColorManager.subtitleTextColor
        statusLabel.font = FontManager.regular(size: 14)
        if ticket?.status == "In Progress"{
            statusLabel.textColor = ColorManager.primaryTextColor
        }
        
        categoryLabel.text = ticket?.category
        categoryLabel.textColor = ColorManager.subtitleTextColor
        categoryLabel.font = FontManager.regular(size: 14)
        
        titleLabel.text = ticket?.title
        titleLabel.textColor = ColorManager.textColor
        titleLabel.font = FontManager.regular()
        
        dateLabel.textColor = ColorManager.subtitleTextColor
        dateLabel.text = convertDateString(ticket?.createdAt ?? "")
        dateLabel.font = FontManager.regular(size: 14)
        
        ticketNumberLabel.text = ""
        ticketNumberLabel.textColor = ColorManager.subtitleTextColor
        ticketNumberLabel.font = FontManager.regular(size: 14)
        
    }
    func fetchData(){
        guard let ticket = ticket else { return }
        viewModel?.getAllMessages(ticketId: ticket.id) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case.success(let response):
                    if response.status{
                        if response.messages?.last?.message == "Ticket has been resolved."{
                            self.messageInputViewState(isEnabled: false)
                        }else{
                            self.messageInputViewState(isEnabled: true)
                        }
                        self.tableView.reloadData()
                        self.adjustTableViewContentInset()
                        self.scrollToBottom()
                    }else {
                        self.showAlert(title: "Error", message: response.message)
                    }
                case .failure(let error):
                    AppErrorHandler.handle(error, in: self)
                }
            }
        }
    }
    func connectToSocket(){
        guard let userTicket = ticket else { return }
        guard let userdata = UserDefaultManager.shared.getUserProfile() else {return}
        ChatSocketManager.shared.establishConnection(ticketId: userTicket.id, userId: userdata.id)
        ChatSocketManager.shared.observeMessages { [weak self] message in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.viewModel?.appendNewMessage(message)
                self.tableView.reloadData()
                self.scrollToBottom()
                self.adjustTableViewContentInset()
                if message.message == "Ticket has been resolved."{
                    self.messageInputViewState(isEnabled: false)
                }else{
                    self.messageInputViewState(isEnabled: true)
                }
            }
        }
    }
    @IBAction func sendMessageTapped(_ sender: Any) {
        guard let message = messageTextView.text else {return}
        if message != ""{
            ChatSocketManager.shared.sendMessage(message)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.scrollToBottom()
                self.adjustTableViewContentInset()
            }
        }
        messageTextView.text = ""
        textViewDidChange(messageTextView)
    }
}
extension TicketChatViewController: UITableViewDataSource, UITableViewDelegate{
    func setUpTableView(){
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = ColorManager.backgroundColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: ChatTableViewCell.identifier)
        tableView.register(UINib(nibName: "TicketStatusTableViewCell", bundle: nil), forCellReuseIdentifier: TicketStatusTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.groupedMessages.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.groupedMessages[section].messages.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.identifier) as? ChatTableViewCell else{
            return UITableViewCell()
        }

        if let message = viewModel?.groupedMessages[indexPath.section].messages[indexPath.row]{
            if message.message == "Ticket has been resolved." || message.message == "Ticket has been reopened."{
                guard let cell = tableView.dequeueReusableCell(withIdentifier: TicketStatusTableViewCell.identifier) as? TicketStatusTableViewCell else {return UITableViewCell()}
                cell.configure(title: message.message)
                cell.backgroundColor = .clear
                return cell
            }else{
                cell.configure(message: message)
                cell.backgroundColor = .clear
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = viewModel?.groupedMessages[section].date
        label.textColor = ColorManager.subtitleTextColor
        label.font = FontManager.regular(size: 12)
        label.textAlignment = .center
        return label
    }
    func scrollToBottom() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.layoutIfNeeded()
            let lastSection = max(self.tableView.numberOfSections - 1, 0)
            let lastRow = max(self.tableView.numberOfRows(inSection: lastSection) - 1, 0)
            guard lastRow >= 0 else { return }
            let indexPath = IndexPath(row: lastRow, section: lastSection)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    func adjustTableViewContentInset() {
        tableView.layoutIfNeeded()

        let contentHeight = tableView.contentSize.height
        let tableViewHeight = tableView.bounds.height

        let topInset = max(tableViewHeight - contentHeight, 0)
        tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    }
    func messageInputViewState(isEnabled : Bool) {
        messageTextView.isHidden = !isEnabled
        sendMessageButton.isHidden = !isEnabled
        if isEnabled{
            statusLabel.text = "In Progress"
            statusLabel.textColor = ColorManager.primaryTextColor
        }else{
            statusLabel.text = "Resolved"
            statusLabel.textColor = ColorManager.subtitleTextColor
            view.endEditing(true)
        }
        
    }
}

extension TicketChatViewController : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        let maxHeight: CGFloat = 120
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.isScrollEnabled = estimatedSize.height > maxHeight
        messageTextViewHeightConstraint.constant = min(estimatedSize.height, maxHeight)
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    override func moveViewForKeyboard(yOffset: CGFloat) {
        bottomBackView.transform = CGAffineTransform(translationX: 0, y: yOffset)
        tableView.transform = CGAffineTransform(translationX: 0, y: yOffset)
        topBackView.transform = CGAffineTransform(translationX: 0, y: yOffset)
    }
    func convertDateString(_ isoDate: String) -> String? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd/MM/yy"
        displayFormatter.timeZone = TimeZone.current

        if let date = isoFormatter.date(from: isoDate) {
            return displayFormatter.string(from: date)
        } else {
            return nil
        }
    }
}
