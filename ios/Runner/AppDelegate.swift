import Flutter
import UIKit
import flutter_local_notifications
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let audioChannel = FlutterMethodChannel(name: "app.fikrasoft.engez/audio_converter",
                                              binaryMessenger: controller.binaryMessenger)
    audioChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "convertToWav" {
        guard let args = call.arguments as? [String: Any],
              let sourcePath = args["sourcePath"] as? String,
              let destFileName = args["destFileName"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing sourcePath or destFileName", details: nil))
          return
        }
        
        self.handleAudioConversion(sourcePath: sourcePath, destFileName: destFileName, result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func handleAudioConversion(sourcePath: String, destFileName: String, result: @escaping FlutterResult) {
    var cleanPath = sourcePath
    if cleanPath.hasPrefix("file://") {
        cleanPath = String(cleanPath.dropFirst(7))
    }
    if let decodedPath = cleanPath.removingPercentEncoding {
        cleanPath = decodedPath
    }
    let sourceUrl = URL(fileURLWithPath: cleanPath)
    
    let libraryDirs = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
    guard let libraryDir = libraryDirs.first else {
      result(FlutterError(code: "DIRECTORY_ERROR", message: "Failed to locate Library directory", details: nil))
      return
    }
    
    let soundsDir = libraryDir.appendingPathComponent("Sounds")
    do {
      try FileManager.default.createDirectory(at: soundsDir, withIntermediateDirectories: true, attributes: nil)
    } catch {
      result(FlutterError(code: "DIRECTORY_ERROR", message: "Failed to create Library/Sounds directory", details: nil))
      return
    }
    
    // Sanitize destination filename: replace characters not in a-zA-Z0-9.-_ with "_"
    let safeDestFileName: String
    if let regex = try? NSRegularExpression(pattern: "[^a-zA-Z0-9.\\-_]", options: []) {
        let range = NSRange(location: 0, length: destFileName.utf16.count)
        safeDestFileName = regex.stringByReplacingMatches(in: destFileName, options: [], range: range, withTemplate: "_")
    } else {
        safeDestFileName = destFileName
    }
    
    // Ensure the destination filename ends with .wav
    let baseName = (safeDestFileName as NSString).deletingPathExtension
    let finalDestFileName = "\(baseName).wav"
    let destUrl = soundsDir.appendingPathComponent(finalDestFileName)
    
    // If destination file already exists, delete it first
    try? FileManager.default.removeItem(at: destUrl)
    
    convertToWav(sourceUrl: sourceUrl, destUrl: destUrl) { error in
      DispatchQueue.main.async {
        if let error = error {
          result(FlutterError(code: "CONVERSION_ERROR", message: error.localizedDescription, details: nil))
        } else {
          result(destUrl.path) // Return the absolute path of the converted WAV file
        }
      }
    }
  }

  private func convertToWav(sourceUrl: URL, destUrl: URL, completion: @escaping (Error?) -> Void) {
    // Start accessing security-scoped resource if it's a security-scoped URL
    let accessed = sourceUrl.startAccessingSecurityScopedResource()
    
    // We want to make sure completion is called exactly once
    var isCompleted = false
    let completionOnce: (Error?) -> Void = { error in
      guard !isCompleted else { return }
      isCompleted = true
      if accessed {
        sourceUrl.stopAccessingSecurityScopedResource()
      }
      completion(error)
    }

    let asset = AVURLAsset(url: sourceUrl, options: nil)
    
    // Load tracks asynchronously to support modern iOS and avoid blocking
    asset.loadValuesAsynchronously(forKeys: ["tracks"]) {
      var error: NSError?
      let status = asset.statusOfValue(forKey: "tracks", error: &error)
      
      guard status == .loaded else {
        completionOnce(error ?? NSError(domain: "AudioConverter", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to load tracks asynchronously"]))
        return
      }
      
      guard let reader = try? AVAssetReader(asset: asset) else {
        completionOnce(NSError(domain: "AudioConverter", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create AVAssetReader"]))
        return
      }
      
      guard let track = asset.tracks(withMediaType: .audio).first else {
        completionOnce(NSError(domain: "AudioConverter", code: 2, userInfo: [NSLocalizedDescriptionKey: "No audio track found in source file"]))
        return
      }
      
      let readerOutput = AVAssetReaderTrackOutput(track: track, outputSettings: [
        AVFormatIDKey: kAudioFormatLinearPCM,
        AVSampleRateKey: 44100.0,
        AVNumberOfChannelsKey: 1,
        AVLinearPCMBitDepthKey: 16,
        AVLinearPCMIsBigEndianKey: false,
        AVLinearPCMIsFloatKey: false,
        AVLinearPCMIsNonInterleaved: false
      ])
      reader.add(readerOutput)
      
      guard let writer = try? AVAssetWriter(outputURL: destUrl, fileType: .wav) else {
        completionOnce(NSError(domain: "AudioConverter", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to create AVAssetWriter"]))
        return
      }
      
      let writerInput = AVAssetWriterInput(mediaType: .audio, outputSettings: [
        AVFormatIDKey: kAudioFormatLinearPCM,
        AVSampleRateKey: 44100.0,
        AVNumberOfChannelsKey: 1,
        AVLinearPCMBitDepthKey: 16,
        AVLinearPCMIsBigEndianKey: false,
        AVLinearPCMIsFloatKey: false,
        AVLinearPCMIsNonInterleaved: false
      ])
      writer.add(writerInput)
      
      guard reader.startReading() else {
        completionOnce(reader.error)
        return
      }
      
      guard writer.startWriting() else {
        completionOnce(writer.error)
        return
      }
      
      writer.startSession(atSourceTime: .zero)
      
      let queue = DispatchQueue(label: "audio-conversion-queue")
      writerInput.requestMediaDataWhenReady(on: queue) {
        while writerInput.isReadyForMoreMediaData {
          if reader.status == .failed {
            writerInput.markAsFinished()
            completionOnce(reader.error)
            return
          }
          
          if reader.status == .completed {
            writerInput.markAsFinished()
            writer.finishWriting {
              completionOnce(writer.error)
            }
            return
          }
          
          guard let sampleBuffer = readerOutput.copyNextSampleBuffer() else {
            // copyNextSampleBuffer returned nil, check status
            writerInput.markAsFinished()
            if reader.status == .failed {
              completionOnce(reader.error)
            } else {
              writer.finishWriting {
                completionOnce(writer.error)
              }
            }
            return
          }
          
          if !writerInput.append(sampleBuffer) {
            writerInput.markAsFinished()
            completionOnce(writer.error)
            return
          }
        }
      }
    }
  }
}
