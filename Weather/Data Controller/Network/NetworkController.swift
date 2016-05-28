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

class NetworkController: NSObject {
    let rootURL: NSURL
    var session: NSURLSession!
    
    private var taskToOperationMap: [NSURLSessionTask: NetworkOperation]

    lazy var apiKey: String = {
        guard let apiKeyPath = NSBundle.mainBundle().pathForResource("APIKey", ofType: "plist") else {
            fatalError("Couldn't find APIKey.plist")
        }

        guard let plistDictionary = NSDictionary(contentsOfFile: apiKeyPath) else {
            fatalError("couldn't initialize dictionayy")
        }
        
        guard let apiKey = plistDictionary["APIKey"] as? String else {
            fatalError("Couldn't find apiKey")
        }
        
        return apiKey
    }()
    
    override init() {
        guard let rootURL = NSURL(string: "http://api.openweathermap.org") else {
            fatalError("failed to initialize endpointURL")
        }
        
        self.rootURL = rootURL

        taskToOperationMap = [NSURLSessionTask: NetworkOperation]()

        super.init()
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 30.0
        
        session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    func getNearbyStationNetworkOperation(latitude: String, longitude: String) -> NearbyStationNetworkOperation {
        let components = NSURLComponents()
        
        components.scheme = rootURL.scheme
        components.host = rootURL.host
        components.path = "/data/2.5/station/find"
        components.query = "lat=\(latitude)&lon=\(longitude)&cnt=30&units=imperial&appid=\(apiKey)"
        
        guard let endpointURL = components.URL else {
            fatalError("couldn't create endpointURL")
        }
        
        let urlRequest = NSMutableURLRequest(URL: endpointURL)
        let task = session.dataTaskWithRequest(urlRequest)
        
        let operation = NearbyStationNetworkOperation(task: task)
        taskToOperationMap[task] = operation
        
        return operation
    }
}

extension NetworkController: NSURLSessionDataDelegate {
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        if let operation = taskToOperationMap[dataTask] {
            if operation.cancelled {
                taskToOperationMap[dataTask] = nil
            } else {
                operation.didReceiveResponse(response, completionHandler: completionHandler)
            }
        }
    }

    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if let operation = taskToOperationMap[dataTask] {
            if operation.cancelled {
                taskToOperationMap[dataTask] = nil
            } else {
                operation.didReceiveData(data)
            }

        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let operation = taskToOperationMap[task] {
            operation.didCompleteWithError(error)
            taskToOperationMap[task] = nil
        }
    }
}