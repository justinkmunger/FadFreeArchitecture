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
    let rootURL: URL
    var session: Foundation.URLSession!
    
    private var taskToOperationMap: [URLSessionTask: NetworkOperation]

    lazy var apiKey: String = {
        guard let apiKeyPath = Bundle.main().pathForResource("APIKey", ofType: "plist") else {
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
        guard let rootURL = URL(string: "http://api.openweathermap.org") else {
            fatalError("failed to initialize endpointURL")
        }
        
        self.rootURL = rootURL

        taskToOperationMap = [URLSessionTask: NetworkOperation]()

        super.init()
        
        let configuration = URLSessionConfiguration.default()
        configuration.timeoutIntervalForRequest = 30.0
        
        session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    func getNearbyStationNetworkOperation(_ latitude: String, longitude: String) -> NetworkOperation {
        var components = URLComponents()
        
        components.scheme = rootURL.scheme
        components.host = rootURL.host
        components.path = "/data/2.5/station/find"
        components.query = "lat=\(latitude)&lon=\(longitude)&cnt=30&units=imperial&appid=\(apiKey)"
        
        guard let endpointURL = components.url else {
            fatalError("couldn't create endpointURL")
        }
        
        let urlRequest = URLRequest(url: endpointURL)
        let task = session.dataTask(with: urlRequest)
        
        let operation = NetworkOperation(task: task)
        taskToOperationMap[task] = operation
        
        return operation
    }
}

extension NetworkController: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: (URLSession.ResponseDisposition) -> Void) {
        if let operation = taskToOperationMap[dataTask] {
            if operation.isCancelled {
                taskToOperationMap[dataTask] = nil
            } else {
                operation.didReceiveResponse(response, completionHandler: completionHandler)
            }
        }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let operation = taskToOperationMap[dataTask] {
            if operation.isCancelled {
                taskToOperationMap[dataTask] = nil
            } else {
                operation.didReceiveData(data)
            }

        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        if let operation = taskToOperationMap[task] {
            operation.didCompleteWithError(error)
            taskToOperationMap[task] = nil
        }
    }
}
