//
//  APIResponse.swift
//  WeatherApp
//
//  Created by Zara on 9/17/21.
//

import Foundation


protocol APIResponseProtocol {
    var data: Data? {get set}
    var apiError: Error? {get set}
}

struct APIResponse: APIResponseProtocol {
    var data: Data?
    var apiError: Error?
}
