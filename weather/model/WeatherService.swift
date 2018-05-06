//
//  HTTPService.swift
//  weather
//

import Foundation
import CoreLocation
import UIKit

class WeatherService {
    private let weatherString = "http://api.openweathermap.org/data/2.5/forecast"
    private let APIKEY = ""
    private let iconString = "http://openweathermap.org/img/w/"
    
    var weather: Weather?
    
    func getWeather(coords: CLLocationCoordinate2D, completion: @escaping (Weather?, String?) -> ()) {
        
        guard let url = generateRequestURL(coords: coords) else { return}
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data,response,error) in
            guard error == nil else { completion(nil, error?.localizedDescription)
                return
            }
                if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                        print("error json")
                        return
                    }
                    
                    guard let array = json as? [String: Any],
                    let cityArray = array["city"] as? [String: Any],
                    let city = cityArray["name"] as? String,
                    let list = array["list"] as? [Any] else { print("error parse")
                        return
                    }
                    
                    guard let firstList = list[0] as? [String: Any],
                        let mainArray = firstList["main"] as? [String: Any],
                        let temp = mainArray["temp"] as? Double,
                        
                        let weatherArray = firstList["weather"] as? [Any],
                        let firstWeather = weatherArray[0] as? [String:Any],
                        let main = firstWeather["main"] as? String,
                        let description = firstWeather["description"] as? String,
                        let icon = firstWeather["icon"] as? String,
                        
                        let currentTime = firstList["dt"] as? Int
                        
                        else { print("parse error")
                            return
                    }
                    
                    var forecasts: [Forecast] = []
                    for i in 1..<list.count {
                        guard let firstList = list[i] as? [String: Any],
                            let mainArray = firstList["main"] as? [String: Any],
                            let temp = mainArray["temp"] as? Double,
                            
                            let weatherArray = firstList["weather"] as? [Any],
                            let firstWeather = weatherArray[0] as? [String:Any],
                            let icon = firstWeather["icon"] as? String,
                            
                            let time = firstList["dt"] as? Int
                            
                            else { print("parse error")
                                return
                        }
                        let forecast = Forecast(time: self.hourFromTimestamp(timestamp: time), icon: icon, temp: self.convertedTemp(temp: temp))
                        forecasts.append(forecast)
                    }
            
            self.weather = Weather(city: city, temp: self.convertedTemp(temp: temp), main: main, description: description, currentTime: self.timeFromTimestamp(timestamp: currentTime), icon: icon, forecasts: forecasts)
                completion(self.weather, nil)
            }
        }
        dataTask.resume()
    }
    
    func generateRequestURL(coords: CLLocationCoordinate2D)->URL? {
        guard var urlComponents = URLComponents(string: weatherString) else { return nil }
        urlComponents.queryItems = [URLQueryItem(name: "lat", value: String(coords.latitude)),
                                    URLQueryItem(name: "lon", value: String(coords.longitude)),
                                    URLQueryItem(name: "APPID", value: APIKEY)]
        return urlComponents.url
    }
    
    func timeFromTimestamp(timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    func hourFromTimestamp(timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        return formatter.string(from: date)
    }
    
    func convertedTemp(temp: Double) -> String {
        //return round((temperature - 273.15) * 1.8 + 32)
        return String(round(temp - 273.5))
    }
    
    func loadIcon(icon: String, completion: @escaping (UIImage) -> Void) {
        guard let url = URL(string: iconString + icon + ".png") else { return }
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            guard error == nil, let data = data else { return }
            
            if let image = UIImage(data: data) {
                completion(image)
            
            }
        }).resume()
    }
}
