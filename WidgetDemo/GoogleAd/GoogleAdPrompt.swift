//
//  UserMessagePrompt.swift
//  GaweeBaweeBoh
//
//  Created by Changyeol Seo on 2023/07/20.
//

import Foundation
import UIKit
import UserMessagingPlatform
import AppTrackingTransparency

// The SDK callback returns a UI-bound object that is only accessed after a MainActor hop.
private struct ConsentFormTransfer: @unchecked Sendable {
    let form: ConsentForm?
}

@MainActor
fileprivate func requestTrackingAuthorization(complete: @escaping @MainActor @Sendable () -> Void) {
    ATTrackingManager.requestTrackingAuthorization { status in
        print("google ad tracking status : \(status)")
        Task { @MainActor in
            complete()
        }
    }
}

@MainActor
fileprivate func loadUserMessageForm() {
    guard let viewController = UIApplication.shared.lastViewController else {
        Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(1))
            } catch {
                return
            }
            loadUserMessageForm()
        }
        return
    }

    ConsentForm.load { form, loadError in
        if let loadError {
            print("Consent form load error: \(loadError.localizedDescription)")
            return
        }
        let transfer = ConsentFormTransfer(form: form)
        Task { @MainActor [transfer] in
            if ConsentInformation.shared.consentStatus == ConsentStatus.required,
               let form = transfer.form {
                do {
                    try await form.present(from: viewController)
                } catch {
                    print("Consent form presentation error: \(error.localizedDescription)")
                }
            }
        }
    }
}

@MainActor
fileprivate func userMessagePlatformPrompt(complete: @escaping @MainActor @Sendable () -> Void) {
    
    #if DEBUG
    ConsentInformation.shared.reset()
    #endif

    // Create a UMPRequestParameters object.
    let parameters = RequestParameters()
    // Set tag for under age of consent. Here false means users are not under age.
    parameters.isTaggedForUnderAgeOfConsent = false
    #if DEBUG
    let debugSettings = DebugSettings()
//        debugSettings.testDeviceIdentifiers = ["78ce88aff302a5f4dfa5226a766c0b5a"]
    debugSettings.geography = DebugGeography.EEA
    parameters.debugSettings = debugSettings
    #endif
    ConsentInformation.shared.requestConsentInfoUpdate(
        with: parameters,
        completionHandler: { error in
            let errorDescription = error?.localizedDescription
            Task { @MainActor in
                if let errorDescription {
                    print(errorDescription)
                } else {
                    let formStatus = ConsentInformation.shared.formStatus
                    if formStatus == FormStatus.available {
                        loadUserMessageForm()
                    }
                }
                complete()
            }
        })
}
/** 구글 AD 사용 위한 권한 등 프롬프트 요청..*/
struct GoogleAdPrompt {
    @MainActor
    static func promptWithDelay(complete: @escaping @MainActor @Sendable () -> Void) {
        // contentView.init 등에서 호출할 때 1초 딜레이를 주어야 알람창이 뜬다.
        Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(1))
            } catch {
                return
            }
            requestTrackingAuthorization {
                userMessagePlatformPrompt {
                    complete()
                }
            }
        }
    }
}
