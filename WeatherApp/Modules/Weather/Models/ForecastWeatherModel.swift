//
//  ForecastWeatherModel.swift
//  WeatherApp
//
//  Created by Zara on 9/8/21.
//

import Foundation

struct ForecastWeatherModel: Decodable {
    
    let forecastWeatherList: [DailyWeatherModel]
    
    enum CodingKeys: String, CodingKey {
        case forecastWeatherList = "list"
    }

}

struct DailyWeatherModel: Decodable, Equatable {
    static func == (lhs: DailyWeatherModel, rhs: DailyWeatherModel) -> Bool {
        return lhs == rhs
    }
    
    let main: MainInfo
    let weather: [WeatherInfo]
    let rain: RainInfo?
   
    
    enum CodingKeys: String, CodingKey {
        case main
        case weather
        case rain
    }
}

