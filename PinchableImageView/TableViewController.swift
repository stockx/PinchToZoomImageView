//
//  TableViewController.swift
//  PinchableImageView
//
//  Created by Josh Sklar on 5/10/17.
//  Copyright © 2017 StockX. All rights reserved.
//

import UIKit

private let reuseIdentifier = "tableViewCellIdentifier"

class TableViewController: UITableViewController {

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
    }
}
