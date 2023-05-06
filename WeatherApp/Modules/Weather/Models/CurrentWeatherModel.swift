//
//  CurrentWeatherModel.swift
//  WeatherApp
//
//  Created by Zara on 9/8/21.
//

import Foundation

struct CurrentWeatherModel: Decodable {
    
    let main: MainInfo
    let weather: [WeatherInfo]
   
    
    enum CodingKeys: String, CodingKey {
        case main
        case weather
    }
}

struct RainInfo: Decodable {
    let rain: Double
    
    enum CodingKeys: String, CodingKey {
        case rain = "3h"
    }
}

struct MainInfo: Decodable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
    let feels_like: Double
    let humidity: Int
    
    enum CodingKeys: String, CodingKey {
        case temp
        case temp_min
        case temp_max
        case humidity
        case feels_like
    }
}


struct WeatherInfo: Decodable {
    let icon: String

    enum CodingKeys: String, CodingKey {
        case icon
    }
}
