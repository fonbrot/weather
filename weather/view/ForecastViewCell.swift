//
//  ForecastViewCell.swift
//  weather


import UIKit

class ForecastViewCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    
    var forecast: Forecast?
    
    let weatherService = WeatherService()
    
    func configureCell() {
        if let forecast = forecast {
            timeLabel.text = forecast.time
            tempLabel.text = forecast.temp
            weatherService.loadIcon(icon: forecast.icon) { image in
                DispatchQueue.main.async {
                    self.iconView.image = image
                }
            }
        }
    }
}
