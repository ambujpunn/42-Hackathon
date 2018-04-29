//
//  ViewController.swift
//  Safe Adventures
//
//  Created by Ambuj Punn on 4/28/18.
//  Copyright © 2018 Ambuj Punn. All rights reserved.
//

import UIKit

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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Private
    
    private func loadPark(_ name: String, completionHandler: (Park) -> Void) {
        if let parkJsonData = loadJson("parks") {
            do {
                let park = try JSONDecoder().decode(Park.self, from: parkJsonData)
                completionHandler(park)
            } catch {
                print("error:\(error)")
            }
        }
    }
    
    private func loadHikingGear(_ name: String, completionHandler: (Park) -> Void) {
        if let parkJsonData = loadJson("parks") {
            do {
                let park = try JSONDecoder().decode(Park.self, from: parkJsonData)
                completionHandler(park)
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

