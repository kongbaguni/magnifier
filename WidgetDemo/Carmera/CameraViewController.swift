//
//  CameraViewController.swift
//  ucmIos
//
//  Created by Changyeol Seo on 10/29/24.
//
import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    private var onCapture: (UIImage) -> Void = { _ in }
    private var captureSession: AVCaptureSession?
    private var photoOutput = AVCapturePhotoOutput()
    private var captureDevice: AVCaptureDevice?

        
    func setupCamera(onCapture: @escaping (UIImage) -> Void) {
        self.onCapture = onCapture
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo
        
        
        guard let backCamera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: backCamera),
              captureSession?.canAddInput(input) == true else {
            Log.error(#function, "Unable to access back camera!")
            return
        }
        
        captureDevice = backCamera
        
        captureSession?.addInput(input)
        
        if captureSession?.canAddOutput(photoOutput) == true {
            captureSession?.addOutput(photoOutput)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer.videoGravity = .resizeAspect
        previewLayer.frame = view.layer.frame
        previewLayer.frame.size.height = previewLayer.frame.width / 3 * 4
        previewLayer.frame.origin = .zero
                
        view.layer.addSublayer(previewLayer)
        
        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchGesture(sender:)))
        view.addGestureRecognizer(gesture)
        
        
        DispatchQueue.global().async {[weak self] in
            self?.captureSession?.startRunning()
        }
        
        NotificationCenter.default.addObserver(forName: .cameraCapture, object: nil, queue: nil) { [weak self] noti in
            self?.capturePhoto()
        }
        
        NotificationCenter.default.addObserver(forName: .cameraSettingChange, object: nil, queue: nil) {[weak self] noti in
            do {
                try self?.captureDevice?.lockForConfiguration()
                if let value = noti.userInfo?["exporse"] as? Float {
                    self?.captureDevice?.setExposureTargetBias(value)
                }
                if let value = noti.userInfo?["focus"] as? Float {
                    self?.captureDevice?.setFocusModeLocked(lensPosition: value, completionHandler: { time in
                        print("초점 조정 완료: \(time)")
                    })
                }
                if let value = noti.userInfo?["zoom"] as? Float {
                    
                    let min = Float(self?.captureDevice?.minAvailableVideoZoomFactor ?? 0)
                    let max = Float(self?.captureDevice?.maxAvailableVideoZoomFactor ?? 0)
                    if min <= value && value <= max {
                        self?.captureDevice?.videoZoomFactor = CGFloat(value)
                    }
                    else {
                        print("out of range : \(value)")
                    }
                }
                if let dic = noti.userInfo?["whiteBalence"] as? [String:Float] {
                    if let r = dic["red"], let g = dic["green"], let b = dic["blue"] {
                        let max = self?.captureDevice?.maxWhiteBalanceGain ?? 0
                        if r > max || g > max || b > max {
                            print("out of range : r \(r) g \(g) b \(b) max : \(max)")
                            return
                        }
                        
                        self?.captureDevice?.setWhiteBalanceModeLocked(with: AVCaptureDevice.WhiteBalanceGains.init(redGain: r, greenGain: g, blueGain: b), completionHandler: { time in
                            print("화이트밸런스 조절 완료")
                        })
                    }
                }
                
                
                
            } catch {
                print("error : " + error.localizedDescription)
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
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            Log.error(#function, "carmera error:", error.localizedDescription)
        }
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            Log.error(#function, "Error capturing photo.")
            return
        }
        
        onCapture(image)
    }
}
