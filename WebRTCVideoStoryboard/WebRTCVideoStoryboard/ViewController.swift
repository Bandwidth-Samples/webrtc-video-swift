//
//  ViewController.swift
//  WebRTCVideoStoryboard
//
//  Created by Michael Hamer on 1/13/21.
//

import UIKit
import WebRTC
import BandwidthWebRTC

class ViewController: UIViewController {
    private let bandwidth = RTCBandwidth()
    
    private var address: String = {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"), let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            fatalError("Failed to load configuration property list.")
        }
        
        guard let configuration = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String: String] else {
            fatalError("Failed to load configuration data.")
        }
        
        guard let address = configuration["Address"] else {
            fatalError("Failed to load address.")
        }
        
        return address
    }()
    
    private var remoteRenderer: RTCVideoRenderer = {
        #if arch(arm64)
        let renderer = RTCMTLVideoView()
        renderer.videoContentMode = .scaleAspectFill
        #else
        let renderer = RTCEAGLVideoView()
        #endif
        
        renderer.backgroundColor = .systemBlue
        return renderer
    }()
    
    private var localRenderer: RTCVideoRenderer = {
        #if arch(arm64)
        let renderer = RTCMTLVideoView(frame: .zero)
        renderer.videoContentMode = .scaleAspectFill
        #else
        let renderer = RTCEAGLVideoView(frame: .zero)
        #endif
        
        renderer.backgroundColor = .systemGreen
        return renderer
    }()
    
    private var stream: RTCMediaStream?
    private var speaker = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bandwidth.delegate = self
        
        if let remoteRenderer = remoteRenderer as? UIView {
            view.addSubview(remoteRenderer)
            
            remoteRenderer.translatesAutoresizingMaskIntoConstraints = false
            remoteRenderer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            remoteRenderer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            remoteRenderer.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            remoteRenderer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        
        if let localRenderer = localRenderer as? UIView {
            view.addSubview(localRenderer)
            
            localRenderer.translatesAutoresizingMaskIntoConstraints = false
            localRenderer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.33).isActive = true
            localRenderer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.33).isActive = true
            localRenderer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            localRenderer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
    }

    @IBAction func connect(_ sender: Any) {
        startCall { token in
            try? self.bandwidth.connect(using: token) {
                self.bandwidth.publish(audio: true, video: true, alias: "adam") {
                    self.bandwidth.captureLocalVideo(renderer: self.localRenderer)
                }
            }
        }
    }
    
    @IBAction func speaker(_ sender: Any) {
        speaker.toggle()
        
        bandwidth.setSpeaker(speaker)
        
        let button = sender as? UIBarButtonItem
        button?.image = UIImage(systemName: speaker ? "speaker.3.fill" : "speaker.3")
    }
    
    func startCall(completion: @escaping (String) -> Void) {
        print("Fetching media token from server application.")

        guard let url = URL(string: "\(address)/startCall") else {
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
                  let token = json["token"] as? String else {
                fatalError("Failed to get media token from server application.")
            }
            
            DispatchQueue.main.async {
                completion(token)
            }
        }.resume()
    }
}

extension ViewController: RTCBandwidthDelegate {
    func bandwidth(_ bandwidth: RTCBandwidth, streamAvailableAt endpointId: String, participantId: String, alias: String?, mediaTypes: [MediaType], mediaStream: RTCMediaStream?) {
        self.stream = mediaStream

        DispatchQueue.main.async {
            mediaStream?.videoTracks.first?.add(self.remoteRenderer)
        }
    }

    func bandwidth(_ bandwidth: RTCBandwidth, streamUnavailableAt endpointId: String) {
        
    }
}
