import SwiftUI
import AVFoundation
extension Notification.Name {
    static let carmeraCtlZoom = Notification.Name("carmeraCtlZoom_observer")
    static let carmeraPreviewLog = Notification.Name("carmeraPreviewLog_observer")
    static let carmeraTakePhoto = Notification.Name("carmeraTakePhoto_observer")
    static let carmeraPhotoOutput = Notification.Name("cameraPhotoOutput_observer")
}

struct CameraPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        return CameraPreviewView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // No update necessary
    }
}

class CameraPreviewView: UIView {
    private var permissionGranted = false // Flag for permission
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private var previewLayer = AVCaptureVideoPreviewLayer()
    var captureDevice : AVCaptureDevice? = nil
    var photoOutput: AVCapturePhotoOutput? = nil
    
    var screenRect: CGRect! = nil // For view dimensions
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCamera()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCamera()
    }
    
    private func setupCamera() {
        "setupCamera".sendLog()
        checkPermission()
        sessionQueue.async { [unowned self] in
            guard permissionGranted else { return }
            self.setupCaptureSession()
            self.captureSession.startRunning()
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
    
    private func setupCaptureSession() {
        // Access camera
        "\(#function) \(#line)".sendLog()
        guard let videoDevice = AVCaptureDevice.default(.builtInDualWideCamera,for: .video, position: .back) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        
        self.captureDevice = videoDevice
        
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
        // TODO: Add preview layer
        DispatchQueue.main.async {
            self.screenRect = self.layer.frame
        }
        //        screenRect = UIScreen.main.bounds
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill // Fill screen
        
        previewLayer.connection?.videoOrientation = .portrait
        // Updates to UI must be on main queue
        DispatchQueue.main.async { [weak self] in
            self!.layer.addSublayer(self!.previewLayer)
        }
        self.layer.masksToBounds = true;
        
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
            s.zoomScale = zoomScale
        }
        
        NotificationCenter.default.addObserver(forName: .carmeraTakePhoto, object: nil, queue: nil) { [weak self] noti in
            DispatchQueue.main.async {
                self?.takePhoto()
            }
        }
        
       
        self.zoomScale = videoDevice.videoZoomFactor
        "zoomscale : \(self.zoomScale)".sendLog()
        self.updateZoomScale()
    }
    
    var zoomScale:CGFloat = 1.0 {
        didSet {
            DispatchQueue.main.async {
                self.updateZoomScale()
            }
        }
    }
    
    private func updateZoomScale() {
        "\(#line):\(#function) zoom : \(self.zoomScale)".sendLog()
        guard let captureDevice = AVCaptureDevice.default(.builtInDualWideCamera,for: .video, position: .back) else {
            "\(#function):\(#line)".sendLog()
            return
        }
        "\(#function):\(#line)".sendLog()
        do {
            "\(#function):\(#line)".sendLog()
            try captureDevice.lockForConfiguration()
            
            let maxZoomFactor = captureDevice.activeFormat.videoMaxZoomFactor
            let clampedZoomScale = max(1.0, min(zoomScale, maxZoomFactor))
            
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
    }
    
}
