//
//  WeatherFetchService.swift
//  WeatherApp
//
//  Created by Zara on 9/8/21.
//

import Foundation
import RxSwift
import Alamofire


enum Endpoints {
    case currentWeather
    case forecastWeather
    
    var endpoint: String {
        switch self {
        
        case .currentWeather:
            return "weather"
        case .forecastWeather:
            return "forecast"
        }
    }
}


protocol WeatherFetchServiceProtocol {
    func fetchCurrentWeather(cityName: String) -> Observable<CurrentWeatherModel>
    func fetchForecastWeather(cityName: String) -> Observable<ForecastWeatherModel>
}

class WeatherFetchService: WeatherFetchServiceProtocol {
    
    private let _requestBuilder: RequestBuilderType
    private let client: FetchClient
    private let constants = StringConstants()
    
    init(builder: RequestBuilderType, client: FetchClient) {
        self._requestBuilder = builder
        self.client = client
    }
    
    func fetchCurrentWeather(cityName: String) -> Observable<CurrentWeatherModel> {
        
        let parameters = ["q": cityName, "appid": constants.apiKey]
        let urlString = String(format: "%@%@", BaseUrl.apiBasrUrl.url , Endpoints.currentWeather.endpoint)
        
        let request = _requestBuilder.request(parameters: parameters, isBody: false, method: .get, encoding: URLEncoding.queryString, urlString: urlString)
        guard let urlReq = request  else { return Observable.error(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "URL found missing"]))}
        let response = client.fetch(with: urlReq)
        return updateResponse(response: response)
        
    }
    
    func fetchForecastWeather(cityName: String) -> Observable<ForecastWeatherModel> {
        
        let parameters: [String: Any] = ["q": cityName, "cnt": constants.forecastCount, "appid": constants.apiKey]
        let urlString = String(format: "%@%@", BaseUrl.apiBasrUrl.url, Endpoints.forecastWeather.endpoint)
        
        let request = _requestBuilder.request(parameters: parameters, isBody: false, method: .get, encoding: URLEncoding.queryString, urlString: urlString)
        guard let urlReq = request  else { return Observable.error(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "URL found missing"]))}
        let response = client.fetch(with: urlReq)
        return updateResponse(response: response)
        
    }
}

private extension WeatherFetchService {
    func updateResponse<T: Decodable>(response: Observable<APIResponseProtocol>) -> Observable<T> {
        
        response.map { response -> APIResponseProtocol in
            guard response.apiError == nil else {
                throw response.apiError ?? NSError(domain: "", code: 2, userInfo: [NSLocalizedDescriptionKey: response.apiError?.localizedDescription ?? "Unable to fetch"])
            }
            return response
        }.map { response -> T in
            do {
                if let data = response.data {
                    let model = try JSONDecoder().decode(T.self, from: data)
                    return model
                } else {
                    throw NSError(domain: "", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not found your result."])
                }
            } catch let error {
                throw error
            }
        }
    }
}
