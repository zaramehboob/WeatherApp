//
//  Double+Extensions.swift
//  WeatherApp
//
//  Created by Zara on 9/9/21.
//

import Foundation


extension Double {

    private var convertionValue: Double  { 273.15 }
    func convertToCelciusTemperature() -> String {
        let measurement = Measurement(value: self - convertionValue, unit: UnitTemperature.celsius)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .short
        formatter.numberFormatter.minimumFractionDigits = 1
        return formatter.string(from: measurement)
    }

}
