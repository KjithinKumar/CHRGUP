//
//  ReserveViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 30/05/25.
//

import UIKit

class ReserveViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chooseTimeLabel: UILabel!
    @IBOutlet weak var chooseChargerTitleLabel: UILabel!
    @IBOutlet weak var ChargercollectionView: UICollectionView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var timeSubTitle: UILabel!
    @IBOutlet weak var reserveButton: UIButton!
    var viewModel : ReserveChargerViewModelInterface?
    var selectedIndexPath: IndexPath?
    var selectedConnector : ConnectorDisplayItem?
    var onReservationSuccess: ((ConnectorDisplayItem) -> Void)?
    @IBOutlet weak var dismissButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUi()
        configureCollectionView()
    }
    init(viewModel : ReserveChargerViewModelInterface){
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUpUi() {
        view.backgroundColor = .clear
        
        titleLabel.text = AppStrings.reserveCharger.reserveChargerTitleText
        titleLabel.font = FontManager.bold(size: 17)
        titleLabel.textColor = ColorManager.textColor
        
        popUpView.backgroundColor = ColorManager.secondaryBackgroundColor
        popUpView.layer.cornerRadius = 10
        popUpView.clipsToBounds = true
        
        chooseChargerTitleLabel.text = AppStrings.reserveCharger.reserveChargerText
        chooseChargerTitleLabel.font = FontManager.regular(size: 15)
        chooseChargerTitleLabel.textColor = ColorManager.placeholderColor
        
        chooseTimeLabel.text = AppStrings.reserveCharger.selectTimeText
        chooseTimeLabel.font = FontManager.regular(size: 15)
        chooseTimeLabel.textColor = ColorManager.placeholderColor
        
        timeSubTitle.text = AppStrings.reserveCharger.timeSubtitleText
        timeSubTitle.font = FontManager.regular()
        timeSubTitle.textColor = ColorManager.textColor
        
        reserveButton.setTitle(AppStrings.reserveCharger.reserveButtonText, for: .normal)
        reserveButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
        reserveButton.titleLabel?.font = FontManager.bold(size: 17)
        reserveButton.imageView?.tintColor = ColorManager.backgroundColor
        reserveButton.backgroundColor = ColorManager.primaryColor
        reserveButton.layer.cornerRadius = 25
        
        dismissButton.imageView?.tintColor = ColorManager.subtitleTextColor
        
        
        guard let _ = selectedIndexPath else{
            setReserveButtonState(isEnable: false)
            return
        }
    }
    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func reserverButtonPressed(_ sender: Any) {
        disableButtonWithActivityIndicator(reserveButton)
        if let selectedConnector = selectedConnector {
            Task{
                do {
                    if let response = try await viewModel?.makeReservation(for: selectedConnector){
                        if response.status{
                            ToastManager.shared.showToast(message: response.message)
                            self.onReservationSuccess?(selectedConnector)
                            self.dismiss(animated: true)
                        }else{
                            self.showAlert(title: "Error", message: response.message)
                        }
                    }
                }catch(let error) {
                    AppErrorHandler.handle(error, in: self)
                    enableButtonAndRemoveIndicator(reserveButton)
                }
            }
        }
    }

    func setReserveButtonState(isEnable : Bool){
        if isEnable {
            reserveButton.backgroundColor = ColorManager.primaryColor
            reserveButton.setTitleColor(ColorManager.buttonTextColor, for: .normal)
            reserveButton.isUserInteractionEnabled = true
        }else{
            reserveButton.backgroundColor = ColorManager.thirdBackgroundColor
            reserveButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
            reserveButton.isUserInteractionEnabled = false
        }
    }

}
extension ReserveViewController : UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    func configureCollectionView(){
        ChargercollectionView.delegate = self
        ChargercollectionView.dataSource = self
        ChargercollectionView.register(UINib(nibName: "ChargersCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ChargersCollectionViewCell.identifier)
        ChargercollectionView.heightAnchor.constraint(equalToConstant: 170).isActive = true
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.sectionInset = .zero
        ChargercollectionView.setCollectionViewLayout(layout, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.connectorItems.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChargersCollectionViewCell.identifier, for: indexPath) as? ChargersCollectionViewCell
        if let connectorDisplay = viewModel?.connectorItems[indexPath.row]{
            cell?.configure(itemsDisplay: connectorDisplay)
            let isSelected = indexPath == selectedIndexPath
            cell?.setSelected(isSelected)
        }
        return cell ?? ChargersCollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 110, height: 180)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let previousSelected = selectedIndexPath
        selectedIndexPath = indexPath
        var indexPathsToReload: [IndexPath] = [indexPath]
        if let previous = previousSelected, previous != indexPath {
            indexPathsToReload.append(previous)
        }
        setReserveButtonState(isEnable: true)
        selectedConnector = viewModel?.connectorItems[indexPath.row]
        collectionView.reloadItems(at: indexPathsToReload)
    }
}
