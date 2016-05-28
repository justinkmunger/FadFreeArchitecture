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

enum NetworkResult<T> {
    case Success(T)
    case Error(NSError)
}

class NetworkOperation: BaseOperation {
    let task: NSURLSessionTask
    
    var myData = NSMutableData()
        
    init(task: NSURLSessionTask) {
        self.task = task
        
        super.init()
    }
    
    override func start() {
        if cancelled {
            state = .Finished
            return
        }
        
        task.resume()
        
        state = .Executing
    }
        
    func processData() {}
    
    func didReceiveResponse(response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        if cancelled {
            state = .Finished
            task.cancel()
            return
        }
        
        guard let httpResponse = response as? NSHTTPURLResponse else {
            fatalError("Unexpected response")
        }
        
        if httpResponse.statusCode != 200 {
            completionHandler(.Cancel)
            return
        }
        
        completionHandler(.Allow)
    }
    
    func didReceiveData(data: NSData) {
        if cancelled {
            state = .Finished
            task.cancel()
            return
        }
        
        myData.appendData(data)
    }
    
    func didCompleteWithError(error: NSError?) {
        if cancelled {
            state = .Finished
            task.cancel()
            return
        }
        
        if error != nil {
            myError = error
            state = .Finished
            return
        }
        
        processData()
        
        state = .Finished
    }
}