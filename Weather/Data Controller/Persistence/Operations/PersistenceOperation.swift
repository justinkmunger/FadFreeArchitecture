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

enum PersistenceResult {
    case Success
    case Error(NSError)
}

class PersistenceOperation: BaseOperation {
    let parentContext: NSManagedObjectContext
    
    var responseJSON: AnyObject?
    
    init(parentContext: NSManagedObjectContext) {
        self.parentContext = parentContext
        
        super.init()
    }
    
    override func start() {
        if cancelled {
            state = .Finished
            return
        }
    
        guard let responseJSONProvider = dependencies.filter({ $0 is JSONResponseProvider }).first as? JSONResponseProvider else {
            state = .Finished
            return
        }

        guard let responseJSON = responseJSONProvider.responseJSON else {
            state = .Finished
            return
        }
        
        self.responseJSON = responseJSON

        state = .Executing
        
        let childContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        childContext.parentContext = parentContext

        persistData(childContext)
        
        state = .Finished
    }

    func persistData(childContext: NSManagedObjectContext) {}
}