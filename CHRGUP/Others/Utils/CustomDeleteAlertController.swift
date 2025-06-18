//
//  CustomDeleteAlertController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 18/03/25.
//


import UIKit
import SDWebImage

class CustomDeleteAlertController: UIViewController {

    var vehicleImageURL: String
    var vehicleName: String
    var deleteAction: (() -> Void)?

    init(vehicleImageURL: String, vehicleName: String, deleteAction: @escaping () -> Void) {
        self.vehicleImageURL = vehicleImageURL
        self.vehicleName = vehicleName
        self.deleteAction = deleteAction
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)

        let alertView = UIView()
        alertView.backgroundColor = ColorManager.backgroundColor
        alertView.layer.cornerRadius = 10
        alertView.translatesAutoresizingMaskIntoConstraints = false

        let vehicleImageView = UIImageView()
        vehicleImageView.contentMode = .scaleAspectFit
        vehicleImageView.layer.cornerRadius = 10
        vehicleImageView.clipsToBounds = true
        vehicleImageView.translatesAutoresizingMaskIntoConstraints = false
        if let url = URL(string: vehicleImageURL) {
            vehicleImageView.sd_setImage(with: url)
        }
        vehicleImageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = "Delete Vehicle"
        titleLabel.font = FontManager.bold(size: 17)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let vehicleLabel = UILabel()
        vehicleLabel.text = vehicleName
        vehicleLabel.font = FontManager.regular()
        vehicleLabel.textAlignment = .center
        vehicleLabel.translatesAutoresizingMaskIntoConstraints = false

        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 10
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        let cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.backgroundColor = ColorManager.primaryColor
        cancelButton.setTitleColor(ColorManager.buttonTextColor, for: .normal)
        cancelButton.layer.cornerRadius = 20
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(dismissMyAlert), for: .touchUpInside)

        let deleteButton = UIButton()
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.backgroundColor = .red
        deleteButton.setTitleColor(ColorManager.buttonTextColor, for: .normal)
        deleteButton.layer.cornerRadius = 20
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteVehicle), for: .touchUpInside)

        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(deleteButton)

        view.addSubview(alertView)
        alertView.addSubview(vehicleImageView)
        alertView.addSubview(titleLabel)
        alertView.addSubview(vehicleLabel)
        alertView.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.widthAnchor.constraint(equalToConstant: 325),
            alertView.heightAnchor.constraint(equalToConstant: 320),

            titleLabel.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor),

            vehicleImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            vehicleImageView.bottomAnchor.constraint(equalTo: vehicleLabel.topAnchor, constant: -10),
            vehicleImageView.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
            vehicleImageView.heightAnchor.constraint(equalToConstant: 150),
            vehicleImageView.leadingAnchor.constraint(equalTo: alertView.leadingAnchor,constant: 20),
            vehicleImageView.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -20),

            vehicleLabel.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -20),
            vehicleLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor),
            vehicleLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor),

            buttonStack.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -20),
            buttonStack.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func dismissMyAlert() {
        dismiss(animated: true)
    }

    @objc private func deleteVehicle() {
        dismiss(animated: true) {
            self.deleteAction?()
        }
    }
}
