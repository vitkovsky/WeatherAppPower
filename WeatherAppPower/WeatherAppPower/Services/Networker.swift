//
//  Networker.swift
//  WeatherAppPower
//
//  Created by Vitkovsky on 31.03.2026.
//

import Foundation
import Combine

protocol NetworkerProtocol {
    
    func processRequest<T: Codable>(_ request: URLRequest) -> AnyPublisher<T, Error>
    func processRequest(_ request: URLRequest) -> AnyPublisher<Data, Error>
}

final class Networker: NetworkerProtocol {
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(
        session: URLSession,
        decoder: JSONDecoder
    ) {
        self.session = session
        self.decoder = decoder
    }
    
    func processRequest<T: Codable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        return decodedRequestPublisher(request)
    }
    
    func processRequest(_ request: URLRequest) -> AnyPublisher<Data, Error> {
        requestPublisher(request)
    }
}

private extension Networker {
    func requestPublisher(_ request: URLRequest) -> AnyPublisher<Data, any Error> {
        session
            .dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard
                    let response = response as? HTTPURLResponse,
                    (200..<300).contains(response.statusCode)
                else {
                    throw AppError.networkError(.badResponse)
                }
                return data
            }
            .eraseToAnyPublisher()
    }
    
    func decodedRequestPublisher<T: Codable>(_ request: URLRequest) -> AnyPublisher<T, any Error> {
        requestPublisher(request)
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
