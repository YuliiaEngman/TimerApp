//
//  ViewController.swift
//  TimerApp
//
//  Created by Yuliia Engman on 2/20/20.
//  Copyright © 2020 Yuliia Engman. All rights reserved.
//

import UIKit
import UserNotifications

protocol SetTimerControllerDelegate: AnyObject {
    func didCreateNotification(_ setTimerController: SetTimerViewController)
}

class SetTimerViewController: UIViewController {
    
    @IBOutlet weak var pickerView: UIDatePicker!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var button: UIButton!
    
    var hour: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
    
    weak var delegate: SetTimerControllerDelegate?
    
     //FIXME: I dont think it is working
    private var timeInterval: TimeInterval = Timer().timeInterval
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func createLocalNotification() {
        // create the content (Model for motification):
        let content = UNMutableNotificationContent()
        content.title = textField.text ?? "No title"
        content.body = "Time of Timer"
        //content.sound = .default
        //or try custom sound:
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "wolf-howling-sound-effect.mp3"))
        
        // create identifier - ask Alex...?
        let identifier = UUID().uuidString
        
        // attachment:
        if let imageURL = Bundle.main.url(forResource: "TimeOut", withExtension: "png") {
            do {
                let attachment = try UNNotificationAttachment(identifier: identifier, url: imageURL, options: nil)
                content.attachments = [attachment]
            } catch {
                print("error with attachment: \(error)")
            }
        } else {
            print("imsge resource could not be found")
            
            //create trigger - timeInterval
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            
            // create a request:
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            //adding request to the UNNotificationCenter
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print("error adding request: \(error)")
                } else {
                    print("request was succesfully added")
                }
            }
        }
    }
    
    @IBAction func timePickerChanged(_ sender: UIDatePicker) {
        //FIXME: I dont think it is working
        timeInterval = sender.countDownDuration
    }
    

    @IBAction func startButtonPressed(_ sender: UIButton) {
        createLocalNotification()
        delegate?.didCreateNotification(self)
        dismiss(animated: true)
    }
    
     //FIXME: unwind segue?
    func unwindSegue(segue: UIStoryboardSegue, sender: Any?) {
        guard let navController = segue.source as? UINavigationController,
            let manageTimersVC = navController.viewControllers.first as? ManageTimersViewController else {
                 fatalError("could not downcast to CreateNotificationViewController")
        }
       // manageTimersVC.delegate = self
        }
        
        // unwinde segue
    //    @IBAction func addNewEvent(segue: UIStoryboardSegue) {
    //        // caveman debugging  print("adding event....")
    //        guard let createEventController = segue.source as? CreateEventController,
    //            let createdEvent = createEventController.event else {
    //            fatalError("failed to access CreateEventController")
    //        }
    //        // insert into our events array
    //        // 1. update the data model e.g. update the evnts array
    //        events.insert(createdEvent, at: 0) // implies top of the events array
    //
    //        // create an indexPathto be inserted into the tableView
    //        let indexPath = IndexPath(row: 0, section: 0) // will represent top of table view
    //
    //        // 2. we need to update the table view
    //        // use indexPath to inser into tble view
    //        tableView.insertRows(at: [indexPath], with: .automatic)
    //    }
        
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //           guard let navController = segue.destination as?
    //               UINavigationController,
    //               let createVC = navController.viewControllers.first as?
    //               CreateNotificationViewController else {
    //                   fatalError("could not downcast to CreateNotificationViewController")
    //           }
    //           createVC.delegate = self
    //       }
}

extension SetTimerViewController {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 25
        case 1, 2:
            return 60
        default:
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.size.width/3
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(row) Hour"
        case 1:
            return "\(row) Minute"
        case 2:
            return "\(row) Second"
        default:
            return ""
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            hour = row
        case 1:
            minutes = row
        case 2:
            seconds = row
        default:
            break;
        }
    }
    
}

