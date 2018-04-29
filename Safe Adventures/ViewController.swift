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

class ViewController: UIViewController {
    private let darkSkyAPIKey = "4a76b0aa817f065da1ac4e81d94b70de"
    let weatherClient: DarkSkyClient
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        weatherClient = DarkSkyClient(apiKey: darkSkyAPIKey)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadPark("yosemite") { (park) in
            if park != nil {
                print(park!.description)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Private - Call DarkSky APIs
    /*
    func weather(_ today: Bool, ) -> <#return type#> {
        <#function body#>
    }*/

    // Private - Load Mock JSON
    // Lots of reusable code, but not sure how to take in generic version of Decodable, look more into this
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
    
    /*
    private func parseLatLongString(latLongString: String) -> (lat: String, long: String) {
        // Format is: "lat:37.29839254, long:-113.0265138"
        let latLongSplitArray = latLongString.split(separator: ",")
        let lat = latLongSplitArray.first
        let long = latLongSplitArray.last
        
        // Format is: "lat:37.29839254" and "long:-113.0265138"
        if let
    }*/
    
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

