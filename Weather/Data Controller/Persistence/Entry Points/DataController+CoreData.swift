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

extension DataController {
    func stationResultsFetchResultsController() -> NSFetchedResultsController {
        let request = NSFetchRequest(entityName: "StationResult")
        
        let stationNamePredicate = NSPredicate(format: "name.length > 0")
        request.predicate = stationNamePredicate
        
        let distanceSort = NSSortDescriptor(key: "distance", ascending: true)
        request.sortDescriptors = [distanceSort]
        
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return frc
    }
}