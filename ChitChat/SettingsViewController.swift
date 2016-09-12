//
//  SettingsViewController.swift
//  ChitChat
//
//  Created by Ricky Gill on 07/09/2016.
//
//

import UIKit
import XMPPFramework
import xmpp_messenger_ios


class SettingsViewController: UIViewController {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tap = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.DismissKeyboard))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if OneChat.sharedInstance.isConnected() {
            usernameTextField.hidden = true
            passwordTextField.hidden = true
            validateButton.setTitle("Disconnect", forState: UIControlState.Normal)
        } else if NSUserDefaults.standardUserDefaults().stringForKey(kXMPP.myJID) != "kXMPPmyJID" {
            doneButton.enabled = false
            passwordTextField.text = NSUserDefaults.standardUserDefaults().stringForKey(kXMPP.myPassword)
            let username = NSUserDefaults.standardUserDefaults().stringForKey(kXMPP.myJID)
            guard let unwrappedUsername = username else {
                print("error getting username")
                usernameTextField.text = ""
                return
            }
            usernameTextField.text = unwrappedUsername.componentsSeparatedByString("@")[0]
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func DismissKeyboard() {
        if usernameTextField.isFirstResponder() {
            usernameTextField.resignFirstResponder()
        } else if passwordTextField.isFirstResponder() {
            passwordTextField.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if passwordTextField.isFirstResponder() {
            textField.resignFirstResponder()
            validate(self)
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var validateButton: UIButton!
    
    @IBAction func validate(sender: AnyObject) {
//        let this = self
        if OneChat.sharedInstance.isConnected() {
            OneChat.sharedInstance.disconnect()
            doneButton.enabled = false
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: kXMPP.stopConnection)
            usernameTextField.hidden = false
            passwordTextField.hidden = false
            validateButton.setTitle("Validate", forState: UIControlState.Normal)
        } else if checkInputs() {
            OneChats.self.clearChatsList()
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: kXMPP.stopConnection)
            OneChat.sharedInstance.connect(username: self.usernameTextField.text! + "@localhost", password: self.passwordTextField.text!) { (stream, error) -> Void in
                if let _ = error {
                    let alertController = UIAlertController(title: "Sorry", message: "Username/Password did not match our records", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                        // do something
                    }))
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    self.doneButton.enabled = true
                    self.tabBarController?.selectedIndex = 1
                }
            }
        }
    }
    
    @IBAction func done(sender: AnyObject) {
        self.tabBarController?.selectedIndex = 1
    }
    
    func checkInputs() -> Bool {
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            let alertController = UIAlertController(title: "Sorry", message: "Username/Password cannot be empty", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                // do something
            }))
            self.presentViewController(alertController, animated: true, completion: nil)
            return false
        }
        return true
    }
    
}