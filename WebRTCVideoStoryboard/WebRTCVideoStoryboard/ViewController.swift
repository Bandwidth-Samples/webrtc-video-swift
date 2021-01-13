//
//  ViewController.swift
//  WebRTCVideoStoryboard
//
//  Created by Michael Hamer on 1/13/21.
//

import UIKit

class ViewController: UIViewController {
    private let address = "http://localhost:3000"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func getToken(completion: @escaping (String) -> Void) {
        print("Fetching media token from server application.")

        guard let url = URL(string: "\(address)/startBrowserCall") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let token = json["token"] as? String else {
                fatalError("Failed to get media token from server application.")
            }
            
            DispatchQueue.main.async {
                completion(token)
            }
        }.resume()
    }
}

