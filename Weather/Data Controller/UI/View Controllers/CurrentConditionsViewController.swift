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
    var stationResultsFetchedResultsController: NSFetchedResultsController<StationResult>?

    var dateSortDescriptorAscending = true
    var nameSortDescriptorAscending = true
    var distanceSortDescriptorAscending = true
    
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
        refreshControl?.addTarget(self, action: #selector(refreshStations), for: UIControlEvents.valueChanged)
    }
    
    func refreshStations() {
        refreshControl?.beginRefreshing()
        dataController.getStations { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.refreshControl?.endRefreshing()
            
            switch result {
                case .success:
                    break
                case .error:
                    let alertController = UIAlertController(title: "Error", message: "Error", preferredStyle: .alert)
                    
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(alertAction)
                    
                    strongSelf.present(alertController, animated: true, completion: nil)
            }
        }
    }

    @IBAction func filterButtonPressed(_ sender: UIBarButtonItem) {
        guard let stationResultsFetchedResultsController = self.stationResultsFetchedResultsController else {
            return
        }

        let actionSheetController = UIAlertController(title: "Filter", message: "Choose the time range to filter on", preferredStyle: .actionSheet)
        
        let lastThirtyMinutesPredicateAction = UIAlertAction(title: "Last thirty minutes", style: .default) { action in
            stationResultsFetchedResultsController.fetchRequest.predicate = self.dataController.lastThirtyMinutesTimePredicate
            
            do {
                try stationResultsFetchedResultsController.performFetch()
                self.tableView.reloadData()
            } catch {
                
            }
        }
        
        let lastHourPredicateAction = UIAlertAction(title: "Last hour", style: .default) { action in
            stationResultsFetchedResultsController.fetchRequest.predicate = self.dataController.lastHourTimePredicate
            
            do {
                try stationResultsFetchedResultsController.performFetch()
                self.tableView.reloadData()
            } catch {
                
            }
            
        }
        
        let lastTwoHoursPredicateAction = UIAlertAction(title: "Last two hours", style: .default) { action in
            stationResultsFetchedResultsController.fetchRequest.predicate = self.dataController.lastTwoHoursTimePredicate
            
            do {
                try stationResultsFetchedResultsController.performFetch()
                self.tableView.reloadData()
            } catch {
                
            }
            
        }

        let lastFourHoursPredicateAction = UIAlertAction(title: "Last four hours", style: .default) { action in
            stationResultsFetchedResultsController.fetchRequest.predicate = self.dataController.lastFourHoursTimePredicate
            
            do {
                try stationResultsFetchedResultsController.performFetch()
                self.tableView.reloadData()
            } catch {
                
            }
            
        }

        let allTimesPredicateAction = UIAlertAction(title: "All Times", style: .default) { action in
            stationResultsFetchedResultsController.fetchRequest.predicate = self.dataController.allTimesPredicate
            
            do {
                try stationResultsFetchedResultsController.performFetch()
                self.tableView.reloadData()
            } catch {
                
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheetController.addAction(lastThirtyMinutesPredicateAction)
        actionSheetController.addAction(lastHourPredicateAction)
        actionSheetController.addAction(lastTwoHoursPredicateAction)
        actionSheetController.addAction(lastFourHoursPredicateAction)
        actionSheetController.addAction(allTimesPredicateAction)
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func sortButtonPressed(_ sender: UIBarButtonItem) {
        let actionSheetController = UIAlertController(title: "Sort", message: "Choose with property to sort by", preferredStyle: .actionSheet)
        
        let dateSortDirectionString = dateSortDescriptorAscending ? "Descending" : "Ascending"
        let dateAction = UIAlertAction(title: "Date \(dateSortDirectionString)", style: .default) { action in
            
            var dateSortDescriptor: SortDescriptor
            
            if self.dateSortDescriptorAscending {
                dateSortDescriptor = self.dataController.dateSortDescriptorDescending
            } else {
                dateSortDescriptor = self.dataController.dateSortDescriptorAscending
            }
            self.stationResultsFetchedResultsController?.fetchRequest.sortDescriptors = [dateSortDescriptor]
            
            do {
                try self.stationResultsFetchedResultsController?.performFetch()
                self.dateSortDescriptorAscending = !self.dateSortDescriptorAscending
                self.tableView.reloadData()
            } catch {
                
            }
        }
        
        let nameSortDirectionString = nameSortDescriptorAscending ? "Descending" : "Ascending"
        let nameAction = UIAlertAction(title: "Name \(nameSortDirectionString)", style: .default) { action in
            
            var nameSortDescriptor: SortDescriptor
            
            if self.nameSortDescriptorAscending {
                nameSortDescriptor = self.dataController.nameSortDescriptorDescending
            } else {
                nameSortDescriptor = self.dataController.nameSortDescriptorAscending
            }
            
            self.stationResultsFetchedResultsController?.fetchRequest.sortDescriptors = [nameSortDescriptor]
            
            do {
                try self.stationResultsFetchedResultsController?.performFetch()
                self.nameSortDescriptorAscending = !self.nameSortDescriptorAscending
                self.tableView.reloadData()
            } catch {
                
            }
        }
        
        let distanceSortDirectionString = distanceSortDescriptorAscending ? "Descending" : "Ascending"
        let distanceAction = UIAlertAction(title: "Distance \(distanceSortDirectionString)", style: .default) { action in
            var distanceSortDescriptor: SortDescriptor
            
            if self.distanceSortDescriptorAscending {
                distanceSortDescriptor = self.dataController.distanceSortDescriptorDescending
            } else {
                distanceSortDescriptor = self.dataController.distanceSortDescriptorAscending
            }
            
            self.stationResultsFetchedResultsController?.fetchRequest.sortDescriptors = [distanceSortDescriptor]
            
            do {
                try self.stationResultsFetchedResultsController?.performFetch()
                self.distanceSortDescriptorAscending = !self.distanceSortDescriptorAscending
                self.tableView.reloadData()
            } catch {
                
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheetController.addAction(dateAction)
        actionSheetController.addAction(nameAction)
        actionSheetController.addAction(distanceAction)
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true, completion: nil)
    }
    
}

extension CurrentConditionsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return stationResultsFetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let fetchedResultController = self.stationResultsFetchedResultsController, sections = fetchedResultController.sections else {
            return nil
        }
        
        return sections[section].name
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let fetchedResultController = self.stationResultsFetchedResultsController,
            sections = fetchedResultController.sections else {
                return 0
        }
        
        return sections[section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StationCell", for: indexPath) as? StationCell else {
            fatalError("StationCell not found")
        }
        
        guard let fetchedResultController = self.stationResultsFetchedResultsController else {
            print("fetchedResultController not set")
            return UITableViewCell()
        }
        
        let stationResult = fetchedResultController.object(at: indexPath)

        cell.configureCell(stationResult)
        
        return cell
    }
}

extension CurrentConditionsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: AnyObject, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            guard let indexPath = indexPath else {
                print("indexPath not valid")
                return
            }
            
            guard let cell = tableView.cellForRow(at: indexPath) as? StationCell else {
                return
            }
            
            guard let fetchedResultController = self.stationResultsFetchedResultsController else {
                print("fetchedResultController not set")
                return
            }

            let stationResult = fetchedResultController.object(at: indexPath)            
            cell.configureCell(stationResult)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        default:
            break
        }
    }
}
