import SwiftUI
@preconcurrency import AVFoundation

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
        let newRotationAngle: CGFloat
        switch UIDevice.current.orientation {
        case .portrait:
            newRotationAngle = 90
        case .portraitUpsideDown:
            newRotationAngle = 270
        case .landscapeLeft:
            newRotationAngle = 0
        case .landscapeRight:
            newRotationAngle = 180
        default:
            newRotationAngle = 90
        }
        if let connection = previewLayer.connection,
           connection.isVideoRotationAngleSupported(newRotationAngle) {
            connection.videoRotationAngle = newRotationAngle
        }
    }
    
    private func setupCamera() {
        "setupCamera".sendLog()
        checkPermission()
        
        NotificationCenter.default.addObserver(forName: .carmeraSettingChange, object: nil, queue: nil) {[weak self] noti in
            let isManual = noti.userInfo?["isOnExposureManual"] as? Bool
            let exposureValue = noti.userInfo?["exposureManualValue"] as? Double
            Task { @MainActor [weak self] in
                if let isManual {
                    self?.setExposureMode(isManual: isManual)
                }
                if let exposureValue {
                    self?.setExposureValue(value: Int64(exposureValue * 10))
                }
            }
        }
        NotificationCenter.default.addObserver(forName: .carmeraZoomChangedWithZoomController, object: nil, queue: nil) { [weak self] noti in
            let zoom = noti.object as? CGFloat
            Task { @MainActor [weak self] in
                if let zoom {
                    self?.setZoomFactor(zoom)
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
            configureAndStartCaptureSession()
            
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
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.permissionGranted = granted
                NotificationCenter.default.post(name: .cameraRequestPermissionGetResult, object: granted)
                if granted {
                    self.configureAndStartCaptureSession()
                }
            }
        }
    }

    private func configureAndStartCaptureSession() {
        guard permissionGranted else { return }
        setupCaptureSession()
        let session = captureSession
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
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
        screenRect = layer.frame
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        previewLayer.videoGravity = .resizeAspectFill
        if let connection = previewLayer.connection,
           connection.isVideoRotationAngleSupported(90) {
            connection.videoRotationAngle = 90
        }
        layer.masksToBounds = true
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        layer.addSublayer(previewLayer)
        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(sender:)))
        addGestureRecognizer(gesture)
        
        photoOutput = AVCapturePhotoOutput()
        if let photoOutput = photoOutput {
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
        }
        
        NotificationCenter.default.addObserver(forName: .carmeraCtlZoom, object: nil, queue: nil) { [weak self] noti in
            let zoomScale = noti.object as? CGFloat ?? 1.0
            Task { @MainActor [weak self] in
                self?.currentZoomFactor = zoomScale
            }
        }
        
        NotificationCenter.default.addObserver(forName: .carmeraTakePhoto, object: nil, queue: nil) { [weak self] noti in
            Task { @MainActor [weak self] in
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
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        Task { @MainActor [weak self] in
            guard let self, let image = UIImage(data: imageData) else {
                return
            }
            NotificationCenter.default.post(name: .carmeraPhotoOutput, object: image)
            "\(#function):\(#line)".sendLog()
            self.saveImageToAppGroup(image: image)
        }
    }
}


extension CameraPreviewView {
    func saveImageToAppGroup(image: UIImage) {
        AppGroup.saveImage(image: image)
    }
}
