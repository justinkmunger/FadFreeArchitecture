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

import UIKit

class StationCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initializeCell()
    }
    
    override func prepareForReuse() {
        initializeCell()
    }
    
    func initializeCell() {
        nameLabel.text = ""
        distanceLabel.text = ""
        dateTimeLabel.text = ""
        temperatureLabel.text = ""
    }
    
    func configureCell(_ stationResult: StationResult) {
        
        if stationResult.name.isEmpty {
            nameLabel.text = "<No station name>"
        } else {
            nameLabel.text = stationResult.name
        }
        
        distanceLabel.text = String(format: "%.2f miles", stationResult.distance)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy hh:mm a"
        
        dateTimeLabel.text = dateFormatter.string(from: stationResult.date as Date)
        
        if stationResult.temperature.isNaN {
            temperatureLabel.text = "<No temp>"
        } else {
            temperatureLabel.text = String(format: "%.2f", stationResult.temperature)
        }
    }
}
