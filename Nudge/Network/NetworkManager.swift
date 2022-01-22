//
//  NetworkManager.swift
//  Nudge
//
//  Created by Eli Zhang on 1/20/22.
//

import Combine
import Foundation
import KeychainAccess
import os

extension NetworkManager {
    static func login(password: String) {
        
    }

    static func createUser(password: String) -> AnyPublisher<NetworkTypes.CreateUser.Data, Error> {
        let body = NetworkTypes.CreateUser.Body(password: password)
        return postRequestAndDecode(route: "/user/create", body: body)
    }

    static func updateUserInfo(name: String, deviceToken: String) -> AnyPublisher<NetworkTypes.UpdateUserInfo.Data, Error> {
        let userId = CredentialManager.getUserId()!
        let body = NetworkTypes.UpdateUserInfo.Body(name: name, deviceToken: deviceToken)
        return postRequestAndDecode(route: "/user/\(userId)/update", body: body)
    }
    
    static func getUserInfo() -> AnyPublisher<NetworkTypes.GetUserInfo.Data, Error> {
        let userId = CredentialManager.getUserId()!
        return getRequestAndDecode(route: "/user/\(userId)")
    }
    
    static func addFriend(friendCode: String) -> AnyPublisher<NetworkTypes.AddFriend.Data, Error> {
        let userId = CredentialManager.getUserId()!
        let body = NetworkTypes.AddFriend.Body(friendCode: friendCode)
        return postRequestAndDecode(route: "/user/\(userId)/friend/addCode", body: body)
    }
}

// Reference: https://medium.com/better-programming/upgrade-your-swift-api-client-with-combine-4897d6e408a0
enum NetworkManager {

    static let serverURL = "http://192.168.1.36:3000"
    
    enum NetworkError: Error {
        case statusCode(Int)
        case invalidResponse
        case invalidURL
        case invalidBody
        case invalidToken
    }
    
    enum ResponseError: Error {
        case notFound
        case failed
    }
    
    enum UserError: Error {
        case noUserId
        case noPassword
    }

    static func postRequest<T: Codable>(
        route: String,
        data: T,
        token: String? = nil
    ) throws -> URLSession.DataTaskPublisher {
        guard let fullURL = URL(string: "\(serverURL)\(route)") else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: fullURL)
        var headers = [
            "Content-Type": "application/json",
            "cache-control": "no-cache"
        ]
        if let tokenString = token {
            headers["Authorization"] = "Bearer \(tokenString)"
        }
        let encoder = JSONEncoder()
        guard let postData = try? encoder.encode(data) else {
            throw NetworkError.invalidBody
        }
        request.httpMethod = "POST"
        request.httpBody = postData as Data
        request.allHTTPHeaderFields = headers

        return URLSession.shared.dataTaskPublisher(for: request)
    }

    static func postRequestAndDecode<B: Codable, R: Codable>(
        route: String,
        body: B,
        token: String? = nil
    ) -> AnyPublisher<R, Error> {
        do {
            return try postRequest(route: route, data: body, token: token)
                .tryMap { try validate($0.data, $0.response) }
//                .handleEvents(receiveOutput: { prettyPrintResponseData($0) })
                .decode(type: NetworkTypes.Response<R>.self, decoder: JSONDecoder())
                .tryMap(decodeResponse)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    static func getRequest(
        route: String,
        token: String? = nil,
        params: [String: String]? = nil
    ) throws -> URLSession.DataTaskPublisher {
        var components = URLComponents(string: "\(serverURL)\(route)")
        if let queryParams = params {
            components?.queryItems = queryParams.map { (key, value) in
                    URLQueryItem(name: key, value: value)
            }
        }

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        var headers = [
            "Content-Type": "application/json",
            "cache-control": "no-cache"
        ]
        if let tokenString = token {
            headers["Authorization"] = "Bearer \(tokenString)"
        }
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        return URLSession.shared.dataTaskPublisher(for: request)
    }

    static func getRequestAndDecode<R: Codable>(
        route: String,
        token: String? = nil,
        params: [String: String]? = nil
    ) -> AnyPublisher<R, Error> {
        do {
            return try getRequest(route: route, token: token, params: params)
                .tryMap { try validate($0.data, $0.response) }
//                .handleEvents(receiveOutput: { prettyPrintResponseData($0) })
                .decode(type: NetworkTypes.Response<R>.self, decoder: JSONDecoder())
                .tryMap(decodeResponse)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    static func validate(_ data: Data, _ response: URLResponse) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        // Can modify to fit relevant status codes
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.statusCode(httpResponse.statusCode)
        }
        return data
    }

    static func decodeResponse<T: Decodable>(response: NetworkTypes.Response<T>) throws -> T {
        guard let data = response.data else {
            if response.err_code == 404 {
                throw ResponseError.notFound
            }

            os_log(.error, "Response does not contain data or error")
            os_log(.error, "response.success = %@", "\(response.success)")
            throw ResponseError.failed
        }

        return data
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        } else {
            print("Couldn't convert string \(string) to data")
        }
    }
}
