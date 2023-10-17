//
//  Network.swift
//  ProjectDescriptionHelpers
//
//  Created by Kim Yewon on 2023/09/18.
//

import UIKit
import Combine

public enum NetworkServiceError: Error {
    case networkError
    case noInternet
    case unknownError
    case decodingError
    case serverError(String)
    case unauthorized
}

public class NetworkService<T: Decodable> {
    public static func fetchApp(with endpoint: Endpoint, completion: @escaping (Result<T, NetworkServiceError>) -> Void) {
        guard let request = endpoint.request else { return }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                completion(.failure(.networkError))
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let appSearchData = try decoder.decode(T.self, from: data)
                    completion(.success(appSearchData))
                } catch let error {
                    if error is DecodingError{
                        completion(.failure(.decodingError))
                    } else {
                        completion(.failure(.unknownError))
                    }
                    print(error.localizedDescription)
                    
                }
            } else {
                completion(.failure(.unknownError))
            }
        }
        .resume()
    }
    
    public static func fetchAppWithCombine(with endpoint: Endpoint) -> AnyPublisher<T, NetworkServiceError> {
        guard let request = endpoint.request?.url else { return Fail(error: NetworkServiceError.noInternet).eraseToAnyPublisher() }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, 200 ... 299 ~= httpResponse.statusCode else {
                    throw NetworkServiceError.networkError
                }
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 401 else {
                    throw NetworkServiceError.unauthorized
                }
                
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet:
                        return NetworkServiceError.noInternet
                    default:
                        return NetworkServiceError.unknownError
                    }
                } else if error is DecodingError {
                    return NetworkServiceError.decodingError
                } else {
                    return NetworkServiceError.serverError(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
    
    public static func fetchAppWithAsync(with endpoint: Endpoint) async -> Result<T, NetworkServiceError> {
        guard let request = endpoint.request?.url else { return .failure(NetworkServiceError.noInternet) }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: request)
            
            guard let response = response as? HTTPURLResponse else {
                return .failure(.noInternet)
            }
            
            switch response.statusCode {
            case 200...299:
                guard let decodedResponse = try? JSONDecoder().decode(T.self, from: data) else {
                    return .failure(.decodingError)
                }
                
                return .success(decodedResponse)
            case 401:
                return .failure(.unauthorized)
            default:
                return .failure(.unknownError)
            }
        } catch {
            return .failure(.unknownError)
        }
    }
}
