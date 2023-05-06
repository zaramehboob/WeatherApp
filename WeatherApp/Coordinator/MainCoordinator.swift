//
//  MainCoordinator.swift
//  WeatherApp
//
//  Created by Zara on 9/8/21.
//

import Foundation
import UIKit

protocol Coordinator {
    func start()
}

class MainCoordinator: Coordinator {
    private var window: UIWindow!
    
    init(window: UIWindow) {
        self.window = window
    }
 
    func start() {
        let sessionConfiguration = SessionConfiguration()
        
        let viewModel = WeatherViewModel(weatherService: WeatherFetchService(builder: RequestBuilder(), client: AlamofireClient(configuration: sessionConfiguration)), locationService: LocationService())
        viewModel.fetchLocation()
        let weather = WeatherViewController(viewModel: viewModel)
        
       self.window.rootViewController = weather
    }
}
