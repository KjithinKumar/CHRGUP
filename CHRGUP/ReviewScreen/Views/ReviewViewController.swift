//
//  ReviewViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 09/04/25.
//

import UIKit

class ReviewViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var subtitleOne: UILabel!
    @IBOutlet weak var subtitleTwo: UILabel!
    @IBOutlet weak var starOneView: UIView!
    @IBOutlet weak var starTwoView: UIView!
    @IBOutlet weak var commentsTitle: UILabel!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var spacerView: UIView!
    @IBOutlet weak var spacerTwo: UIView!
    let ratingViewOne = RatingView()
    let ratingViewTwo = RatingView()
    private var ratingOne: Int?
    private var ratingTwo: Int?
    
    var viewModel : ReviewViewModelInterface?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        observeKeyboardNotifications()
        navigationController?.navigationBar.isHidden = true
    }
    deinit {
        removeKeyboardNotifications()
    }
    func setUpUI(){
        view.backgroundColor = ColorManager.backgroundColor
        backView.backgroundColor = ColorManager.backgroundColor
        
        titleLabel.text = AppStrings.Review.title
        titleLabel.textColor = ColorManager.primaryTextColor
        titleLabel.font = FontManager.bold(size: 24)
        
        subtitleLabel.text = AppStrings.Review.subtitle
        subtitleLabel.textColor = ColorManager.subtitleTextColor
        subtitleLabel.font = FontManager.light()
        
        subtitleOne.textColor = ColorManager.textColor
        subtitleOne.font = FontManager.bold(size: 17)
        subtitleOne.text = AppStrings.Review.subtitleOne
        
        
        starOneView.backgroundColor = ColorManager.backgroundColor
        
        ratingViewOne.translatesAutoresizingMaskIntoConstraints = false
        starOneView.addSubview(ratingViewOne)
        NSLayoutConstraint.activate([
            ratingViewOne.leadingAnchor.constraint(equalTo: starOneView.leadingAnchor,constant: 20),
            ratingViewOne.trailingAnchor.constraint(equalTo: starOneView.trailingAnchor,constant: -20),
            ratingViewOne.topAnchor.constraint(equalTo: starOneView.topAnchor),
            ratingViewOne.bottomAnchor.constraint(equalTo: starOneView.bottomAnchor),
            ratingViewOne.heightAnchor.constraint(equalToConstant: 50)
        ])
        ratingViewOne.onRatingSelected = { [weak self] rating in
            self?.ratingOne = rating
            self?.checkIfBothRatingsSelected()
        }
        
        starTwoView.backgroundColor = ColorManager.backgroundColor
        
        ratingViewTwo.translatesAutoresizingMaskIntoConstraints = false
        starTwoView.addSubview(ratingViewTwo)
        NSLayoutConstraint.activate([
            ratingViewTwo.leadingAnchor.constraint(equalTo: starTwoView.leadingAnchor,constant: 20),
            ratingViewTwo.trailingAnchor.constraint(equalTo: starTwoView.trailingAnchor,constant: -20),
            ratingViewTwo.topAnchor.constraint(equalTo: starTwoView.topAnchor),
            ratingViewTwo.bottomAnchor.constraint(equalTo: starTwoView.bottomAnchor),
            ratingViewTwo.heightAnchor.constraint(equalToConstant: 50)
        ])
        ratingViewTwo.onRatingSelected = { [weak self] rating in
            self?.ratingTwo = rating
            self?.checkIfBothRatingsSelected()
        }
        
        subtitleTwo.textColor = ColorManager.textColor
        subtitleTwo.font = FontManager.bold(size: 17)
        subtitleTwo.text = AppStrings.Review.subtitleTwo
        
        commentsTitle.text = AppStrings.Review.commentsText
        commentsTitle.textColor = ColorManager.textColor
        commentsTitle.font = FontManager.bold(size: 17)
        
        commentsTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        commentsTextView.backgroundColor = ColorManager.secondaryBackgroundColor
        commentsTextView.layer.cornerRadius = 8
        commentsTextView.layer.borderWidth = 2
        commentsTextView.layer.borderColor = ColorManager.thirdBackgroundColor.cgColor
        commentsTextView.textColor = ColorManager.primaryTextColor
        commentsTextView.tintColor = ColorManager.primaryTextColor
        commentsTextView.clipsToBounds = true
        
        submitButton.titleLabel?.font = FontManager.bold(size: 18)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
        submitButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        submitButton.layer.cornerRadius = 20
        configureSubmitButton(isEnable: false)
        
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(ColorManager.primaryTextColor, for: .normal)
        skipButton.backgroundColor = .clear
        skipButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        spacerView.backgroundColor = ColorManager.backgroundColor
        spacerTwo.backgroundColor = ColorManager.backgroundColor
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(keyboardWillHide))
        view.addGestureRecognizer(gesture)
        scrollView.isScrollEnabled = false
        
    }
    func configureSubmitButton(isEnable : Bool) {
        if isEnable{
            submitButton.isEnabled = true
            submitButton.backgroundColor = ColorManager.primaryColor
            submitButton.setTitleColor(ColorManager.buttonTextColor, for: .normal)
        }else{
            submitButton.isEnabled = false
            submitButton.backgroundColor = ColorManager.secondaryBackgroundColor
            submitButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
        }
    }
    private func checkIfBothRatingsSelected() {
        if let _ = ratingOne, let _ = ratingTwo {
            configureSubmitButton(isEnable: true)
        } else {
            configureSubmitButton(isEnable: false)
        }
    }
    
    override func moveViewForKeyboard(yOffset: CGFloat) {
        scrollView.isScrollEnabled = true
        scrollView.contentOffset.y = -(yOffset-20)
        
        scrollView.contentInset.bottom = -yOffset - 20
        scrollView.verticalScrollIndicatorInsets.bottom = -yOffset - 20
    }
    @objc func keyboardWillHide() {
        dismissKeyboard()
        UIView.animate(withDuration: 0.2) {
            self.scrollView.contentOffset.y = 0
            self.scrollView.contentInset.bottom = 0
            self.scrollView.verticalScrollIndicatorInsets.bottom = 0
            self.view.layoutIfNeeded()
        }
        scrollView.isScrollEnabled = false
        
    }
    @IBAction func submitButtonPressed(_ sender: Any) {
        disableButtonWithActivityIndicator(submitButton)
        keyboardWillHide()
        let chargingExp = ratingViewOne.selectedIndex + 1
        let locationExp = ratingViewTwo.selectedIndex + 1
        let comment = commentsTextView.text ?? ""
        viewModel?.submitReview(charging: chargingExp, location: locationExp, comments: comment) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async{
                switch result {
                case .success(let response):
                    ToastManager.shared.showToast(message: response.message ?? "Success")
                    UserDefaultManager.shared.deleteScannedLocationId()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                        self.dismiss(animated: true)
                    }
                case .failure(let error):
                    AppErrorHandler.handle(error, in: self)
                    self.enableButtonAndRemoveIndicator(self.submitButton)
                }
            }
        }
    }
    @IBAction func skipButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}
