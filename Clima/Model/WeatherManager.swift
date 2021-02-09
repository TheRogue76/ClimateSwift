//
//  WeatherManager.swift
//  Clima
//
//  Created by Parsa Nasirimehr on 11/21/1399 AP.
//  Copyright © 1399 AP App Brewery. All rights reserved.
//

import Foundation

protocol WeatherProtocol {
    func didUpdateWeather(_ weatherManager: WeatherManager,weather: WeatherModel) -> Void
    func didFailWithError(_ error: Error)
}

struct WeatherManager {
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=6619ad5b8695cfb466327e2ca33200b0&units=metric"
    var delegate: WeatherProtocol?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherUrl)&q=\(cityName)"
        preformRequest(urlString)
    }
    
    func preformRequest(_ urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, res, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJson(safeData) {
                        self.delegate?.didUpdateWeather(self,weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJson(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            return WeatherModel(conditionId: id, cityName: name, temprature: temp)
            
        } catch  {
            delegate?.didFailWithError(error)
            return nil
        }
    }
}
