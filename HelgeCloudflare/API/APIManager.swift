//
//  APIManager.swift
//  Default SwiftUI App
//
//  Created by Ryan Helgeson on 8/8/25.
//

import Foundation

final class APIManager {
    static let shared = APIManager()
    
    func decodeData<T: Decodable>(_ data: Data) throws -> T {
        do {
            let data = try JSONDecoder().decode(T.self, from: data)
            return data
        } catch let error as DecodingError {
            switch error {
            case .dataCorrupted(let context):
                print("Context: \(context)")
            case .keyNotFound(let key, let context):
                print("Key: \(key), Context: \(context)")
            case .typeMismatch(let type, let context):
                print( "Type: \(type), Context: \(context)")
                case .valueNotFound(let type, let context):
                print("Type: \(type), Context: \(context)")
            default:
                break
            }
            throw APIManagerError.decodingFailed
        }
    }
    
    func sendRequest<T: Decodable>(_ request: HTTPRequest) async throws -> T {
        do {
            // Create URLRequest
            let urlRequest = try request.urlRequest()
            
            // Send Data Request
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            if request.isLoggingEnabled {
                logRequest(request.path, data: data)
            }
            
            if let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode > 299 {
                if let error = request.decodeError(errorData: data) {
                    throw error
                } else {
                    throw APIManagerError.invalidResponse
                }
            }
            
            // Decode the data
            let decodedData: T = try decodeData(data)
            return decodedData
        } catch let error as CustomError {
            throw error
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet:
                print("Not connected to the internet.")
                throw APIManagerError.noInternetConnection
            case .badServerResponse:
                print("Not server connection.")
                throw APIManagerError.noServerConenction
            default:
                break
            }
            throw APIManagerError.failedToCreateRequest
        } catch {
            // Do nothing
            throw APIManagerError.failedToCreateRequest
        }
    }
    
    private func logRequest(_ path: String, data: Data) {
        debugPrint("===========================================")
        debugPrint("Request: \(path)")
        debugPrint()
        if let prettyJSONString = data.prettyJSONString {
            debugPrint(prettyJSONString)
        } else {
            debugPrint(String(data: data, encoding: .utf8)!)
        }
        debugPrint()
        debugPrint("===========================================")
    }
}
