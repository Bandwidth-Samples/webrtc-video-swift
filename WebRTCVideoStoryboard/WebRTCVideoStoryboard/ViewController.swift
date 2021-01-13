//
//  ViewController.swift
//  WebRTCVideoStoryboard
//
//  Created by Michael Hamer on 1/13/21.
//

import UIKit
import BandwidthWebRTC
import WebRTC

class ViewController: UIViewController {
    private let address = "http://localhost:3000"
    private let webRTC = WebRTC()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func connect(_ sender: Any) {
        getToken { token in
            try? self.webRTC.connect(using: token) {
                self.webRTC.publish(audio: true, video: true) {
                    #if arch(arm64)
                    let localRenderer = RTCMTLVideoView(frame: .zero)
                    let remoteRenderer = RTCMTLVideoView(frame: self.view.frame)
                    localRenderer.videoContentMode = .scaleAspectFill
                    remoteRenderer.videoContentMode = .scaleAspectFill
                    #else
                    let localRenderer = RTCEAGLVideoView(frame: .zero)
                    let remoteRenderer = RTCEAGLVideoView(frame: self.view.frame)
                    #endif
                    
                    self.webRTC.captureLocalVideo(renderer: localRenderer)
                    self.webRTC.renderRemoteVideo(renderer: remoteRenderer)
                }
            }
        }
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

