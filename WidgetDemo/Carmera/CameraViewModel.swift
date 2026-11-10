import Combine
import Foundation
import UIKit

@MainActor
final class CameraViewModel: ObservableObject {
    enum SliderType: CaseIterable, Hashable {
        case zoom
        case focus
        case exposure
        case whiteBalanceRed
        case whiteBalanceGreen
        case whiteBalanceBlue
    }

    private let onCapture: (UIImage) -> Void
    private let defaults: UserDefaults
    private var isUpdatingZoomFromCamera = false

    @Published var exposure: Float {
        didSet {
            guard oldValue != exposure else { return }
            postCameraSetting(["exporse": exposure])
        }
    }

    @Published var focus: Float {
        didSet {
            guard oldValue != focus else { return }
            postCameraSetting(["focus": focus])
        }
    }

    @Published var zoom: Float {
        didSet {
            guard oldValue != zoom, !isUpdatingZoomFromCamera else { return }
            postCameraSetting(["zoom": zoom])
        }
    }

    @Published var lensSelection: Int {
        didSet {
            guard oldValue != lensSelection else { return }
            defaults.set(lensSelection, forKey: "lens_select")
            postCameraSetting(["lens": lensSelection])
        }
    }

    @Published var whiteBalanceRed: Double {
        didSet {
            guard oldValue != whiteBalanceRed else { return }
            defaults.set(whiteBalanceRed, forKey: "whiteBalance_red")
            postWhiteBalance()
        }
    }

    @Published var whiteBalanceGreen: Double {
        didSet {
            guard oldValue != whiteBalanceGreen else { return }
            defaults.set(whiteBalanceGreen, forKey: "whiteBalance_green")
            postWhiteBalance()
        }
    }

    @Published var whiteBalanceBlue: Double {
        didSet {
            guard oldValue != whiteBalanceBlue else { return }
            defaults.set(whiteBalanceBlue, forKey: "whiteBalance_blue")
            postWhiteBalance()
        }
    }

    @Published var isExtended: Bool {
        didSet {
            guard oldValue != isExtended else { return }
            defaults.set(isExtended, forKey: "isExtend")
        }
    }

    @Published private(set) var images: [UIImage] = []
    @Published var isPresentingImage = false

   
    init(
        onCapture: @escaping (UIImage) -> Void,
        defaults: UserDefaults = .standard
    ) {
        self.onCapture = onCapture
        self.defaults = defaults
        exposure = 0
        focus = 0
        zoom = 1
        lensSelection = defaults.object(forKey: "lens_select") as? Int ?? 0
        whiteBalanceRed = defaults.object(forKey: "whiteBalance_red") as? Double ?? 1.5
        whiteBalanceGreen = defaults.object(forKey: "whiteBalance_green") as? Double ?? 1.0
        whiteBalanceBlue = defaults.object(forKey: "whiteBalance_blue") as? Double ?? 3.0
        isExtended = defaults.object(forKey: "isExtend") as? Bool ?? true
    }

    func configureCamera() {
        NotificationCenter.default.post(
            name: .cameraSettingChange,
            object: nil,
            userInfo: [
                "lens": lensSelection,
                "focus": focus,
                "exporse": exposure,
                "zoom": zoom,
                "whiteBalence": [
                    "red": Float(whiteBalanceRed),
                    "green": Float(whiteBalanceGreen),
                    "blue": Float(whiteBalanceBlue)
                ]
            ]
        )
    }

    func capturePhoto() {
        NotificationCenter.default.post(name: .cameraCapture, object: nil)
    }

    
    func handleCapturedImage(_ image: UIImage) {
        Task { @MainActor in
            images.append(image)
            AppGroup.saveImage(image: image)
            onCapture(image)
        }
    }

    func showImage(_ image: UIImage) {
        AppGroup.saveImage(image: image)
        isPresentingImage = true
    }

    func clearImages() {
        images.removeAll()
    }

    func handleCameraSettingChange(_ notification: Notification) {
        guard let cameraZoom = notification.userInfo?["zoom"] as? Float,
              cameraZoom != zoom else {
            return
        }

        isUpdatingZoomFromCamera = true
        zoom = cameraZoom
        isUpdatingZoomFromCamera = false
    }

    private func postWhiteBalance() {
        postCameraSetting([
            "whiteBalence": [
                "red": Float(whiteBalanceRed),
                "green": Float(whiteBalanceGreen),
                "blue": Float(whiteBalanceBlue)
            ]
        ])
    }

    private func postCameraSetting(_ userInfo: [String: Any]) {
        NotificationCenter.default.post(
            name: .cameraSettingChange,
            object: nil,
            userInfo: userInfo
        )
    }
}
