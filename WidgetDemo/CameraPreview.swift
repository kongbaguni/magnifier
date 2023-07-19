import SwiftUI
import AVFoundation


struct CameraPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = CameraPreviewView(frame: UIScreen.main.bounds)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        print("\(#function) \(#line)")
        
//        if let c = uiView as? CameraPreviewView {
//            c.setPreviewLayerSize(rect: uiView.frame)
//            print("Camera preview size : \(uiView.frame)")
//        }
    }
}

class CameraPreviewView: UIView {
    private var permissionGranted = false // Flag for permission
    private let captureSession:AVCaptureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    var previewLayer = AVCaptureVideoPreviewLayer()
    var captureDevice : AVCaptureDevice? = nil
    var photoOutput: AVCapturePhotoOutput? = nil
    
    var screenRect: CGRect! = nil // For view dimensions
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        setupCamera()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = self.frame
        var newOrientation:AVCaptureVideoOrientation {
            switch UIDevice.current.orientation {
            case .portrait:
                return .portrait
            case .portraitUpsideDown:
                return .portraitUpsideDown
            case .landscapeLeft:
                return .landscapeRight
            case .landscapeRight:
                return .landscapeLeft
            default:
                return .portrait
            }
        }
        if(newOrientation != previewLayer.connection?.videoOrientation) {
            previewLayer.connection?.videoOrientation = newOrientation
        }
        
    }
    
    private func setupCamera() {
        "setupCamera".sendLog()
        checkPermission()
        sessionQueue.async { [unowned self] in
            guard permissionGranted else { return }
            self.setupCaptureSession()
            self.captureSession.startRunning()
        }
        
        NotificationCenter.default.addObserver(forName: .carmeraSettingChange, object: nil, queue: nil) {[weak self] noti in
            if let info = noti.userInfo {
                if let isOn = info["isOnExposureManual"] as? Bool {
                    self?.setExposureMode(isManual: isOn)
                }
                if let value = info["exposureManualValue"] as? Double {
                    
                    self?.setExposureValue(value: Int64(value * 10))
                }
            }
        }
    }
    
    func setExposureMode(isManual:Bool) {
        guard let videoDevice = captureDevice else {
            return
        }
        do {
            try videoDevice.lockForConfiguration()
            
            if videoDevice.isExposureModeSupported(.custom) {
                videoDevice.exposureMode = isManual ? .custom : .autoExpose
            }
            else {
                videoDevice.exposureMode = isManual ? .continuousAutoExposure : .autoExpose
            }
            videoDevice.unlockForConfiguration()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func setExposureValue(value:Int64) {
        guard let videoDevice = captureDevice else {
            return
        }

        do {
            try videoDevice.lockForConfiguration()
            let exposureDuration = CMTimeMake(value: value, timescale: 1000) // 노출 시간 설정 (1/1000초)
            if videoDevice.isExposureModeSupported(.custom) {
                videoDevice.setExposureModeCustom(duration: exposureDuration, iso: videoDevice.iso) { time in
                    
                }
                videoDevice.unlockForConfiguration()
            }
            
        } catch {
            
        }
        
    }
    
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            // Permission has been granted before
        case .authorized:
            "checkPermission : authorized".sendLog()
            permissionGranted = true
            
            // Permission has not been requested yet
        case .notDetermined:
            "checkPermission : notDetermined".sendLog()
            requestPermission()
            
        default:
            "checkPermission : false".sendLog()
            permissionGranted = false
        }
    }
    
    private func requestPermission() {
        "\(#function) \(#line)".sendLog()
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }
    private var currentVideoDevice:AVCaptureDevice? {
        return AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back) ??
        AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) ??
        AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) ??
        AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) ??
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) ??
        AVCaptureDevice.default(.builtInTelephotoCamera, for: .video, position: .back) 
    }
    
    private func setupCaptureSession() {
        // Access camera
        "\(#function) \(#line)".sendLog()
        
        guard let videoDevice = currentVideoDevice else {
            return
        }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            return
        }
        
        self.captureDevice = videoDevice
        
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
        // TODO: Add preview layer
        DispatchQueue.main.async {[weak self] in
            guard let s = self else {
                return
            }
            s.screenRect = s.layer.frame
            s.previewLayer = AVCaptureVideoPreviewLayer(session: s.captureSession)
            s.previewLayer.frame = CGRect(x: 0, y: 0, width: s.screenRect.size.width, height: s.screenRect.size.height)
            s.previewLayer.videoGravity = .resizeAspectFill // Fill screen
            s.previewLayer.connection?.videoOrientation = .portrait
            s.layer.masksToBounds = true;
            s.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            s.layer.addSublayer(s.previewLayer)
            let gesture = UIPinchGestureRecognizer(target: s, action: #selector(s.pinchGesture(sender:)))
            s.addGestureRecognizer(gesture)
        }
        
        photoOutput = AVCapturePhotoOutput()
        if let photoOutput = photoOutput {
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
        }
        
        NotificationCenter.default.addObserver(forName: .carmeraCtlZoom, object: nil, queue: nil) { [weak self] noti in
            guard let s = self else {
                return;
            }
            let zoomScale = noti.object as? CGFloat ?? 1.0
            s.currentZoomFactor = zoomScale
        }
        
        NotificationCenter.default.addObserver(forName: .carmeraTakePhoto, object: nil, queue: nil) { [weak self] noti in
            DispatchQueue.main.async {
                self?.takePhoto()
            }
        }
        
        self.currentZoomFactor = videoDevice.videoZoomFactor
        "zoomscale : \(self.currentZoomFactor)".sendLog()
        self.updateZoomScale()
    
    }
    var initialZoomFactor:CGFloat = 1.0
    var currentZoomFactor:CGFloat = 1.0 {
        didSet {
            if(oldValue != currentZoomFactor) {
                setZoomFactor(currentZoomFactor)
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
    
//    var zoomScale:CGFloat = 1.0 {
//        didSet {
//            DispatchQueue.main.async {
//                self.updateZoomScale()
//            }
//        }
//    }
    
    func setZoomFactor(_ zoomFactor: CGFloat) {
        guard let device = captureDevice else {
            return
        }
        
        do {
            try device.lockForConfiguration()
            
            var zoomFactor = max(1.0, min(zoomFactor, device.activeFormat.videoMaxZoomFactor))
            if(zoomFactor > 80) {
                zoomFactor = 80
            }
            device.videoZoomFactor = zoomFactor
            device.unlockForConfiguration()
            NotificationCenter.default.post(name: .carmeraZoomChanged, object: zoomFactor)
        } catch {
            // 오류 처리
        }
    }

    
    private func updateZoomScale() {
        "\(#line):\(#function) zoom : \(self.currentZoomFactor)".sendLog()
        guard let captureDevice = AVCaptureDevice.default(.builtInDualWideCamera,for: .video, position: .back) else {
            "\(#function):\(#line)".sendLog()
            return
        }
        "\(#function):\(#line)".sendLog()
        do {
            "\(#function):\(#line)".sendLog()
            try captureDevice.lockForConfiguration()
            
            let maxZoomFactor = captureDevice.activeFormat.videoMaxZoomFactor
            let clampedZoomScale = max(1.0, min(currentZoomFactor, maxZoomFactor))
            
            captureDevice.videoZoomFactor = clampedZoomScale
            captureDevice.focusMode = .continuousAutoFocus
            captureDevice.unlockForConfiguration()
            "\(#function):\(#line)".sendLog()
        } catch {
            "Failed to update zoom scale: \(error.localizedDescription)".sendLog()
        }
    }
    
    private func takePhoto() {
        guard let photoOutput = self.photoOutput else {
            return
        }
        let photosetting = AVCapturePhotoSettings()
        photosetting.isAutoRedEyeReductionEnabled = true
        
        photoOutput.isLivePhotoCaptureEnabled = false
        photoOutput.capturePhoto(with: photosetting, delegate: self)
        
    }
    
    
}


extension CameraPreviewView : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else {
            return
        }
        
        NotificationCenter.default.post(name: .carmeraPhotoOutput, object: image)
        "\(#function):\(#line)".sendLog()
        self.saveImageToAppGroup(image: image)
    }
}


extension CameraPreviewView {
    func saveImageToAppGroup(image: UIImage) {
        AppGroup.saveImage(image: image)
    }
}
