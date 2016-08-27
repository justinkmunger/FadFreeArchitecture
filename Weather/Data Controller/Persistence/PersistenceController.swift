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

class PersistenceController {

    let managedObjectContext: NSManagedObjectContext
    let persistenceStoreCoordinator: NSPersistentStoreCoordinator
    private let writerContext: NSManagedObjectContext
    
    init() {
        guard let modelURL = Bundle.main.url(forResource: "Weather", withExtension: "momd") else {
            fatalError("Unable to find model file")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to initialize data model")
        }
        
        persistenceStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        writerContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        writerContext.persistentStoreCoordinator = persistenceStoreCoordinator
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.parent = writerContext
    }
    
    func initCoreDataStack(_ completion: @escaping () -> ()) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            let fileManager = FileManager.default
            let docURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last
            
            guard let storeURL = docURL?.appendingPathComponent("data.sqlite") else {
                fatalError("Unable to resolve persistent store URL")
            }
            
            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
            
            do {
                try self.persistenceStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
            } catch {
                fatalError("Unable to add persistent store")
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func save() {
        if !Thread.isMainThread {
            DispatchQueue.main.sync {
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
        
        writerContext.perform() {
            do {
                if self.writerContext.hasChanges {
                    try self.writerContext.save()
                }
            } catch {
                DispatchQueue.main.async {
                    // Handle error here
                }
            }
        }
    }
}
