//
//  QuoteViewController.swift
//  Quotable
//
//  Created by Ade Septian on 09/10/22.
//

import Combine
import UIKit

class QuoteViewController: UIViewController {
    //MARK: - Outlets
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.distribution = .fill
        sv.spacing = 20
        return sv
    }()
    
    private let quoteLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .systemPink
        button.configuration?.imagePlacement = .trailing
        button.configuration?.imagePadding = 10.0
        button.configuration?.cornerStyle = .large
        button.configuration?.title = "Refresh"
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        return button
    }()
    
    //MARK: - Instances
    private let vm = QuoteViewModel()
    private let input: PassthroughSubject<Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        input.send(.viewDidAppear)
    }
    
    //MARK: - Methods
    private func setupViews() {
        let subViews = [quoteLabel, authorLabel, refreshButton]
        subViews.forEach {
            stackView.addArrangedSubview($0)
        }
        
        view.backgroundColor = .systemBackground
        refreshButton.addTarget(self, action: #selector(didTapRefresh), for: .touchUpInside)
        stackView.center = view.center
        view.addSubview(stackView)
        setConstraints()
    }
    
    private func setConstraints() {
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func applyData(with data: QuoteModel) {
        quoteLabel.text = "\"\(data.content)\""
        authorLabel.text = data.author
    }
    
    private func bind() {
        let output = vm.transform(input: input.eraseToAnyPublisher())
        
        output.receive(on: DispatchQueue.main)
            .sink { [weak self] event in
            switch event {
            case .fetchDataDidSucceed(let data):
                self?.applyData(with: data as! QuoteModel)
            case .fetchDataDidFail(let error):
                self?.quoteLabel.text = error.localizedDescription
                self?.authorLabel.text = ""
            case .toggleButton(let isEnabled):
                self?.refreshButton.configuration?.showsActivityIndicator = !isEnabled
                self?.refreshButton.isUserInteractionEnabled = isEnabled
            }
        }.store(in: &cancellables)
    }   
    
    @objc private func didTapRefresh() {
        input.send(.didTapRefresh)
    }
}

