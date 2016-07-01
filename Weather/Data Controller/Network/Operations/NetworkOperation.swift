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
    case success(T)
    case error(NSError)
}

protocol JSONResponseProvider {
    var responseJSON: AnyObject? { get }
}

class NetworkOperation: BaseOperation, JSONResponseProvider {
    let task: URLSessionTask
    
    var myData = NSMutableData()
    
    var responseJSON: AnyObject?
    
    init(task: URLSessionTask) {
        self.task = task
        
        super.init()
    }
    
    override func start() {
        if isCancelled {
            state = .Finished
            return
        }
        
        task.resume()
        
        state = .Executing
    }
        
    func processData() {}
    
    func didReceiveResponse(_ response: URLResponse, completionHandler: (URLSession.ResponseDisposition) -> Void) {
        if isCancelled {
            state = .Finished
            task.cancel()
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            fatalError("Unexpected response")
        }
        
        if httpResponse.statusCode != 200 {
            completionHandler(.cancel)
            return
        }
        
        completionHandler(.allow)
    }
    
    func didReceiveData(_ data: Data) {
        if isCancelled {
            state = .Finished
            task.cancel()
            return
        }
        
        myData.append(data)
    }
    
    func didCompleteWithError(_ error: NSError?) {
        if isCancelled {
            state = .Finished
            task.cancel()
            return
        }
        
        if error != nil {
            myError = error
            state = .Finished
            return
        }
        
        do {
            self.responseJSON = try JSONSerialization.jsonObject(with: myData as Data, options: .allowFragments)
        } catch let error as NSError {
            myError = error
            state = .Finished
        }
        
        state = .Finished
    }
}
