//
//  AudioManager.swift
//  Bro
//

import AVFoundation
import Cocoa

class AudioManager: NSObject {
    static let shared = AudioManager()
    
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var audioFile: AVAudioFile?
    
    private override init() {
        super.init()
        setupAudioEngine()
    }
    
    // MARK: - Setup
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        
        guard let engine = audioEngine, let player = playerNode else {
            return
        }
        
        engine.attach(player)
        
        let mainMixer = engine.mainMixerNode
        let format = mainMixer.outputFormat(forBus: 0)
        
        engine.connect(player, to: mainMixer, format: format)
    }
    
    // MARK: - Playback
    
    func playAudio(data: Data, completion: @escaping (Bool) -> Void) {
        // Save to temporary file
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp3")
        
        do {
            try data.write(to: tempURL)
            playAudio(url: tempURL, completion: completion)
        } catch {
            print("Error writing audio file: \(error)")
            completion(false)
        }
    }
    
    func playAudio(url: URL, completion: @escaping (Bool) -> Void) {
        guard let engine = audioEngine, let player = playerNode else {
            completion(false)
            return
        }
        
        do {
            audioFile = try AVAudioFile(forReading: url)
            
            guard let file = audioFile else {
                completion(false)
                return
            }
            
            // Stop if already playing
            if player.isPlaying {
                player.stop()
            }
            
            // Start engine if not running
            if !engine.isRunning {
                try engine.start()
            }
            
            // Schedule file for playback
            player.scheduleFile(file, at: nil) {
                DispatchQueue.main.async {
                    completion(true)
                    
                    // Clean up temp file
                    try? FileManager.default.removeItem(at: url)
                }
            }
            
            player.play()
            
        } catch {
            print("Error playing audio: \(error)")
            completion(false)
        }
    }
    
    func stopPlayback() {
        playerNode?.stop()
        audioEngine?.stop()
    }
    
    // MARK: - Output Device
    
    func getOutputDevices() -> [(name: String, id: AudioDeviceID)] {
        var devices: [(String, AudioDeviceID)] = []
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var dataSize: UInt32 = 0
        var status = AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize
        )
        
        guard status == noErr else { return devices }
        
        let deviceCount = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
        var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)
        
        status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &deviceIDs
        )
        
        guard status == noErr else { return devices }
        
        for deviceID in deviceIDs {
            // Check if it's an output device
            var streamAddress = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyStreams,
                mScope: kAudioDevicePropertyScopeOutput,
                mElement: kAudioObjectPropertyElementMain
            )
            
            var streamDataSize: UInt32 = 0
            status = AudioObjectGetPropertyDataSize(
                deviceID,
                &streamAddress,
                0,
                nil,
                &streamDataSize
            )
            
            if status != noErr || streamDataSize == 0 {
                continue // Not an output device
            }
            
            // Get device name
            var nameAddress = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyDeviceNameCFString,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain
            )
            
            var name: CFString = "" as CFString
            var nameSize = UInt32(MemoryLayout<CFString>.size)
            
            status = AudioObjectGetPropertyData(
                deviceID,
                &nameAddress,
                0,
                nil,
                &nameSize,
                &name
            )
            
            if status == noErr {
                devices.append((name as String, deviceID))
            }
        }
        
        return devices
    }
    
    func setOutputDevice(deviceID: AudioDeviceID) -> Bool {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var deviceID = deviceID
        let dataSize = UInt32(MemoryLayout<AudioDeviceID>.size)
        
        let status = AudioObjectSetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            dataSize,
            &deviceID
        )
        
        return status == noErr
    }
    
    func getCurrentOutputDevice() -> (name: String, id: AudioDeviceID)? {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var deviceID: AudioDeviceID = 0
        var dataSize = UInt32(MemoryLayout<AudioDeviceID>.size)
        
        var status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &deviceID
        )
        
        guard status == noErr else { return nil }
        
        // Get device name
        var nameAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceNameCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var name: CFString = "" as CFString
        var nameSize = UInt32(MemoryLayout<CFString>.size)
        
        status = AudioObjectGetPropertyData(
            deviceID,
            &nameAddress,
            0,
            nil,
            &nameSize,
            &name
        )
        
        if status == noErr {
            return (name as String, deviceID)
        }
        
        return nil
    }
}

