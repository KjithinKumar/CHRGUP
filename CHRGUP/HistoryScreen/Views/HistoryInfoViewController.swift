//
//  HistoryInfoViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 15/04/25.
//

import UIKit
import QuickLook

class HistoryInfoViewController: UIViewController, QLPreviewControllerDataSource {
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var paymentStatusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bottomview: UIView!
    @IBOutlet weak var titleOneLabel: UILabel!
    @IBOutlet weak var SubtitleOneLabel: UILabel!
    @IBOutlet weak var titleTwoLabel: UILabel!
    @IBOutlet weak var SubtitleTwoLabel: UILabel!
    @IBOutlet weak var titleThreeLabel: UILabel!
    @IBOutlet weak var subtitleThreeLabel: UILabel!
    @IBOutlet weak var titlefourLabel: UILabel!
    @IBOutlet weak var subtitleFourLabel: UILabel!
    @IBOutlet weak var titleFiveLabel: UILabel!
    @IBOutlet weak var subtitleFiveLabel: UILabel!
    @IBOutlet weak var titleSixLabel: UILabel!
    @IBOutlet weak var subtitleSixLabel: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    var pdfURLToPreview: URL?
    var historyInfo : HistoryModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUprightNavigationBar()
    }
    func setUpUI(){
        view.backgroundColor = ColorManager.backgroundColor
        
        navigationItem.title = AppStrings.History.receiptTitle
        
        bottomview.backgroundColor = ColorManager.secondaryBackgroundColor
        bottomview.layer.cornerRadius = 10
        
        LocationLabel.text = historyInfo?.locationName
        LocationLabel.textColor = ColorManager.textColor
        LocationLabel.font = FontManager.bold(size: 19)
        
        addressLabel.text = historyInfo?.address
        addressLabel.textColor = ColorManager.subtitleTextColor
        addressLabel.font = FontManager.light()
        
        priceLabel.text = historyInfo?.paymentAmount
        priceLabel.textColor = ColorManager.textColor
        priceLabel.font = FontManager.bold(size: 18)
        
        if historyInfo?.paymentStatus == "captured"{
            statusImageView.image = UIImage(named: "Completed")
            paymentStatusLabel.text = AppStrings.History.completedText
            paymentStatusLabel.textColor = ColorManager.primaryTextColor
            
        }else{
            statusImageView.image = UIImage(named: "Pending")
            paymentStatusLabel.text = AppStrings.History.failed
            paymentStatusLabel.textColor = ColorManager.pendingColor
        }
        paymentStatusLabel.font = FontManager.regular()
        
        if let chargeStart = historyInfo?.createdAt{
            timeLabel.text = formatDate(chargeStart)
        }
        timeLabel.textColor = ColorManager.textColor
        timeLabel.font = FontManager.regular()
        
        titleOneLabel.text = AppStrings.History.chargerIdText
        titleOneLabel.textColor = ColorManager.subtitleTextColor
        titleOneLabel.font = FontManager.regular()
        
        SubtitleOneLabel.text = historyInfo?.chargerName
        SubtitleOneLabel.textColor = ColorManager.textColor
        SubtitleOneLabel.font = FontManager.regular()
        
        titleTwoLabel.text = AppStrings.History.chargingTypeText
        titleTwoLabel.textColor = ColorManager.subtitleTextColor
        titleTwoLabel.font = FontManager.regular()
        
        let text = "\(historyInfo?.chargerType ?? "") - \(historyInfo?.powerOutput ?? "")"
        SubtitleTwoLabel.text = text
        SubtitleTwoLabel.textColor = ColorManager.textColor
        SubtitleTwoLabel.font = FontManager.regular()
        if historyInfo?.chargerType == "DC"{
            typeImageView.image = UIImage(named: "dc")
        }else{
            typeImageView.image = UIImage(named: "ac")
        }
        
        titleThreeLabel.text = AppStrings.History.trasactionIdText
        titleThreeLabel.textColor = ColorManager.subtitleTextColor
        titleThreeLabel.font = FontManager.regular()
        
        subtitleThreeLabel.text = "N/A"
        if let transactionId = historyInfo?.transactionId{
            subtitleThreeLabel.text = transactionId
        }
        subtitleThreeLabel.textColor = ColorManager.textColor
        subtitleThreeLabel.font = FontManager.regular()
        
        titlefourLabel.text = AppStrings.History.energyConsumedText
        titlefourLabel.textColor = ColorManager.subtitleTextColor
        titlefourLabel.font = FontManager.regular()
        
        subtitleFourLabel.text = historyInfo?.energyConsumed
        subtitleFourLabel.textColor = ColorManager.textColor
        subtitleFourLabel.font = FontManager.regular()
        
        titleFiveLabel.text = AppStrings.History.chargingTimeText
        titleFiveLabel.textColor = ColorManager.subtitleTextColor
        titleFiveLabel.font = FontManager.regular()
        
        subtitleFiveLabel.text = historyInfo?.chargeTime
        subtitleFiveLabel.textColor = ColorManager.textColor
        subtitleFiveLabel.font = FontManager.regular()
        
        titleSixLabel.text = AppStrings.History.paymentMethodText
        titleSixLabel.textColor = ColorManager.subtitleTextColor
        titleSixLabel.font = FontManager.regular()
        
        subtitleSixLabel.text = historyInfo?.paymentMethod
        subtitleSixLabel.textColor = ColorManager.textColor
        subtitleSixLabel.font = FontManager.regular()
    }
    func formatDate(_ isoString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = isoFormatter.date(from: isoString) else {
            return isoString // fallback in case of failure
        }

        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        displayFormatter.locale = Locale(identifier: "en_US_POSIX")

        return displayFormatter.string(from: date)
    }
    var downloadButton: UIBarButtonItem?

    func setUprightNavigationBar() {
        if historyInfo?.invoice != nil {
            let button = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"), style: .plain, target: self, action: #selector(downloadTapped))
            downloadButton = button
            navigationItem.rightBarButtonItem = button
        }
    }
    @objc func downloadTapped() {
        showSpinnerInNavigationBar()
        if let pdfUrl = historyInfo?.invoice{
            downloadFromURL(url: pdfUrl)
        }
    }
    func showSpinnerInNavigationBar() {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()

        // Center in container view
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        spinner.center = container.center
        container.addSubview(spinner)

        let spinnerItem = UIBarButtonItem(customView: container)
        navigationItem.rightBarButtonItem = spinnerItem
    }
    func restoreDownloadButton() {
        navigationItem.rightBarButtonItem = downloadButton
    }
    func downloadFromURL(url : String){
        guard let url = URL(string: url) else {
            return
        }
        let fileName = url.lastPathComponent
        let task = URLSession.shared.downloadTask(with: url){ [weak self] tempUrl, response, error in
            guard let self = self else {return}
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
            guard let tempURL = tempUrl else {
                return
            }
            let fileManager = FileManager.default
            let destinationURL = fileManager.temporaryDirectory.appendingPathComponent(fileName)
            
            try? fileManager.removeItem(at: destinationURL)
            
            do {
                try fileManager.copyItem(at: tempURL, to: destinationURL)
                
                DispatchQueue.main.async{ [weak self] in
                    guard let self = self else { return }
                    self.previewFile(at: destinationURL)
                }
            } catch {
                print("File copy failed: \(error)")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.restoreDownloadButton()
            }
        }
        task.resume()
    }
    func previewFile(at url: URL) {
        pdfURLToPreview = url
        let previewController = QLPreviewController()
        previewController.dataSource = self
        navigationController?.pushViewController(previewController, animated: true)
    }

    // MARK: - QLPreviewControllerDataSource
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return pdfURLToPreview! as NSURL
    }
}

