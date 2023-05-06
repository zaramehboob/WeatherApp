//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Zara on 9/7/21.
//

import Foundation
import RxSwift
import UIKit
import RxCocoa
import SDWebImage


class WeatherViewController: UIViewController {
    
    private let cellIdentifier = "forecast_cell"
    private var viewModel: WeatherViewModelType!
    private var disposeBag = DisposeBag()
    
    private lazy var locationLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor =  UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tempLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 37, weight: .heavy)
        label.textColor =  UIColor.white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var tempMinLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var tempMaxLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor =  UIColor.gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var humidityLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var feelLikeLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [tempMaxLbl, tempMinLbl, humidityLbl])
        stackView.spacing = 5
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .clear
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(ForecastCell.self, forCellWithReuseIdentifier: cellIdentifier)
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.scrollDirection = .vertical
        flowlayout.itemSize = CGSize(width: 0, height: 0)
        view.setCollectionViewLayout(flowlayout, animated: true)
        view.backgroundColor = .clear
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setUpConstraints()
        bind()
        subscribeErrorAlert()
        setupCollectionViewConstraints()
        bindCollectionView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
    }
    
    init(viewModel: WeatherViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

private extension WeatherViewController {
    
    func setUpConstraints() {
        //topview constraints
        topView
            .alignEdgesWithSuperview([.top, .right, .left])
            .height(with: .height, ofView: view, multiplier: 0.4)
        
        bottomView
            .alignEdges([.left , .right , .bottom], withView: view)
            .toBottomOf(topView)
        
        //lbl constraints
        tempLbl
            .centerInSuperView()
            .height(constant: 29)
        //.width(with: .width, ofView: view, multiplier: 0.5)
        
        feelLikeLbl
            .centerHorizontallyInSuperview()
            .width(with: .width, ofView: topView, multiplier: 0.38)
            .height(constant: 20)
            .toBottomOf(tempLbl, constant: 10)
        
        locationLbl
            // .alignEdgesWithSuperview([.right, .left])
            .height(constant: 20)
            .toTopOf(tempLbl, constant: 20)
            .centerHorizontallyInSuperview()
        
        // imageView constraints
        imageView.width(constant: 50)
            .height(constant: 50)
            .toLeftOf(tempLbl, constant: 5)
            .verticallyCenterWith(tempLbl)
        
        // stackView constraints
        horizontalStackView
            .alignEdges([.bottom, .left, .right], withView: topView , constants: [5, 5 , 5])
            .height(constant: 40)
    
    }
    
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(topView)
        view.addSubview(bottomView)
        
        topView.addSubview(locationLbl)
        topView.addSubview(tempLbl)
        topView.addSubview(imageView)
        topView.addSubview(horizontalStackView)
        topView.addSubview(feelLikeLbl)
        bottomView.addSubview(collectionView)
    }
    
    func bind() {
        
        // bind labels
        viewModel.outs.location.bind(to: locationLbl.rx.text).disposed(by: disposeBag)
        viewModel.outs.temperature.bind(to: tempLbl.rx.text).disposed(by: disposeBag)
        
        viewModel.outs.temperatureMax.bind(to: tempMaxLbl.rx.text).disposed(by: disposeBag)
        
        viewModel.outs.temperatureMin.bind(to: tempMinLbl.rx.text).disposed(by: disposeBag)
        
        viewModel.outs.humidity.bind(to: humidityLbl.rx.text).disposed(by: disposeBag)
        
        viewModel.outs.feelLike.bind(to: feelLikeLbl.rx.text).disposed(by: disposeBag)
        
        viewModel.outs.location.bind(to: locationLbl.rx.text).disposed(by: disposeBag)
        
        //bind Image
        viewModel.outs.weatherImg.subscribe (onNext: { [weak self] iconString in
            self?.imageView.downloadImage(url: URL(string: "\(BaseUrl.imageBaseUrl.url)\(iconString ?? "")@2x.png"))
        }).disposed(by: disposeBag)
        
    }
}

private extension WeatherViewController {
    func subscribeErrorAlert() {
        viewModel.outs.showalert.subscribe(onNext: { errorMsg in
           let alert = UIAlertController(title: NSLocalizedString("Oops, something went wrong.", comment: ""), message: errorMsg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
}

extension WeatherViewController: UICollectionViewDelegateFlowLayout {
    
    func setupCollectionViewConstraints() {
        collectionView.alignAllEdgesWithSuperview()
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
    }
    
    func bindCollectionView() {
        viewModel.outs.data.bind(to: collectionView.rx.items(cellIdentifier: cellIdentifier, cellType: ForecastCell.self)) { row, data, cell in
            print("\(data)")
            cell.rowNumber = row
            cell.item = data
            
        }.disposed(by: disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = collectionView.bounds.width
            let cellWidth = (width)
            return CGSize(width: cellWidth, height: 50)
        }
}

