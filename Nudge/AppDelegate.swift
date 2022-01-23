//
//  AppDelegate.swift
//  Nudge
//
//  Created by Eli Zhang on 1/14/22.
//

import UIKit
import Combine
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var createUserCancellable: AnyCancellable?
    var updateUserCancellable: AnyCancellable?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
        if CredentialManager.getUserId() == nil {
            // Auto generate a password and store it in the keychain
            let len = 10
            let pswdChars = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890")
            let password = String((0..<len).map{ _ in pswdChars[Int(arc4random_uniform(UInt32(pswdChars.count)))]})
            let deviceToken = UserDefaults.standard.string(forKey: "deviceToken")
            
            createUserCancellable = NetworkManager.createUser(password: password, deviceToken: deviceToken)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                            case .failure(let error): print("Error: \(error)")
                            case .finished: print("Successfully created user.")
                        }
                    },
                    receiveValue: { userId in
                        CredentialManager.setPassword(password: password)
                        CredentialManager.setUserId(userId: userId)
                    }
                )
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self?.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        // If it hasn't been stored in UserDefaults, we need to update the profile
        if UserDefaults.standard.string(forKey: "deviceToken") == nil {
            if CredentialManager.getUserId() != nil {
                updateUserCancellable = NetworkManager.updateUserInfo(deviceToken: token)
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: { completion in
                            switch completion {
                                case .failure(let error): print("Error: \(error)")
                                case .finished: print("Successfully updated device token.")
                            }
                        },
                        receiveValue: { _ in
                            UserDefaults.standard.set(token, forKey: "deviceToken")
                        }
                    )
            }
            
        }
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
}

