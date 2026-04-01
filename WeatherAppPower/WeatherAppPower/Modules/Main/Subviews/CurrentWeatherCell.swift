//
//  CurrentWeatherCell.swift
//  WeatherAppPower
//
//  Created by Vitkovsky on 31.03.2026.
//

import UIKit

final class CurrentWeatherCell: UICollectionViewCell {
    
    private let api: ApiProtocol = Dependencies.shared.resolve()
    
    // MARK: - ui elements
    
    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title3)
        label.numberOfLines = 0
        return label
    }()
    private lazy var tempretureLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        return label
    }()
    private lazy var conditionLabel:  UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
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
    private lazy var feelsLikeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    private lazy var humidityLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    private lazy var precipitaionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    private lazy var windLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    private lazy var detailsStackView: UIStackView = makeDetailsStackView()
    
    
    
    // MARK: - initilizers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - override methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        conditionImageView.image = nil
        activityIndicator.startAnimating()
        
        locationLabel.text = nil
        tempretureLabel.text = nil
        conditionLabel.text = nil
        feelsLikeLabel.text = nil
        humidityLabel.text = nil
        precipitaionLabel.text = nil
        windLabel.text = nil
    }
}

// MARK: - private methods

private extension CurrentWeatherCell {
    
    func setup() {
        addViews()
        setupViews()
        makeConsraints()
    }
    
    func addViews() {
        [
            locationLabel,
            tempretureLabel,
            conditionLabel,
            conditionImageView,
            activityIndicator,
            detailsStackView
        ].forEach { subview in
            contentView.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupViews() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 20
    }
    
    func makeConsraints() {
        NSLayoutConstraint.activate(
            [
                conditionImageView.widthAnchor.constraint(equalToConstant: 50),
                conditionImageView.heightAnchor.constraint(equalToConstant: 50),
                conditionImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
                conditionImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                
                activityIndicator.centerXAnchor.constraint(equalTo: conditionImageView.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: conditionImageView.centerYAnchor),
                
                locationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                locationLabel.trailingAnchor.constraint(equalTo: conditionImageView.leadingAnchor, constant: -8),
                locationLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
                
                tempretureLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                tempretureLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 16),
                
                conditionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                conditionLabel.bottomAnchor.constraint(equalTo: tempretureLabel.bottomAnchor),
                
                detailsStackView.topAnchor.constraint(equalTo: tempretureLabel.bottomAnchor, constant: 25),
                detailsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                detailsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                detailsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            ]
        )
    }
    
    func makeDetailsStackView() -> UIStackView {
        let subStacks: [UIStackView] = [
            ("Feels like:", feelsLikeLabel),
            ("Wind direction and speed:", windLabel),
            ("Expected precipitation (mm):", precipitaionLabel),
            ("Humidity:", humidityLabel)
        ].map { title, valueLabel in
            let titleLabel = UILabel()
            titleLabel.font = .preferredFont(forTextStyle: .body)
            titleLabel.text = title
            
            let hStack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
            hStack.axis = .horizontal
            hStack.alignment = .center
            hStack.spacing = 8
            hStack.distribution = .equalSpacing
            
            return hStack
        }
        
        
        let stackView = UIStackView(
            arrangedSubviews: subStacks
        )
        
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        return stackView
    }
}

// MARK: - ItemConfigurable

extension CurrentWeatherCell: ItemConfigurable {
    
    func configure(with item: CurrentWeather) {
        locationLabel.text = item.location
        tempretureLabel.text = "\(item.currentTemperature)°"
        conditionLabel.text = item.conditionDescription
        feelsLikeLabel.text = "\(item.feelsLikeTemperature)°"
        humidityLabel.text = "\(item.humidity)%"
        precipitaionLabel.text = "\(item.precipitationMm) mm"
        windLabel.text = "\(item.windDirection) \(item.windSpeed) kM/h"
        
        _ = Task {
            do {
                // Start loading the image asynchronously
                if let image = try await api.fetchImage(from: item.currentConditionImageUrl) {
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
