//
//  SystemStatus.swift
//  appdb
//
//  Created by ned on 05/05/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit

class SystemStatus: LoadingTableView {
    
    var checkedAt: String?
    
    var services: [ServiceStatus] = [] {
        didSet {
            self.tableView.spr_endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    convenience init() {
        self.init(style: .grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "System Status".localized()
        
        tableView.register(SimpleStaticCell.self, forCellReuseIdentifier: "service")
        tableView.estimatedRowHeight = 50
        
        tableView.theme_separatorColor = Color.borderColor
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        view.theme_backgroundColor = Color.tableViewBackgroundColor
        
        animated = false
        showsErrorButton = false
        showsSpinner = false
        
        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        
        if IS_IPAD {
            // Add 'Dismiss' button for iPad
            let dismissButton = UIBarButtonItem(title: "Dismiss".localized(), style: .done, target: self, action: #selector(self.dismissAnimated))
            self.navigationItem.rightBarButtonItems = [dismissButton]
        }
        
        // Refresh action
        tableView.spr_setIndicatorHeader{ [weak self] in
            self?.fetchStatus()
        }
        
        tableView.spr_beginRefreshing()
    }
    
    fileprivate func fetchStatus() {
        
        API.getLastSystemStatusUpdateTime { checkedAt in self.checkedAt = checkedAt }
        
        API.getSystemStatus(success: { services in
            self.services = services.sorted{ $0.name.lowercased() < $1.name.lowercased() }
            if let error = self.errorMessage, let secondary = self.secondaryErrorMessage {
                error.isHidden = true
                secondary.isHidden = true
            }
            
        }, fail: { error in
            self.services = []
            self.showErrorMessage(text: "An error has occurred".localized(), secondaryText: error.localizedDescription, animated: false)
        })
    }
    
    @objc func dismissAnimated() { dismiss(animated: true) }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "service", for: indexPath) as? SimpleStaticCell {
            cell.textLabel?.text = services[indexPath.row].name
            cell.accessoryView = UIImageView(image: services[indexPath.row].isOnline ? #imageLiteral(resourceName: "online") : #imageLiteral(resourceName: "offline"))
            cell.accessoryView?.frame.size.width = 24
            cell.accessoryView?.frame.size.height = 24
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return services.isEmpty ? nil : (self.checkedAt ?? nil)
    }
}