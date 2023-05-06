//
//  ForecastCell.swift
//  WeatherApp
//
//  Created by Zara on 9/9/21.
//

import Foundation

import UIKit
private let totalWeekDays = 7
private let weekNamesDict = [2: "Monday",  3: "Tuesday", 4: "Wednesday",  5: "Thursday" , 6: "Friday",   7: "Saturday",  1: "Sunday"]
class ForecastCell: UICollectionViewCell {
    
    private var weekNameArray = [String]()
    
    private var tempMinLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var tempMaxLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor =  UIColor.gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var humidityLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var rainLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var weekday: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .clear
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [weekday, tempMaxLbl, tempMinLbl, imageView, humidityLbl, rainLbl])
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        getWeekdayListFromToday()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.addSubview(horizontalStackView)
        
        imageView.height(constant: 40).width(constant: 40)
        horizontalStackView.alignAllEdgesWithSuperview()
    }
    var rowNumber: Int = 0
    var item: DailyWeatherModel? {
        didSet {
            tempMinLbl.text = item?.main.temp_min.convertToCelciusTemperature()
                tempMaxLbl.text = item?.main.temp_max.convertToCelciusTemperature()
            self.imageView.downloadImage(url: URL(string: "\(BaseUrl.imageBaseUrl.url)\(item?.weather.first?.icon ?? "")@2x.png"))
                humidityLbl.text = String(format: "%d %@", item?.main.humidity ?? 0, "%")
            rainLbl.text = String(format: "%.1f", item?.rain?.rain ?? 0)
            weekday.text = weekNameArray[rowNumber]
        }
    }
}

extension ForecastCell {
   // MARK: - HELPER METHODS
    
    func getWeekdayListFromToday() {
        var today = Calendar.current.component(.weekday, from: Date())
        for _ in 0..<totalWeekDays {
            today = today+1
            let value = weekNamesDict[today]
           // debugPrint("\(value)")
            weekNameArray.append(value ?? "")
            if today == totalWeekDays {
                today = 0
            }
        }
    }
    
}
