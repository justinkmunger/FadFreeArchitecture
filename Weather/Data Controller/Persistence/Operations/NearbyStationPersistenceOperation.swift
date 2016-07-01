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

import CoreData
import Foundation

class NearbyStationPersistenceOperation: PersistenceOperation {
    override func persistData(_ childContext: NSManagedObjectContext) {
        
        guard let stationsJSON = responseJSON as? [[String: AnyObject]] else {
            return
        }
        
        childContext.performAndWait {
            for stationJSON in stationsJSON {
                if let stationID = StationResult.getStationID(stationJSON) {
                    
                    var existingStation: StationResult?
                    
                    let fetchRequest = NSFetchRequest<StationResult>(entityName: "StationResult")
                    
                    let idPredicate = Predicate(format: "stationID = %d", stationID)
                    fetchRequest.predicate = idPredicate
                    
                    do {
                        let stationObjects = try childContext.fetch(fetchRequest)
                        existingStation = stationObjects.first
                    } catch {
                        self.myError = error
                        self.state = .Finished
                        return
                    }
                    
                    if let existingStation = existingStation {
                        existingStation.populateWithJSON(stationJSON)
                    } else {
                        guard let stationResult = NSEntityDescription.insertNewObject(forEntityName: "StationResult", into: childContext) as? StationResult else {
                            fatalError("Couldn't create new StationResult")
                        }
                        
                        stationResult.populateWithJSON(stationJSON)
                    }
                }
            }
            
            do {
                try childContext.save()
            } catch {
                childContext.rollback()
                self.myError = error
            }
        }
    }
}
