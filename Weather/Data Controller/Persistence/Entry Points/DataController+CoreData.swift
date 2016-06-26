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
        
        request.sortDescriptors = [distanceSortDescriptorAscending]
        
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: persistenceController.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return frc
    }
    
    var dateSortDescriptorAscending: NSSortDescriptor {
        return NSSortDescriptor(key: "date", ascending: true)
    }

    var dateSortDescriptorDescending: NSSortDescriptor {
        return NSSortDescriptor(key: "date", ascending: false)
    }
    
    var distanceSortDescriptorAscending: NSSortDescriptor {
        return NSSortDescriptor(key: "distance", ascending: true)
    }

    var distanceSortDescriptorDescending: NSSortDescriptor {
        return NSSortDescriptor(key: "distance", ascending: false)
    }

    var nameSortDescriptorAscending: NSSortDescriptor {
        return NSSortDescriptor(key: "name", ascending: true)
    }

    var nameSortDescriptorDescending: NSSortDescriptor {
        return NSSortDescriptor(key: "name", ascending: false)
    }

    
    var allTimesPredicate: NSPredicate {
        return NSPredicate(format: "name.length > 0")
    }
    
    var lastThirtyMinutesTimePredicate: NSPredicate {
        return NSPredicate(format: "name.length > 0 AND date >= %@", NSDate().dateByAddingTimeInterval(-(60*30)))
    }
    
    var lastHourTimePredicate: NSPredicate {
        return NSPredicate(format: "name.length > 0 AND date >= %@", NSDate().dateByAddingTimeInterval(-(60*60)))
    }
    
    var lastTwoHoursTimePredicate: NSPredicate {
        return NSPredicate(format: "name.length > 0 AND date >= %@", NSDate().dateByAddingTimeInterval(-(60*120)))
    }

    var lastFourHoursTimePredicate: NSPredicate {
        return NSPredicate(format: "name.length > 0 AND date >= %@", NSDate().dateByAddingTimeInterval(-(60*240)))
    }
}