//
//  DayCell.swift
//  WeatherAppPower
//
//  Created by Vitkovsky on 31.03.2026.
//

import UIKit

final class DayCell: UICollectionViewCell {
    // MARK: - private properties
    
    private let api: ApiProtocol = Dependencies.shared.resolve()
    
    // MARK: - ui elements
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private lazy var conditionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return imageView
    }()
    
    private lazy var condtionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        return label
    }()
    
    private lazy var tempLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    private lazy var mainElementsStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                dayLabel,
                conditionImageView,
                condtionLabel,
                tempLabel
            ]
        )
        
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 8
        
        return stackView
    }()
    
    private lazy var windSpeedLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var humidityLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var supplementaryElementsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [windSpeedLabel, humidityLabel])
        
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
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
        
        dayLabel.text = nil
        condtionLabel.text = nil
        tempLabel.text = nil
    }
}

// MARK: - private methods

private extension DayCell {
    
    func setup() {
        addViews()
        setupViews()
        makeConsraints()
    }
    
    func addViews() {
        [mainElementsStackView, activityIndicator, supplementaryElementsStackView].forEach { subview in
            contentView.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupViews() {
        contentView.layer.cornerRadius = 20
        contentView.backgroundColor = .systemBackground
    }
    
    func makeConsraints() {
        NSLayoutConstraint.activate(
            [
                mainElementsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
                mainElementsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                mainElementsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                
                conditionImageView.heightAnchor.constraint(equalToConstant: 50),
                conditionImageView.widthAnchor.constraint(equalToConstant: 50),
                
                activityIndicator.centerXAnchor.constraint(equalTo: conditionImageView.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: conditionImageView.centerYAnchor),
                
                supplementaryElementsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                supplementaryElementsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                supplementaryElementsStackView.topAnchor.constraint(equalTo: mainElementsStackView.bottomAnchor, constant: 8),
                supplementaryElementsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
            ]
        )
    }
    
    func loadImage(endpoint: String) {
        _ = Task {
            do {
                // Start loading the image asynchronously
                if let image = try await api.fetchImage(from: endpoint) {
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

// MARK: - ItemConfigurable

extension DayCell: ItemConfigurable {
    func configure(with item: DailyWeather) {
        dayLabel.text = item.date
        tempLabel.text = "\(item.avgTemp)°"
        condtionLabel.text = item.conditionDescription
        windSpeedLabel.text = "Avg. wind speed: \(item.maxWind)"
        humidityLabel.text = "Humidity: \(item.avgHumidity)"
        
        loadImage(endpoint: item.conditionImageUrl)
    }
}
