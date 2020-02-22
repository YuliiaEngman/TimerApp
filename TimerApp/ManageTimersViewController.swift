//
//  ManageTimersViewController.swift
//  TimerApp
//
//  Created by Yuliia Engman on 2/20/20.
//  Copyright © 2020 Yuliia Engman. All rights reserved.
//

import UIKit
import UserNotifications

class ManageTimersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var notifications = [UNNotificationRequest]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private let center = UNUserNotificationCenter.current()
    
    private let pendingNotification = PendingNotification()
    
    private var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        configureRefreshControl()
        loadNotifications()
        checkForNotificationAuthorization()
        
        // setting this view controller as the delegate object for the UNNotificationCenterDelegate
        center.delegate = self
    }
    
    private func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(loadNotifications), for: .valueChanged)
    }
    
    //FIXME: unwind segue?
//      func unwindSegue(segue: UIStoryboardSegue, sender: Any?) {
//          guard let navController = segue.source as? UINavigationController,
//              let setTimerVC = navController.viewControllers.first as? SetTimerViewController else {
//                   fatalError("could not downcast to SetTimerViewController")
//          }
//         setTimerVC.delegate = self
//          }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navController = segue.destination as? UINavigationController,
            let setTimerVC = navController.viewControllers.first as? SetTimerViewController else {
                fatalError("could not downcast to SetTimerViewController")
        }
        setTimerVC.delegate = self
    }
    
    @objc private func loadNotifications() {
        pendingNotification.getPendingNotifications {(requests) in
            self.notifications = requests
            // stop the refreshcontrol from animation and remove from the UI
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func checkForNotificationAuthorization() {
        center.getNotificationSettings {(settings) in
            if settings.authorizationStatus == .authorized {
                print("app is authorized for notifications")
            } else {
                self.requestNotificationPermissions()
            }
        }
    }
    
    private func requestNotificationPermissions() {
        center.requestAuthorization(options: [.alert, .sound]) {(granted, error) in
            if let error = error {
                print("error requesting authorization: \(error)")
                return
            }
            if granted {
                print("access was granted")
            } else {
                print("acces denied")
            }
        }
    }
}

extension ManageTimersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //FIXME:
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timerTitleCell", for: indexPath)
        let notification = notifications[indexPath.row]
        cell.textLabel?.text = notification.content.title
        cell.detailTextLabel?.text = notification.content.subtitle
        //body?
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // delete pending notification
            removeNotification(atIndexPath: indexPath)
        }
    }
    
    private func removeNotification(atIndexPath indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        let identifier = notification.identifier
        // remove notification from INNotificationCenter
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        //remove from array of notifications
        notifications.remove(at: indexPath.row)
        
        //remove from table view
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

//code for making that notifivcation will appear inside our app
extension ManageTimersViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}

extension ManageTimersViewController: SetTimerViewControllerDelegate {
    func didCreateNotification(_ setTimerNotificationCenter: SetTimerViewController) {
        loadNotifications()
    }
}
