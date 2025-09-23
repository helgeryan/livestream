//
//  HTTPRequest.swift
//  Default SwiftUI App
//
//  Created by Ryan Helgeson on 8/8/25.
//

import Foundation

protocol HTTPRequest {
    var method: HTTPMethod { get }
    var host: String { get }
    var scheme: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    var headers: [HTTPHeader] { get }
}

extension HTTPRequest {
    func urlRequest() throws -> URLRequest {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers.reduce(into: [:]) { result, header in
            result[header.key] = header.value
        }
        return request
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
}

struct HTTPHeader: Codable {
    static let apiKey: HTTPHeader = .init(key: "X-Api-Key", value: "7e508a6c3f7b46eea58a55892508857b")
    
    let key: String
    let value: String
}



