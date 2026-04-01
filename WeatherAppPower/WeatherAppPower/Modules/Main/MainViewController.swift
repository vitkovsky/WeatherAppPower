//
//  MainViewController.swift
//  WeatherAppPower
//
//  Created by Vitkovsky on 31.03.2026.
//

import UIKit
import Combine

final class MainViewController: UIViewController {
    
    // MARK: - private properties
    
    private let viewModel: MainViewModel
    
    // MARK: - publishers
    
    private var cancellables: Set<AnyCancellable> = []
    private var reloadButtonPublisher = PassthroughSubject<Void, Never>()
    private var goToSettingsButtonPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - ui elements
    
    private lazy var reloadButton: UIBarButtonItem = {
        let button = UIBarButtonItem(systemItem: .refresh)
        
        button.primaryAction = UIAction { [weak self] _ in
            self?.reloadButtonPublisher.send()
        }
        
        return button
    }()
    
    // MARK: - initilizers
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    
    override func loadView() {
        super.loadView()
        view = MainView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayState(.loading)
        bind()
        setupNavBar()
    }
}

// MARK: - private methods

private extension MainViewController {
    
    func bind() {
        guard let view = view as? MainView else { return }
        
        let viewInput = view.makeInput()
        
        let input = MainViewModel.Input(
            errorReloadButtonPublisher: viewInput.errorReloadButtonPublisher,
            reloadButtonPublisher: reloadButtonPublisher.eraseToAnyPublisher(),
            goToSettingsButtonPublisher: goToSettingsButtonPublisher.eraseToAnyPublisher()
        )
        
        let output = viewModel.bind(input)
        
        handle(output)
    }
    
    func setupNavBar() {
        navigationItem.rightBarButtonItem = reloadButton
    }
    
    func handle(_ output: MainViewModel.Output) {
        handleStatePublisher(output.statePublisher)
        
        guard let view = view as? MainView else { return }
        view.handle(output)
    }
    
    func handleStatePublisher(_ publisher: AnyPublisher<State, Never>) {
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.displayState(state)
            }
            .store(in: &cancellables)
    }
    
    func displayState(_ state: State) {
        switch state {
        
        case .error, .loading:
            navBarElementsShouldbeVisible(false)
            
        case .loaded:
            navBarElementsShouldbeVisible(true)
            
        case .locationAuthRequiredAlert:
            showLocationAuthAlert()
        }
    }
    
    func navBarElementsShouldbeVisible(_ bool: Bool) {
        
        navigationItem.title = bool ? "Weather" : nil
        reloadButton.isHidden = bool ? false : true
    }
    
    func showLocationAuthAlert() {
        let alert = UIAlertController(
            title: "Access required",
            message: "Access to location is required to fetch weather data. Grant access in settings.",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        alert.addAction(
            UIAlertAction(
                title: "Settings",
                style: .default,
                handler: { [weak self] _ in
                    self?.goToSettingsButtonPublisher.send()
                }
            )
        )
        
        present(alert, animated: true)
    }
}

// MARK: - entities

extension MainViewController {
    
    enum State {
        case error(Error)
        case loading
        case loaded(WeatherFormatted)
        case locationAuthRequiredAlert
    }
}



