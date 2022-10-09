//
//  NetworkManager.swift
//  Quotable
//
//  Created by Ade Septian on 09/10/22.
//

import Combine
import Foundation

    
protocol NetworkService {
    func request<T:Decodable>(expecting: T.Type) -> AnyPublisher<T, Error>
}

final class NetworkManager: NetworkService {
    func request<T>(expecting: T.Type) -> AnyPublisher<T, Error> where T: Decodable {
        guard let url = URL(string: "https://api.quotable.io/random") else {
            return Fail(error: Error.self as! Error).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .catch { error in
                return Fail(error: error).eraseToAnyPublisher()
            }
            .map ({ $0.data })
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
