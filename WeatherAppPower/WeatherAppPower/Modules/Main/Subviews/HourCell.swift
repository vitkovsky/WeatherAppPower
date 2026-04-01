//
//  HourCell.swift
//  WeatherAppPower
//
//  Created by Vitkovsky on 31.03.2026.
//

import UIKit

final class HourCell: UICollectionViewCell {
    
    // MARK: - private properties
    
    private let api: ApiProtocol = Dependencies.shared.resolve()
    
    // MARK: - ui elements
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var conditionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    private lazy var tempLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var vStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [timeLabel, conditionImageView, tempLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        
        return stackView
    }()
    
    // MARK: - initilizaers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - overrride methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        conditionImageView.image = nil
        activityIndicator.startAnimating()
        
        tempLabel.text = nil
        timeLabel.text = nil
    }
}

// MARK: - private methods

private extension HourCell {
    
    func setup() {
        addViews()
        setupViews()
        makeConsraints()
    }
    
    func addViews() {
        contentView.addSubview(vStackView)
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupViews() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 20
    }
    
    func makeConsraints() {
        NSLayoutConstraint.activate(
            [
                conditionImageView.heightAnchor.constraint(equalToConstant: 50),
                
                activityIndicator.centerXAnchor.constraint(equalTo: conditionImageView.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: conditionImageView.centerYAnchor),
                
                vStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
                vStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
                vStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                vStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            ]
        )
    }
}


// MARK: - ItemConfigurable

extension HourCell: ItemConfigurable {
    
    func configure(with item: HourlyWeather) {
        timeLabel.text = item.time
        tempLabel.text = "\(String(format: "%.0f", item.temperature))°"
        
        _ = Task {
            do {
                // Start loading the image asynchronously
                if let image = try await api.fetchImage(from: item.conditionImageUrl) {
                    // Ensure UI update is on the main thread
                    await MainActor.run {
                        self.conditionImageView.image = image
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
}

