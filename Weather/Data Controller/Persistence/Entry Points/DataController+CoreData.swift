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
    func stationResultsFetchResultsController() -> NSFetchedResultsController<StationResult> {
        let request = NSFetchRequest<StationResult>(entityName: "StationResult")
        
        let stationNamePredicate = Predicate(format: "name.length > 0")
        request.predicate = stationNamePredicate
        
        request.sortDescriptors = [distanceSortDescriptorAscending]
        
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: persistenceController.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return frc
    }
    
    var dateSortDescriptorAscending: SortDescriptor {
        return SortDescriptor(key: "date", ascending: true)
    }

    var dateSortDescriptorDescending: SortDescriptor {
        return SortDescriptor(key: "date", ascending: false)
    }
    
    var distanceSortDescriptorAscending: SortDescriptor {
        return SortDescriptor(key: "distance", ascending: true)
    }

    var distanceSortDescriptorDescending: SortDescriptor {
        return SortDescriptor(key: "distance", ascending: false)
    }

    var nameSortDescriptorAscending: SortDescriptor {
        return SortDescriptor(key: "name", ascending: true)
    }

    var nameSortDescriptorDescending: SortDescriptor {
        return SortDescriptor(key: "name", ascending: false)
    }

    
    var allTimesPredicate: Predicate {
        return Predicate(format: "name.length > 0")
    }
    
    var lastThirtyMinutesTimePredicate: Predicate {
        return Predicate(format: "name.length > 0 AND date >= %@", Date().addingTimeInterval(-(60*30)))
    }
    
    var lastHourTimePredicate: Predicate {
        return Predicate(format: "name.length > 0 AND date >= %@", Date().addingTimeInterval(-(60*60)))
    }
    
    var lastTwoHoursTimePredicate: Predicate {
        return Predicate(format: "name.length > 0 AND date >= %@", Date().addingTimeInterval(-(60*120)))
    }

    var lastFourHoursTimePredicate: Predicate {
        return Predicate(format: "name.length > 0 AND date >= %@", Date().addingTimeInterval(-(60*240)))
    }
}
