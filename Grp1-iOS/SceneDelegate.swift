//
 //  SceneDelegate.swift
 //  Grp1-iOS
 //
 //  Created by SDC-USER on 25/11/25.
 //

 import UIKit

 class SceneDelegate: UIResponder, UIWindowSceneDelegate {

     var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Restore session
        SessionManager.shared.restoreSession()

        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        let hasOnboarding = UserDefaults.standard.bool(forKey: "hasOnboarding")

        window = UIWindow(windowScene: windowScene)

        if isLoggedIn && SessionManager.shared.isLoggedIn {
            if hasOnboarding {
                // User is logged in AND has completed onboarding → go to Home
                let storyboard = UIStoryboard(name: "HomeMain", bundle: nil)
                window?.rootViewController = storyboard.instantiateInitialViewController()
            } else {
                // User is logged in but hasn't completed onboarding → go to Onboarding
                let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
                window?.rootViewController = storyboard.instantiateViewController(
                    withIdentifier: "OnboardingPageViewController"
                )
            }
        } else {
            // Not logged in → show Login (Authentication storyboard)
            let storyboard = UIStoryboard(name: "Authentication", bundle: nil)
            window?.rootViewController = storyboard.instantiateInitialViewController()
        }

        window?.makeKeyAndVisible()
    }

//      func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
//                 options connectionOptions: UIScene.ConnectionOptions) {
//
//          guard let windowScene = (scene as? UIWindowScene) else { return }
//          window = UIWindow(windowScene: windowScene)
//
//          // Directly launch Generative Scenario for testing:
//          let storyboard = UIStoryboard(name: "Scenario", bundle: nil)
//          window?.rootViewController = storyboard.instantiateInitialViewController()
//
//          window?.makeKeyAndVisible()
//      }

     func sceneDidDisconnect(_ scene: UIScene) {}
     func sceneDidBecomeActive(_ scene: UIScene) {}
     func sceneWillResignActive(_ scene: UIScene) {}
     func sceneWillEnterForeground(_ scene: UIScene) {}
     func sceneDidEnterBackground(_ scene: UIScene) {}
 }
