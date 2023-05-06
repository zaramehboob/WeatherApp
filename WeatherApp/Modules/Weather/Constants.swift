//
//  Constants.swift
//  WeatherApp
//
//  Created by Zara on 9/17/21.
//

import Foundation


enum BaseUrl {
    
    case imageBaseUrl
    case apiBasrUrl
    
    var url: String {
        switch self {
        case .imageBaseUrl:
            return "http://openweathermap.org/img/wn/"
        case .apiBasrUrl:
            return "http://api.openweathermap.org/data/2.5/"
        }
    }
}

struct StringConstants {
     let apiKey: String = "7bbabec031409948b89809281b11a24f"
     let forecastCount = 7
}
