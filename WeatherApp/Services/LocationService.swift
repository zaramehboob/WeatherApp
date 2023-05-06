//
//  LocationService.swift
//  WeatherApp
//
//  Created by Zara on 9/10/21.
//

import Foundation
import CoreLocation
import RxSwift

enum LocationError: Error {
    case locationError
}

protocol LocationServiceProtocol {
    func startFetchingLocation()
    var locationObservable: Observable<String>  {get}
}

class LocationService: NSObject, CLLocationManagerDelegate, LocationServiceProtocol {
    private let locationManager = CLLocationManager()
    private var locationSubject = PublishSubject<String>()
    public var locationObservable: Observable<String>  {
        return locationSubject.asObservable()
    }
    
    override init() {
        super.init()
        
    }
    
    func startFetchingLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            return
        }
        debugPrint("locations = \(locValue.latitude) \(locValue.longitude)")
        let location = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        debugPrint("locations = \(location)")
        let geoDecoder = CLGeocoder()
        geoDecoder.reverseGeocodeLocation(location, preferredLocale: .current) { [weak self] result, error in
            if error == nil {
                let city = result?.first?.locality
                self?.locationSubject.onNext(city ?? "London")
            } else {
                self?.locationSubject.onError(LocationError.locationError)
            }
            self?.locationSubject.onCompleted()
            self?.locationManager.stopUpdatingLocation()
        }
    }
}
