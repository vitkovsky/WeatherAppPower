//
//  ErrorView.swift
//  WeatherAppPower
//
//  Created by Vitkovsky on 31.03.2026.
//

import UIKit
import Combine

final class ErrorView: UIView {
    
    // MARK: - publishers
    
    private(set) var reloadButtonPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - ui elements
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.image = UIImage(systemName: "exclamationmark.triangle")
        return imageView
    }()
    
    private lazy var errorMessageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var reloadButton: UIButton = {
        let button = UIButton(configuration: .bordered())
        button.setTitle("Reload", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.addAction(
            UIAction(
                handler: { [weak self] _ in
                    self?.reloadButtonPublisher.send()
                }
            ),
            for: .touchUpInside
        )
        return button
    }()
    
    // MARK: - initilizers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - public methods
    
    func configureWith(_ error: Error) {

        guard let appError = error as? AppError else {
            errorMessageLabel.text = "Unknown Error:\n\(error.localizedDescription)"
            return
        }
        
        errorMessageLabel.text = "\(appError.title): \(appError.userDescription)"
        
    }
}

// MARK: - private methods

private extension ErrorView {
    
    func setup() {
        addViews()
        setupViews()
        makeConsraints()
    }
    
    func addViews() {
        [imageView, errorMessageLabel, reloadButton].forEach { subview in
            addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupViews() {
        
    }
    
    func makeConsraints() {
        NSLayoutConstraint.activate(
            [
                errorMessageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                errorMessageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                errorMessageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                
                imageView.widthAnchor.constraint(equalToConstant: 200),
                imageView.heightAnchor.constraint(equalToConstant: 200),
                imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                imageView.bottomAnchor.constraint(equalTo: errorMessageLabel.topAnchor, constant: -16),
                
                reloadButton.topAnchor.constraint(equalTo: errorMessageLabel.bottomAnchor, constant: 16),
                reloadButton.centerXAnchor.constraint(equalTo: centerXAnchor)
            ]
        )
    }
}
