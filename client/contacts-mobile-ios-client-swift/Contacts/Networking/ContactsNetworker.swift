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

import Foundation

class ContactsNetworker: RestNetworker {
    
    var username: String?
    
    // holds the singleton ContactsNetworker
    class var shared: ContactsNetworker {
        struct Static {
            static let kAPIBaseURLString = "http://192.168.1.7:8080/jboss-contacts-mobile-picketlink-secured";
            static let _instance = ContactsNetworker(serverURL: NSURL(string: kAPIBaseURLString).URLByAppendingPathComponent("/rest"))
            }
            
            return Static._instance
    }
    
    func loginWithUsername(username: String, password: String, completionHandler: ((NSURLResponse!, AnyObject!, NSError!) -> Void)!) {
        self.username = username
        
        let request = NSMutableURLRequest(URL: serverURL.URLByAppendingPathComponent("/security/user/info"))
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "GET"
    
        // apply HTTP Basic
        let basicAuthCredentials: NSData! = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding)
        let base64Encoded = basicAuthCredentials.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.fromRaw(0)!)
        
        request.setValue("Basic \(base64Encoded)", forHTTPHeaderField: "Authorization")
        
        let task = super.dataTaskWithRequest(request, completionHandler: completionHandler)
        task.resume()
    }

    func logout(completionHandler: ((NSURLResponse!, AnyObject!, NSError!) -> Void)!) {
        super.POST("/security/logout", parameters: nil, completionHandler: completionHandler)
    }
    
}