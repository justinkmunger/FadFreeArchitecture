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

class DataController {
    
    let rootURL: NSURL
    
    let networkController = NetworkController()
    
    let operationQueue = NSOperationQueue()
    let managedObjectContext: NSManagedObjectContext
    let persistenceStoreCoordinator: NSPersistentStoreCoordinator
    private let writerContext: NSManagedObjectContext
    
    init() {
        guard let modelURL = NSBundle.mainBundle().URLForResource("Weather", withExtension: "momd") else {
            fatalError("Unable to find model file")
        }
        
        guard let model = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Failed to initialize data model")
        }
        
        guard let rootURL = NSURL(string: "http://api.openweathermap.org") else {
            fatalError("failed to initialize endpointURL")
        }
        
        self.rootURL = rootURL
        
        persistenceStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        writerContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        writerContext.persistentStoreCoordinator = persistenceStoreCoordinator
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.parentContext = writerContext
    }
    
    func initCoreDataStack(completion: () -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let fileManager = NSFileManager.defaultManager()
            let docURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last
            
            guard let storeURL = docURL?.URLByAppendingPathComponent("data.sqlite") else {
                fatalError("Unable to resolve persistent store URL")
            }
            
            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
            
            do {
                try self.persistenceStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options)
            } catch {
                fatalError("Unable to add persistent store")
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completion()
            }
        }
    }
            
    func save() {
        if !NSThread.isMainThread() {
            dispatch_sync(dispatch_get_main_queue()) {
                self.save()
            }
            return
        }
        
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Handle error here
            }
        }
        
        writerContext.performBlock() {
            do {
                if self.writerContext.hasChanges {
                    try self.writerContext.save()
                }
            } catch {
                dispatch_async(dispatch_get_main_queue()) {
                    // Handle error here
                }
            }
        }
    }
}
