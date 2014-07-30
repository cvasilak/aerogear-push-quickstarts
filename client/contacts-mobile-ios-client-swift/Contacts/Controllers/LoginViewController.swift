/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import UIKit
import AeroGearPush

class LoginViewController: UITableViewController {
    
    @IBOutlet var usernameTxtField: UITextField!
    @IBOutlet var passwordTxtField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Action Methods
    
    @IBAction func login(sender: AnyObject) {
        let username = usernameTxtField.text
        let password = passwordTxtField.text
        
        // check if the fields are empty
        if username == "" || password == "" {
            var alert = UIAlertView(title: "Oops!", message: "Required fields missing!", delegate: nil, cancelButtonTitle: "Bummer")
            alert.show()

            return
        }
        
        ContactsNetworker.shared.loginWithUsername(username, password: password) {(response, result, error) in
            if !error {

                // time to register user with the "AeroGear UnifiedPush Server"

                // initialize "Registration helper" object using the
                // base URL where the "AeroGear Unified Push Server" is running.
                let registration = AGDeviceRegistration(serverURL: NSURL(string: "https://ups-aerodemo.rhcloud.com/ag-push"))
                
                // perform registration of this device
                registration.registerWithClientInfo({ (clientInfo: AGClientDeviceInformation!) in
                    
                    // retrieve the deviceToken
                    let deviceToken = NSUserDefaults.standardUserDefaults().dataForKey("deviceToken");
                    
                     // set it
                    clientInfo.deviceToken = deviceToken
                    
                    // You need to fill the 'Variant Id' together with the 'Variant Secret'
                    // both received when performing the variant registration with the server.
                    // See section "Register an iOS Variant" in the guide:
                    // http://aerogear.org/docs/guides/aerogear-push-ios/unified-push-server/
                    clientInfo.variantID = "c30dc4fc-71fc-422b-a039-9b260f43d561"
                    clientInfo.variantSecret = "bfa1b733-846e-480b-8292-a009f6fc3550"
                    
                    // --optional config--
                    // set some 'useful' hardware information params
                    let currentDevice = UIDevice()
                    
                    clientInfo.operatingSystem = currentDevice.systemName
                    clientInfo.osVersion = currentDevice.systemVersion
                    clientInfo.deviceType = currentDevice.model
                    },
                    
                    success: {
                        // successfully registered!
                        println("successfully registered with UPS!")
                        
                        // if we reach here, time to move to the main Contacts view
                        self.performSegueWithIdentifier("ContactsViewSegue", sender: self)
                    },
                    
                    failure: {(error: NSError!) in
                        var alert = UIAlertView(title: "Oops!", message: "Failed to register with UPS!", delegate: nil, cancelButtonTitle: "Bummer")
                        alert.show()
                    })
                
            } else {
                var alert = UIAlertView(title: "Oops!", message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "Bummer")
                alert.show()
            }
        }
    }
}

