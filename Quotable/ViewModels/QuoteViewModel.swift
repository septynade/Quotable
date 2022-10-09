//
//  QuoteViewModel.swift
//  Quotable
//
//  Created by Ade Septian on 09/10/22.
//

import Combine
import Foundation

final class QuoteViewModel {
    //MARK: - Private properties
    private let networkManager: NetworkService
    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - Publishers
    @Published private(set) var quote: String = ""
    @Published private(set) var author: String = ""
    
    //MARK: - Lifecycles
    init(networkManager: NetworkService = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    //MARK: - Helpers
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidAppear, .didTapRefresh:
                self?.fetchQuote()
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    //MARK: - Network calls
    private func fetchQuote() {
        output.send(.toggleButton(isEnabled: false))
        networkManager.request(expecting: QuoteModel.self).sink { [weak self] completion in
            self?.output.send(.toggleButton(isEnabled: true))
            if case .failure(let error) = completion {
                self?.output.send(.fetchDataDidFail(error: error))
            }
        } receiveValue: { [weak self] quote in
            self?.output.send(.fetchDataDidSucceed(data: quote))
        }.store(in: &cancellables)
    }
}

enum Input {
    case viewDidAppear
    case didTapRefresh
}

enum Output {
    case fetchDataDidFail(error: Error)
    case fetchDataDidSucceed(data: Decodable)
    case toggleButton(isEnabled: Bool)
}
