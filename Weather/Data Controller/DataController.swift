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

enum DataControllerResult<T> {
    case success(T)
    case error(NSError)
}

class DataController {
    let networkController = NetworkController()
    let persistenceController = PersistenceController()
    
    let operationQueue = OperationQueue()
    
    func initCoreDataStack(_ completion: @escaping () -> ()) {
        persistenceController.initCoreDataStack() {
            completion()
        }
    }
    
    func save() {
        persistenceController.save()
    }
}
