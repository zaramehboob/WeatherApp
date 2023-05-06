//
//  RequestBuilder.swift
//  WeatherApp
//
//  Created by Zara on 9/8/21.
//

import Foundation
import Alamofire
import RxSwift

protocol RequestBuilderType {
    func request(parameters: [String: Any]?, isBody: Bool, method: HTTPMethod, encoding: ParameterEncoding, urlString: String) -> URLRequest?
}

final class RequestBuilder: RequestBuilderType {
    
    private let headers: [String: String] = ["Content-Type" : "application/json", "Accept": "application/json"]
    
    func request(parameters: [String: Any]?, isBody: Bool, method: HTTPMethod, encoding: ParameterEncoding, urlString: String) -> URLRequest?  {
        
        var url: URL?
        if let params = parameters, !isBody {
            
            var components = URLComponents(string: urlString)
            var queryItems =  [URLQueryItem]()
            for (key, value) in params {
                let convertedString = "\(value)"
                let item = URLQueryItem(name: key, value: convertedString)
                queryItems.append(item)
            }
            
            components?.queryItems = queryItems
            url = components?.url
        } else {
            url = URL(string: urlString)
        }
        
        guard let url = url else {return nil}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        for (key, value) in headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        if isBody {
            let json = try? JSONSerialization.data(withJSONObject: parameters ?? [:], options: .prettyPrinted)
            urlRequest.httpBody = try? JSONEncoder().encode(json)
        }
        
        return urlRequest
        
    }
}


