//
//  ViewController.swift
//  Safe Adventures
//
//  Created by Ambuj Punn on 4/28/18.
//  Copyright © 2018 Ambuj Punn. All rights reserved.
//

import UIKit
import ForecastIO

struct Parks: Decodable {
    var parkList: [Park]
    
    enum CodingKeys: String, CodingKey {
        case parkList = "parks"
    }
}

struct Park: Decodable {
    var name: String
    var location: String
    var description: String
    var url: String
    var imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case name = "fullName"
        case location = "latLong"
        
        case description
        case imageUrl
        case url
    }
}

struct HikingGear: Decodable {
    var essentials: [String]
    var clothing: [String: [String]]
    var condition: [String: [String]]
    
    enum CodingKeys: String, CodingKey {
        case clothing = "dress"
        
        case essentials
        case condition
    }
}

struct Weather {
    var today: Bool
    var currentTemp: Float?
    var dayTempMax: Float?
    var dayTempMaxTime: Date?
    var dayTempMin: Float?
    var dayTempMinTime: Date?
    var summary: String?
    var iconInfo: Icon?
    var alert: String?
    
    init(today: Bool, foreCast: Forecast) {
        self.today = today
        self.currentTemp = foreCast.currently?.apparentTemperature
        self.dayTempMax = foreCast.daily?.data.first?.apparentTemperatureMax
        self.dayTempMin = foreCast.daily?.data.first?.apparentTemperatureMin
        self.dayTempMaxTime = foreCast.daily?.data.first?.apparentTemperatureMaxTime
        self.dayTempMinTime = foreCast.daily?.data.first?.apparentTemperatureMinTime
        self.summary = foreCast.daily?.data.first?.summary
        self.iconInfo = foreCast.daily?.data.first?.icon
        self.alert = foreCast.alerts?.first?.description
    }
}

class ViewController: UIViewController {
    private let darkSkyAPIKey = "4a76b0aa817f065da1ac4e81d94b70de"
    let weatherClient: DarkSkyClient
    
    required init?(coder aDecoder: NSCoder) {
        weatherClient = DarkSkyClient(apiKey: darkSkyAPIKey)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Testing
        loadPark("yosemite") { (park) in
            if park != nil {
                print(park!.description)
                let (lat, long) = parseLatLongString(latLongString: park!.location)
                weatherToday(lat: lat, long: long, completionHandler: { (forecast) in
                    let weatherDataModel = Weather(today: true, foreCast: forecast)
                    print("Today: \n")
                    print(weatherDataModel)
                })
                let testDate = Date(timeIntervalSince1970: 1525003200)
                weatherDate(date: testDate, lat: lat, long: long, completionHandler: { (forecast) in
                    let weatherDataModel = Weather(today: false, foreCast: forecast)
                    print("later: \n")
                    print(weatherDataModel)
                })
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Private - Call DarkSky APIs
    // Pass in completion handler
    func weatherToday(lat: String, long: String, completionHandler: @escaping (Forecast) -> Void) {
        // Force unwrapping because we are sure the lat long will be legit
        weatherClient.getForecast(latitude: Double(lat)!, longitude: Double(long)!, extendHourly: false, excludeFields: [.hourly, .minutely, .flags]) { (result) in
            switch result {
            case .success(let currentForecast, let requestMetadata):
                completionHandler(currentForecast)
            case .failure(let error):
                print (error)
            }
        }
        
        //Note: Use currently's temperature to get current temperature
        // Use daily's data's first element to get current day's temp max/min and temp max/min time
    }

    func weatherDate(date: Date, lat: String, long: String, completionHandler: @escaping (Forecast) -> Void) {
        // Force unwrapping because we are sure the lat long will be legit
        weatherClient.getForecast(latitude: Double(lat)!, longitude: Double(long)!, time: date, excludeFields: [.hourly, .minutely, .flags]) { (result) in
            switch result {
            case .success(let currentForecast, let requestMetadata):
                completionHandler(currentForecast)
            case .failure(let error):
                print (error)
            }
        }
        
        //Note: Use currently's temperature to get current temperature
        // Use daily's data's first element to get current day's temp max/min and temp max/min time
    }
    
    // Private - Load Mock JSON
    // Lots of reusable code, but not sure how to take in generic version opf Decodable, look more into this
    // Reference: https://stackoverflow.com/questions/46962021/how-to-reference-a-generic-decodable-struct-in-swift-4
    
    private func loadPark(_ name: String, completionHandler: (Park?) -> Void) {
        if let parkJsonData = loadJson("parks") {
            do {
                let parks = try JSONDecoder().decode(Parks.self, from: parkJsonData)
                // Only returns data once the entire name of the park is entered (it's a hackathon remember, it's okay to not write great code lol
                // Filter it so the match is the first element
                let foundPark = parks.parkList.filter({ (park) -> Bool in
                    return park.name.lowercased().contains(name)
                }).first
                completionHandler(foundPark)
            } catch {
                print("error:\(error)")
            }
        }
    }
    
    private func parseLatLongString(latLongString: String) -> (String, String) {
        // Format is: "lat:37.29839254, long:-113.0265138"
        let latLongSplitArray = latLongString.split(separator: ",")
        // Will not break because of mocked out data and its a hackathon so relax bro
        let latString = String(latLongSplitArray.first!)
        let longString = String(latLongSplitArray.last!)
        
        // Format is: "lat:37.29839254", "long:-113.0265138"
        let indexColonLat = latString.index(after:latString.index(of: ":")!)
        let indexColonLong = longString.index(after: longString.index(of: ":")!)
        
        // Force unwrapping because we are sure of the format mentioned above^
        return (String(latString[indexColonLat...]), String(longString[indexColonLong...]))
    }
    
    private func loadHikingGear(_ name: String, completionHandler: (HikingGear) -> Void) {
        if let hikingGearJsonData = loadJson("hiking-gear") {
            do {
                let hikingGear = try JSONDecoder().decode(HikingGear.self, from: hikingGearJsonData)
                completionHandler(hikingGear)
            } catch {
                print("error:\(error)")
            }
        }
    }
    
    private func loadJson(_ fileName: String) -> Data? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                return data
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
    
}

