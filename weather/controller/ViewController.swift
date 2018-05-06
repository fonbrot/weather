//
//  ViewController.swift
//  weather
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    static let forecastCellIdentifier = "forecastCell"
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var weather: Weather?
    
    let weatherService = WeatherService()
    
    let locationManager: CLLocationManager = CLLocationManager()
    
    @IBAction func chooseCity(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "City", message: "Select city", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
            if let textField = alert.textFields?.first {
                self.getWeather(location: textField.text!)
            }
        })
        alert.addTextField { textField in
            textField.placeholder = "Enter city"
        }
        present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
    }
    
    func getWeather(location: String) {
        CLGeocoder().geocodeAddressString(location) { placemarks, error in
            guard error == nil, let location = placemarks?.first?.location else {
                print("error geocode")
                return
            }
            self.getWeather(coords: location.coordinate)
        }
    }
    
    func getWeather(coords: CLLocationCoordinate2D) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        weatherService.getWeather(coords: coords ) { (weather, error) in
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if error == nil, let weather = weather {
                        self.weather = weather
                    self.updateLabels()
                }
            }
        }
    }
    
    func updateLabels() {
        if let weather = weather {
            title = weather.city
            tempLabel.text = weather.temp
            timeLabel.text = weather.currentTime
            mainLabel.text = weather.main
            descriptionLabel.text = weather.description
            collectionView.reloadData()
            weatherService.loadIcon(icon: weather.icon) { image in
                DispatchQueue.main.async {
                    self.iconView.image = image
                }
            }
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let coords = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            getWeather(coords: coords)
        }
        locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error location")
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weather?.forecasts.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ViewController.forecastCellIdentifier , for: indexPath) as! ForecastViewCell
        if let forecast = weather?.forecasts[indexPath.item] {
            cell.forecast = forecast
            cell.configureCell()
        }
        
        return cell
    }
}
