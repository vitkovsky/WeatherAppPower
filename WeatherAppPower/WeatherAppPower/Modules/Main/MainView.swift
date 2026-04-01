//
//  MainView.swift
//  WeatherAppPower
//
//  Created by Vitkovsky on 31.03.2026.
//

import UIKit
import Combine

final class MainView: UIView {
    
    // MARK: - publishers
    
    private var cancellables: Set<AnyCancellable> = []
    private lazy var errorView = ErrorView()
    private lazy var errorReloadButtonPublisher = errorView.reloadButtonPublisher
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        return indicator
    }()
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(
            frame: .zero,
            collectionViewLayout: makeLayout()
        )
        
        cv.register(CurrentWeatherCell.self, forCellWithReuseIdentifier: CurrentWeatherCell.identifier)
        cv.register(HourCell.self, forCellWithReuseIdentifier: HourCell.identifier)
        cv.register(DayCell.self, forCellWithReuseIdentifier: DayCell.identifier)
        
        cv.backgroundColor = .clear
        
        return cv
    }()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    
    // MARK: - initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        initDataSource()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - public methods
    
    func makeInput() -> Input {
        Input(
            errorReloadButtonPublisher: errorReloadButtonPublisher.eraseToAnyPublisher()
        )
    }
    
    func handle(_ output: MainViewModel.Output) {
        output.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.displayState(state)
            }
            .store(in: &cancellables)
    }
}

// MARK: - private methods

private extension MainView {
    
    func setup() {
        addViews()
        setupViews()
        makeConsraints()
    }
    
    func addViews() {
        [collectionView, errorView, activityIndicator].forEach { subview in
            addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupViews() {
        backgroundColor = .systemGray6
        errorView.isHidden = true
    }
    
    func makeConsraints() {
        NSLayoutConstraint.activate(
            [
                errorView.topAnchor.constraint(equalTo: topAnchor),
                errorView.leadingAnchor.constraint(equalTo: leadingAnchor),
                errorView.trailingAnchor.constraint(equalTo: trailingAnchor),
                errorView.bottomAnchor.constraint(equalTo: bottomAnchor),
                
                activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
                
                collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ]
        )
    }
    
    func displayState(_ state: MainViewController.State) {
        switch state {
            
        case .error(let error):
            errorView.isHidden = false
            errorView.configureWith(error)
            activityIndicator.stopAnimating()
            collectionView.isHidden = true
            
        case .loading:
            errorView.isHidden = true
            activityIndicator.startAnimating()
            collectionView.isHidden = true
            
        case .loaded(let weatherFormatted):
            errorView.isHidden = true
            activityIndicator.stopAnimating()
            collectionView.isHidden = false
            displayWeather(weatherFormatted)
            
        case .locationAuthRequiredAlert:
            break
        }
    }
    
    func makeLayout() -> UICollectionViewLayout {
        
        let layout =  UICollectionViewCompositionalLayout { sectionIndex, enviroment in
            
            let sectionType = Section(rawValue: sectionIndex)
            
            let groupWidthRatio: CGFloat = {
                switch sectionType {
                    
                case .hourlyForecast:
                    return 0.22
                    
                default:
                    return  1
                }
            }()
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(100)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(groupWidthRatio),
                heightDimension: .estimated(1)
            )
            
            let group: NSCollectionLayoutGroup = {
                switch sectionType {
                    
                case .hourlyForecast:
                    return NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                    
                default:
                    return NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                }
            }()
            
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
           
            let section = NSCollectionLayoutSection(group: group)
            
            if sectionType == .hourlyForecast {
                section.orthogonalScrollingBehavior = .continuous
                group.interItemSpacing = .fixed(1)
            }
            
            section.interGroupSpacing = 5
            
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 16
        
        layout.configuration = config
        
        return layout
    }
    
    func initDataSource() {
        
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, item in
                
                guard let self else { return UICollectionViewCell() }
                
                let cell: UICollectionViewCell?
                
                switch item {
                    
                case .currentWeather(let currentWeather):
                    cell = configureCell(collectionView, for: indexPath, with: currentWeather, as: CurrentWeatherCell.self)
                    
                case .hourWeather(let hourWeather):
                    cell = configureCell(collectionView, for: indexPath, with: hourWeather, as: HourCell.self)

                case .dayWeather(let dayWeather):
                    cell = configureCell(collectionView, for: indexPath, with: dayWeather, as: DayCell.self)
                }
                
                guard let cell else { return UICollectionViewCell() }
                
                return cell
            }
        )
    }
    
    func configureCell<T: UICollectionViewCell & ItemConfigurable>(
        _ collectionView: UICollectionView,
        for indexPath: IndexPath,
        with item: T.ItemType,
        as cellType: T.Type
    ) -> UICollectionViewCell? {
        
        guard let cell = dequeueCell(collectionView, for: indexPath, as: cellType) else { return nil }
        cell.configure(with: item)
        return cell
    }
    
    func dequeueCell<T: UICollectionViewCell>(
        _ collectionView: UICollectionView,
        for indexPath: IndexPath,
        as type: T.Type
    ) -> T? {
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T
    }
    
    func displayWeather(_ weatherFormatted: WeatherFormatted) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        
        let currentWeather = Item.currentWeather(weatherFormatted.currentWeather)
        snapshot.appendItems( [currentWeather], toSection: .currentWeather)
        
        let hourlyWeather = weatherFormatted.hourlyWeather.map { Item.hourWeather($0) }
        snapshot.appendItems(hourlyWeather, toSection: .hourlyForecast)
        
        let dailyWeather = weatherFormatted.dailyWeather.map { Item.dayWeather($0) }
        snapshot.appendItems(dailyWeather, toSection: .dailyForecast)
        
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - entities

extension MainView {
    
    struct Input {
        let errorReloadButtonPublisher: AnyPublisher<Void, Never>
    }
    
    enum Section: Int, CaseIterable, Hashable {
        case currentWeather
        case hourlyForecast
        case dailyForecast
        
        var title: String {
            switch self {
            case .currentWeather:
                return "Current weather"
                
            case .hourlyForecast:
                return "Hourly forecast"
                
            case .dailyForecast:
                return "Daily forecast"
            }
        }
    }
    
    enum Item: Hashable {
        case currentWeather(CurrentWeather)
        case hourWeather(HourlyWeather)
        case dayWeather(DailyWeather)
    }
}
