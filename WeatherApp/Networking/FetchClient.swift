//
//  FetchClient.swift
//  WeatherApp
//
//  Created by Zara on 9/14/21.
//

import Foundation
import Alamofire
import RxSwift

protocol SessionConfigurationProtocol {
    func createSessionConfiguration() -> URLSessionConfiguration
}

final class SessionConfiguration: SessionConfigurationProtocol {
    func createSessionConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        return configuration
    }
}

protocol FetchClient {
    func fetch(with url: URLRequest) -> Observable<APIResponseProtocol>
}


final class AlamofireClient: FetchClient {
    private let sessionManager: Session!
    
    init(configuration: SessionConfigurationProtocol) {
        sessionManager = Session(configuration: configuration.createSessionConfiguration())
    }
    
    func fetch(with url: URLRequest) -> Observable<APIResponseProtocol> {
        return Observable.create { observer in
            self.sessionManager.request(url).validate().responseData { response in
                debugPrint("URL: \(String(describing: response.request?.url))")
                switch response.result {
                case .success:
                    if let data = response.data {
                        //let strigData = String(data: data, encoding: .utf8)
                        
                    let dataModel = APIResponse(data: data, apiError: nil)
                    observer.onNext(dataModel)

                    }
                case .failure(let error):
                    let dataModel = APIResponse(data: nil, apiError: error)
                    observer.onNext(dataModel)
                }
            }
            return Disposables.create()
        }
    }
}
