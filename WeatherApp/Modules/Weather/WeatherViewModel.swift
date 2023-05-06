//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Zara on 9/7/21.
//

import Foundation
import RxSwift

protocol WeatherViewModelType {
    var outs: WeatherViewModelOutputs {get}
}


protocol WeatherViewModelOutputs {
    var location: Observable<String> {get}
    var temperature: Observable<String> {get}
    var temperatureMin: Observable<String> {get}
    var temperatureMax: Observable<String> {get}
    var humidity: Observable<String> {get}
    var feelLike: Observable<String> {get}
    var weatherImg: Observable<String?> {get}
    var showalert: Observable<String> {get}
    var data: Observable<[DailyWeatherModel]> {get}
    
}

class WeatherViewModel: WeatherViewModelType, WeatherViewModelOutputs {

    private let bag = DisposeBag()
    private var weatherService: WeatherFetchServiceProtocol!
    private var locationService: LocationServiceProtocol!
    private var locationSubject = BehaviorSubject<String>(value: "")
    private var temperatureSubject = BehaviorSubject<Double?>(value: nil)
    private var imageSubject = PublishSubject<String?>()
    private var temperatureMinSubject = BehaviorSubject<Double?>(value: nil)
    private var temperatureMaxSubject = BehaviorSubject<Double?>(value: nil)
    private var humiditySubject = BehaviorSubject<Int?>(value: nil)
    private var feelLikeSubject = BehaviorSubject<Double?>(value: nil)
    private var alertSubject = PublishSubject<String>()
    private var dataSubject = PublishSubject<[DailyWeatherModel]>()
    
    
    var location: Observable<String> { locationSubject.asObservable() }
    var temperature: Observable<String> { temperatureSubject.map { self.transformTemperature(temperature: $0) }.asObservable() }
    var weatherImg: Observable<String?> {  imageSubject.asObservable() }
    var temperatureMin: Observable<String> { temperatureMinSubject.map {"Temp Min: \(self.transformTemperature(temperature: $0))" }.asObservable()}
    var temperatureMax: Observable<String> { temperatureMaxSubject.map {"Temp Max: \(self.transformTemperature(temperature: $0))"}.asObservable()}
    var humidity: Observable<String> { humiditySubject.map { $0 == nil ? "Humidity: -" : String(format: "Humidity: %d%", $0 ?? 0.0)}.asObservable()}
    var feelLike: Observable<String> { feelLikeSubject.map { "Feels Like: \(self.transformTemperature(temperature: $0))" }.asObservable()}
    var showalert: Observable<String> { alertSubject.asObservable()}
    var data: Observable<[DailyWeatherModel]> { dataSubject.asObservable()}
    
    var outs: WeatherViewModelOutputs {
        return self
    }
    
    init(weatherService: WeatherFetchServiceProtocol, locationService: LocationServiceProtocol) {
        self.weatherService = weatherService
        self.locationService = locationService
        
        //fetchLocation()
    }
    
    func fetchLocation() {
        locationService.startFetchingLocation()
        locationService.locationObservable.subscribe(onNext: { [weak self] city in
                                                        self?.fetch(with: city)
                                                        self?.locationSubject.onNext(city)
        },
                                                     onError: { error in
                                                            self.alertSubject.onNext(error.localizedDescription)
                                                     }).disposed(by: bag)
    }
    
    private func fetch(with cityName: String) {
        fetchCurrentWeather(with: cityName)
        fetchForecastWeather(with: cityName)
    }
    
    private func fetchCurrentWeather(with cityName: String) {
        debugPrint("city Name:\(cityName)")
        weatherService.fetchCurrentWeather(cityName: cityName).subscribe ( onNext: { [weak self] currentWeatherModel in
            
            print("weather city\(currentWeatherModel.main)")
            self?.temperatureSubject.onNext(currentWeatherModel.main.temp)
            self?.imageSubject.onNext(currentWeatherModel.weather.first?.icon)
            self?.temperatureMaxSubject.onNext(currentWeatherModel.main.temp_max)
            self?.temperatureMinSubject.onNext(currentWeatherModel.main.temp_min)
            self?.humiditySubject.onNext(currentWeatherModel.main.humidity)
            self?.feelLikeSubject.onNext(currentWeatherModel.main.feels_like)
        }, onError: { error in
            // send error
            debugPrint("\(error)")
            self.alertSubject.onNext(error.localizedDescription)
        }).disposed(by: bag)
    }
    
    private func fetchForecastWeather(with cityName: String) {
        weatherService.fetchForecastWeather(cityName: cityName).subscribe (onNext: { [weak self] forcastWeatherModel in
            
            debugPrint("weather city: \(forcastWeatherModel.forecastWeatherList.count)")
            self?.dataSubject.onNext(forcastWeatherModel.forecastWeatherList)
        }, onError: { error in
            // send error
            debugPrint("\(error)")
            self.alertSubject.onNext(error.localizedDescription)
        }).disposed(by: bag)
    }
    
    
}

private extension WeatherViewModel {
    //MARK:- helper methods
    
    func transformTemperature(temperature: Double?, emptyStateString: String = "- -") -> String {
        return temperature == nil ? emptyStateString : temperature?.convertToCelciusTemperature() ?? "- -"
    }
}
