// Copyright © 2016 Justintomobile, LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import CoreData


class StationResult: NSManagedObject {
    func populateWithJSON(stationJSON: [String: AnyObject]) {
        guard var jsonDistance = stationJSON["distance"] as? Double else {
            print("No distance found")
            return
        }
        
        jsonDistance = jsonDistance * 0.62137
        
        guard let station = stationJSON["station"] as? [String: AnyObject], id = station["id"] as? Int else {
            print("No station found")
            return
        }
        
        let jsonName = station["name"] as? String
        
        var jsonTemperature: Double?
        if let last = stationJSON["last"] as? [String: AnyObject], main = last["main"] as? [String: AnyObject] {
            jsonTemperature = main["temp"] as? Double
            
            if jsonTemperature != nil {
                jsonTemperature = 1.8 * (jsonTemperature! - 273.0) + 32.0
            }
        }
        
        print("distance: \(distance)")
        
        stationID = id
        name = jsonName ?? ""
        distance = jsonDistance
        temperature = jsonTemperature ?? Double.NaN
    }
    
    class func getStationID(stationJSON: [String: AnyObject]) -> Int? {
        guard let station = stationJSON["station"] as? [String: AnyObject], id = station["id"] as? Int else {
            print("No station found")
            return nil
        }
        
        return id
    }
}
