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

protocol JSONResponseProvider {
    var responseJSON: Any? { get }
}

class NetworkOperation: BaseOperation, JSONResponseProvider {
    let networkErrorDomainString = "WeatherNetworkErrorDomain"
    let networkErrorObjectUserInfoKey = "WeatherNetworkErrorObjectUserInfoKey"
    
    let task: URLSessionTask
    
    var myData = Data()
    
    var responseJSON: Any?
    
    var statusCode: Int?
    
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
    
    func didReceiveResponse(response: URLResponse, completionHandler: (URLSession.ResponseDisposition) -> Void) {
        if isCancelled {
            state = .Finished
            task.cancel()
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            fatalError("Unexpected response")
        }
        
        self.statusCode = httpResponse.statusCode
        
        completionHandler(.allow)
    }
    
    func didReceiveData(data: Data) {
        if isCancelled {
            state = .Finished
            task.cancel()
            return
        }
        
        myData.append(data)
    }
    
    func didCompleteWithError(error: Error?) {
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
        
        if let statusCode = self.statusCode, (statusCode >= 200 && statusCode < 300) {
            do {
                responseJSON = try JSONSerialization.jsonObject(with: myData, options: .allowFragments)
                state = .Finished                
            } catch {
                myError = error
                state = .Finished
            }
        } else {
            var errorResponseDictionary: [String: AnyObject] = [:]
            
            do {
                errorResponseDictionary = try JSONSerialization.jsonObject(with: myData, options: .allowFragments) as! [String : AnyObject]
            } catch {
                myError = error
                state = .Finished
                return
            }
            myError = NSError(domain: self.networkErrorDomainString, code: self.statusCode ?? -1, userInfo: [networkErrorObjectUserInfoKey: errorResponseDictionary])
            state = .Finished
        }
    }
}
