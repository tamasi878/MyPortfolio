//
//  SocketManager.swift
//  MyPortfolio
//
//  Created by Tamási Móni on 2021. 03. 03..
//

import Foundation
import Starscream

protocol SocketManagerDelegate {
    func connectionError(reason: String, code: UInt16)
    func connectionWasSuccessful()
    func receivedString(message: String)
    func receivedData(data: Data)
    
    func connectionWasClosed()
}

class SocketManager: NSObject {
    static let shared = SocketManager()
    
    var delegate: SocketManagerDelegate? = nil
    
    private var socket: WebSocket?
    private var connected: Bool = false
    private var tries: Int = 0
    private var lastUsedUrl: String = ""
        
    func connectToSocket(url: String) {
        self.lastUsedUrl = url
        
        var request = URLRequest(url: URL(string: url)!)
        request.timeoutInterval = 5
        self.socket = WebSocket(request: request)
        self.socket?.onEvent = { event in
            self.handleEvent(event)
        }
        self.socket?.connect()
    }
    
    func disconnect() {
        self.socket?.disconnect()
    }
    
    func isConnected() -> Bool {
        return self.socket != nil && self.connected
    }
    
    func write(message: String) {
        self.socket?.write(string: message)
    }
    
    func write(data: Data) {
        self.socket?.write(data: data)
    }
    
    private func handleEvent(_ event: WebSocketEvent) {
        switch event {
        case .connected(_):
            self.connected = true
            tries = 0
            self.delegate?.connectionWasSuccessful()
        case .disconnected(let reason, let code):
            self.connected = false
            tries += 1
            if code != CloseCode.normal.rawValue && tries < 5 {
                self.connectToSocket(url: self.lastUsedUrl)
            } else {
                if code == CloseCode.normal.rawValue {
                    self.delegate?.connectionWasClosed()
                }
                self.delegate?.connectionError(reason: reason, code: code)
            }
        case .text(let message):
            self.delegate?.receivedString(message: message)
        case .binary(let data):
            self.delegate?.receivedData(data: data)
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            self.connectToSocket(url: self.lastUsedUrl)
        case .cancelled:
            self.connected = false
        case .error(let error):
            self.connected = false
            tries += 1
            if tries < 5 {
                self.connectToSocket(url: self.lastUsedUrl)
            } else {
                self.delegate?.connectionError(reason: error?.localizedDescription ?? "Unknown error occured", code: UInt16(100))
            }
        }
    }
}
