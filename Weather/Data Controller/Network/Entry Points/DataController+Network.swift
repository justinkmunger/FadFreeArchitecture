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

extension DataController {
    func getStations(_ completion: ((DataControllerResult<AnyObject?>)->())?) {
        let nearbyStationNetworkOperation = networkController.getNearbyStationNetworkOperation("41.980953", longitude: "-87.659572")
        nearbyStationNetworkOperation.queuePriority = .normal
        
        let nearbyStationPersistenceOperation = NearbyStationPersistenceOperation(parentContext: persistenceController.managedObjectContext)
        nearbyStationPersistenceOperation.addDependency(nearbyStationNetworkOperation)

        nearbyStationNetworkOperation.completionBlock = { [weak nearbyStationNetworkOperation] in
            guard let strongOperation = nearbyStationNetworkOperation else {
                return
            }
            
            if let completion = completion, let error = strongOperation.myError as? NSError {
                OperationQueue.main.addOperation {
                    completion(.error(error))
                }
            }
        }
        
        nearbyStationPersistenceOperation.completionBlock = { [weak nearbyStationPersistenceOperation] in
            guard let strongOperation = nearbyStationPersistenceOperation else {
                return
            }
            
            if strongOperation.responseJSON == nil {
                return
            }
            
            if let completion = completion {
                OperationQueue.main.addOperation {
                    if let error = strongOperation.myError as? NSError {
                        completion(.error(error))
                    } else {
                        completion(.success(nil))
                    }
                }
            }
        }
        
        operationQueue.addOperations([nearbyStationNetworkOperation, nearbyStationPersistenceOperation], waitUntilFinished: false)
    }
}
