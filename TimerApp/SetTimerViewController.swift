//
//  ViewController.swift
//  TimerApp
//
//  Created by Yuliia Engman on 2/20/20.
//  Copyright © 2020 Yuliia Engman. All rights reserved.
//

import UIKit
import UserNotifications

protocol SetTimerViewControllerDelegate: AnyObject {
    func didCreateNotification(_ setTimerNotificationCenter: SetTimerViewController)
}

class SetTimerViewController: UIViewController {
    
    @IBOutlet weak var timerPickerView: UIPickerView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    
    weak var delegate: SetTimerViewControllerDelegate?
    
    //FIXME: I dont think it is working
    private var timeInterval: TimeInterval! = Date().timeIntervalSinceNow + 5
    //var timeInterval: TimeInterval = Double(5.0)
    
    
        var hour: Int = 0
        var minutes: Int = 0
        var seconds: Int = 0
    
    var totalTime = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timerPickerView.dataSource = self
        timerPickerView.delegate = self
    }
    
    private func createLocalNotification() {
        // create the content (Model for motification):
        let content = UNMutableNotificationContent()
        content.title = textField.text ?? "No title"
        content.body = "Time of Timer"
        content.subtitle = "fires in \(totalTime)"
        //content.sound = .default
        //or try custom sound:
        // does not perform sound...
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
        }
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
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
           createLocalNotification()
           delegate?.didCreateNotification(self)
           dismiss(animated: true)
       }
}

extension SetTimerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 23
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
            return "\(row) Hr"
        case 1:
            return "\(row) Min"
        case 2:
            return "\(row) Sec"
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
        default:
            seconds = row
            
            totalTime = Double(hour + minutes + seconds)
            timeInterval = totalTime
        }
    }
}

extension SetTimerViewController: UIPickerViewDelegate {
  
}
