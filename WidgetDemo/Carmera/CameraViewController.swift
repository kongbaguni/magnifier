//
//  CameraViewController.swift
//  ucmIos
//
//  Created by Changyeol Seo on 10/29/24.
//
import UIKit
@preconcurrency import AVFoundation


class CameraViewController: UIViewController {
    private var onCapture: (UIImage) -> Void = { _ in }
    private var captureSession: AVCaptureSession? = nil
    private var photoOutput = AVCapturePhotoOutput()
    private var captureInput: AVCaptureDeviceInput? = nil
    private var captureDevice: AVCaptureDevice? = nil
    
    private var deviceType:AVCaptureDevice.DeviceType? = nil
    
    
    func initCaptureDevice(deviceType:AVCaptureDevice.DeviceType?) {
        if let captureInput = captureInput {
            captureSession?.removeInput(captureInput)
        }
        self.deviceType = deviceType
        if let type = deviceType {
            captureDevice = .default(type, for: .video, position: .back)
        } else {
            captureDevice = .default(for: .video)
        }
        do {
            try captureDevice?.lockForConfiguration()
            captureDevice?.focusMode = .locked
            captureDevice?.setFocusModeLocked(lensPosition: 1.0) // 1.0 = 최단거리 (접사)
            captureDevice?.unlockForConfiguration()
        } catch {
            print("Error: \(error)")
        }
        
        guard
            let backCamera = captureDevice,
            let input = try? AVCaptureDeviceInput(device: backCamera),
            captureSession?.canAddInput(input) == true else {
            Log.error(#function, "Unable to access back camera!")
            return
        }
        captureInput = input
        captureSession?.addInput(input)
        
        if captureSession?.canAddOutput(photoOutput) == true {
            captureSession?.addOutput(photoOutput)
        }
        
    }
    
    func setupCamera(onCapture: @escaping (UIImage) -> Void) {
        self.onCapture = onCapture
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo
        
        initCaptureDevice(deviceType: .builtInUltraWideCamera)
        
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.frame
        //        previewLayer.frame.size.height = previewLayer.frame.width / 3 * 4
        previewLayer.frame.origin = .zero
        
        view.layer.addSublayer(previewLayer)
        
        
        
        view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(self.pinchGesture(sender:))))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture(sender:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        
        if let captureSession {
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning()
            }
        }
        
        NotificationCenter.default.addObserver(forName: .cameraCapture, object: nil, queue: nil) { [weak self] noti in
            Task { @MainActor [weak self] in
                self?.capturePhoto()
            }
        }
        
        NotificationCenter.default.addObserver(forName: .cameraSettingChange, object: nil, queue: nil) {[weak self] noti in
            let lens = noti.userInfo?["lens"] as? Int
            let exposure = noti.userInfo?["exporse"] as? Float
            let focus = noti.userInfo?["focus"] as? Float
            let zoom = noti.userInfo?["zoom"] as? Float
            let whiteBalance = noti.userInfo?["whiteBalence"] as? [String: Float]
            Task { @MainActor [weak self] in
                guard let self else { return }
                do {
                    if let lens {
                        switch lens {
                        case 0:
                            self.initCaptureDevice(deviceType: .builtInUltraWideCamera)
                        default:
                            self.initCaptureDevice(deviceType: nil)
                        }
                    }

                    guard let captureDevice = self.captureDevice else { return }
                    try captureDevice.lockForConfiguration()
                    defer { captureDevice.unlockForConfiguration() }
                    if let exposure {
                        captureDevice.setExposureTargetBias(exposure)
                    }
                    if let focus {
                        captureDevice.setFocusModeLocked(lensPosition: focus, completionHandler: { time in
                            print("초점 조정 완료: \(time)")
                        })
                    }
                    if let zoom {
                        let min = Float(captureDevice.minAvailableVideoZoomFactor)
                        let max = Float(captureDevice.maxAvailableVideoZoomFactor)
                        if min <= zoom && zoom <= max {
                            captureDevice.videoZoomFactor = CGFloat(zoom)
                        } else {
                            print("out of range : \(zoom)")
                        }
                    }
                    if let whiteBalance,
                       let r = whiteBalance["red"],
                       let g = whiteBalance["green"],
                       let b = whiteBalance["blue"] {
                        let max = captureDevice.maxWhiteBalanceGain
                        if r > max || g > max || b > max {
                            print("out of range : r \(r) g \(g) b \(b) max : \(max)")
                            return
                        }
                        captureDevice.setWhiteBalanceModeLocked(
                            with: AVCaptureDevice.WhiteBalanceGains(redGain: r, greenGain: g, blueGain: b),
                            completionHandler: { _ in
                                print("화이트밸런스 조절 완료")
                            }
                        )
                    }
                } catch {
                    print("error : " + error.localizedDescription)
                }
            }
        }
        
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    var initialZoomFactor:CGFloat = 1.0
    var currentZoomFactor:CGFloat = 1.0 {
        didSet {
            if(oldValue != currentZoomFactor) {
                //                setZoomFactor(currentZoomFactor)
                Log.debug("currentZoomFactor:",currentZoomFactor)
                NotificationCenter.default.post(name: .cameraSettingChange, object: nil, userInfo: [
                    "zoom" : Float(currentZoomFactor),
                ])
                
            }
        }
    }
    
    @objc func pinchGesture(sender:UIPinchGestureRecognizer) {
        print(sender.scale)
        //        self.updateZoomScale()
        switch sender.state {
        case .began:
            initialZoomFactor = captureDevice?.videoZoomFactor ?? 1.0
            currentZoomFactor = initialZoomFactor
        case .changed:
            let zoomFector = initialZoomFactor * sender.scale
            //            setZoomFactor(zoomFector)
            currentZoomFactor = zoomFector
        default:
            break
        }
    }
    
    @objc func tapGesture(sender:UITapGestureRecognizer) {
        self.capturePhoto()
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let errorDescription = error?.localizedDescription
        let imageData = photo.fileDataRepresentation()
        Task { @MainActor [weak self] in
            if let errorDescription {
                Log.error(#function, "carmera error:", errorDescription)
            }
            guard let imageData, let image = UIImage(data: imageData) else {
                Log.error(#function, "Error capturing photo.")
                return
            }
            self?.onCapture(image)
        }
    }
}
