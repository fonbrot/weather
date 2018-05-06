//
//  Weather.swift
//  weather
//
//  Created by 1 on 30/04/2018.
//  Copyright © 2018 av. All rights reserved.
//

import Foundation

struct Weather {
    var city: String
    var temp: String
    var main: String
    var description: String
    var currentTime: String
    var icon: String
    
    var forecasts: [Forecast]
}
