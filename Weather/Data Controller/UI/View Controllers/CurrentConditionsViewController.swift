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
import UIKit

class CurrentConditionsViewController: UITableViewController {

    var dataController: DataController!
    var stationResultsFetchedResultsController: NSFetchedResultsController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70.0
        
        guard let dataController = self.dataController else {
            fatalError("DataController not set")
        }
        
        dataController.initCoreDataStack() { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.stationResultsFetchedResultsController = dataController.stationResultsFetchResultsController()
            strongSelf.stationResultsFetchedResultsController!.delegate = strongSelf
            
            do {
                try strongSelf.stationResultsFetchedResultsController!.performFetch()
                strongSelf.tableView.reloadData()
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
            }
            
            strongSelf.refreshStations()
        }
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshStations), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func refreshStations() {
        refreshControl?.beginRefreshing()
        dataController.getStations { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.refreshControl?.endRefreshing()
            
            switch result {
                case .Success:
                    break
                case .Error:
                    let alertController = UIAlertController(title: "Error", message: "Error", preferredStyle: .Alert)
                    
                    let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(alertAction)
                    
                    strongSelf.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
}

extension CurrentConditionsViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return stationResultsFetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let fetchedResultController = self.stationResultsFetchedResultsController, sections = fetchedResultController.sections else {
            return nil
        }
        
        return sections[section].name
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let fetchedResultController = self.stationResultsFetchedResultsController,
            sections = fetchedResultController.sections else {
                return 0
        }
        
        return sections[section].numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
        guard let cell = tableView.dequeueReusableCellWithIdentifier("StationCell", forIndexPath: indexPath) as? StationCell else {
            fatalError("StationCell not found")
        }
        
        guard let fetchedResultController = self.stationResultsFetchedResultsController else {
            print("fetchedResultController not set")
            return UITableViewCell()
        }
        
        guard let stationResult = fetchedResultController.objectAtIndexPath(indexPath) as? StationResult else {
            print("did not return station result object")
            return UITableViewCell()
        }

        cell.configureCell(stationResult)
        
        return cell
    }
}

extension CurrentConditionsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            guard let indexPath = indexPath else {
                print("indexPath not valid")
                return
            }
            
            guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? StationCell else {
                return
            }
            
            guard let fetchedResultController = self.stationResultsFetchedResultsController else {
                print("fetchedResultController not set")
                return
            }

            guard let stationResult = fetchedResultController.objectAtIndexPath(indexPath) as? StationResult else {
                print("did not return station result object")
                return
            }
            
            cell.configureCell(stationResult)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        let indexSet = NSIndexSet(index: sectionIndex)
        
        switch type {
        case .Insert:
            tableView.insertSections(indexSet, withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(indexSet, withRowAnimation: .Automatic)
        default:
            break
        }
    }
}