//
//  WeatherViewModelTests.swift
//  WeatherAppTests
//
//  Created by Zara on 9/10/21.
//

import XCTest
@testable import WeatherApp //internal values are accessible as well
import RxSwift
import RxBlocking
import RxTest

enum FetchStatus {
    case success
    case failure
}

enum WeatherModels<T> {
    case current
    case forecast
    
    var responseModel: T  {
        switch self {
        case .current:
            let mainInfo = MainInfo(temp: 300.0, temp_min: 320.0, temp_max: 334.0, feels_like: 332.0, humidity: 12)
            let weatherInfo = WeatherInfo(icon: "0d")
            let model = CurrentWeatherModel(main: mainInfo, weather: [weatherInfo])
            return model as! T
            
        case .forecast:
            
            let mainInfo = MainInfo(temp: 300.0, temp_min: 320.0, temp_max: 334.0, feels_like: 332.0, humidity: 12)
            let weatherInfo = WeatherInfo(icon: "0d")
            let dailyWeather_one = DailyWeatherModel(main: mainInfo, weather: [weatherInfo], rain: RainInfo(rain: 20.0))
            let dailyWeather_two = DailyWeatherModel(main: mainInfo, weather: [weatherInfo], rain: RainInfo(rain: 20.0))
            
            return ForecastWeatherModel(forecastWeatherList: [dailyWeather_one, dailyWeather_two]) as! T
            
       
        }
    }
}


struct MockFetchWeatherService: WeatherFetchServiceProtocol {
    var status: FetchStatus!
    var forecastModel: ForecastWeatherModel?
    var currentWeatherModel: CurrentWeatherModel?
    
    init(status: FetchStatus, forecastModel: ForecastWeatherModel? = nil, weatherModel: CurrentWeatherModel? = nil) {
        self.status = status
        self.forecastModel = forecastModel
        self.currentWeatherModel = weatherModel
    }
    
    func fetchCurrentWeather(cityName: String) -> Observable<CurrentWeatherModel> {
        return Observable.create { observer in
            
            if status == .success {
                if let model = currentWeatherModel {
                    observer.onNext(model)
                }
            } else {
                observer.onError(NSError(domain: "", code: 202, userInfo: [NSLocalizedDescriptionKey: "There is error fetching current weather."]))
            }
            return Disposables.create()
        }
        
    }
    
    func fetchForecastWeather(cityName: String) -> Observable<ForecastWeatherModel> {
        return Observable.create { observer in
            if status == .success {
                if let model = forecastModel {
                    observer.onNext(model)
                }
            }
            return Disposables.create()
        }
        
    }
    
    
}

struct MockLocationService: LocationServiceProtocol {
    func startFetchingLocation() {
        // dont go fetching during test
    }
    
    var locationObservable: Observable<String> {
        return Observable.just("Lahore")
    }
}

class WeatherViewModelTests: XCTestCase {
    
    
    
    func test_fetchCurrentWeather_success() {
        
        let sut = makeSUT(status: .success, weatherModel: WeatherModels.current.responseModel, forecastWeather: nil)
        sut.fetchLocation()
        do {
            //match temperature
            XCTAssertNotNil(try sut.temperature.toBlocking(timeout: 1).first()!)
            debugPrint("events : \( try sut.temperature.toBlocking(timeout: 1).first()!)")
            XCTAssertEqual(try sut.temperature.toBlocking(timeout: 1).first() , 300.0.convertToCelciusTemperature())
        } catch (let error) {
            XCTFail(error.localizedDescription)
        }
        
    }
    
    func test_fetchCurrentWeather_failure() {
        let sut = makeSUT(status: .failure, weatherModel: nil, forecastWeather: nil)
        
        let scheduler = TestScheduler(initialClock: 0, resolution: 1)
        let disposeBag = DisposeBag()
        
        scheduler.scheduleAt(5) {
            // debugPrint("events _1: \(testList.events)")
            sut.fetchLocation()
            
            
        }
        let observer = scheduler.createObserver(String.self)
        sut.showalert.bind(to: observer).disposed(by: disposeBag)
        scheduler.start()
        
        XCTAssertEqual(observer.events, [.next(5, "There is error fetching current weather.")])
    }
    
    func test_fetchForecastWeather() {

        let model = WeatherModels<ForecastWeatherModel>.forecast.responseModel
        let sut = makeSUT(status: .success, weatherModel: nil, forecastWeather: model)
        
        let scheduler = TestScheduler(initialClock: 0, resolution: 1)
        let disposeBag = DisposeBag()
        
        scheduler.scheduleAt(5) {
            // debugPrint("events _1: \(testList.events)")
            sut.fetchLocation()
        }
        
        let testList = scheduler.createObserver([DailyWeatherModel].self)
        sut.data.bind(to: testList).disposed(by: disposeBag)
        scheduler.start()
        
        
        debugPrint("events : \(testList.events)")
        
        XCTAssertRecordedElements(testList.events, [model.forecastWeatherList])
    }
    
}

extension WeatherViewModelTests {
    func makeSUT(status: FetchStatus, weatherModel: CurrentWeatherModel? , forecastWeather: ForecastWeatherModel?) -> WeatherViewModel {
        let mockWeatherService = MockFetchWeatherService(status: status, forecastModel: forecastWeather, weatherModel: weatherModel)
        let mockLocationService = MockLocationService()
        var sut : WeatherViewModel!
        sut = WeatherViewModel(weatherService: mockWeatherService, locationService: mockLocationService)
        return sut
    }
}
