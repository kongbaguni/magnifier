//
//  Notification.Names.swift
//  WidgetDemo
//
//  Created by Changyeol Seo on 2023/06/28.
//

import Foundation

extension Notification.Name {
    static let carmeraCtlZoom = Notification.Name("carmeraCtlZoom_observer")
    static let carmeraZoomChanged = Notification.Name("carmeraZoomChanged_observer")
    static let carmeraPreviewLog = Notification.Name("carmeraPreviewLog_observer")
    static let carmeraTakePhoto = Notification.Name("carmeraTakePhoto_observer")
    static let carmeraPhotoOutput = Notification.Name("cameraPhotoOutput_observer")
    static let carmeraTakePhotoSaveFinish = Notification.Name("carmeraTakePhotoSaveFinish_observer")
    static let carmeraSettingChange = Notification.Name("carmeraSettingChange_observer")
    static let cameraRequestPermissionGetResult = Notification.Name("CameraRequestPermissionGetResult_observer")
    
    static let adLoadingStart = Notification.Name("adLoadingStart_observer")
    static let adLoadingFinish = Notification.Name("adLoadingFinish_observer")
    static let adLoadingFail = Notification.Name("adLoadingFail_observer")
    
    static let adBannerLoadingStart = Notification.Name("adBannerLoadingStart_observer")
    static let adBannerLoadingFinish = Notification.Name("adBannerLoadingFinish_observer")
    static let adBannerLoadingFail = Notification.Name("adBannerLoadingFail_observer")

}
