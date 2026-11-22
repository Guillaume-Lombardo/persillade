import OSLog
import UIKit

final class OrientationPersillade: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication, configurationForConnecting session: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = session.configuration
        configuration.delegateClass = OrientationScene.self
        return configuration
    }
}

private final class OrientationScene: NSObject, UIWindowSceneDelegate {
    var cuisineOuverte = false

    func supportedInterfaceOrientations(for windowScene: UIWindowScene) -> UIInterfaceOrientationMask {
        cuisineOuverte ? .allButUpsideDown : .portrait
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if let fenetre = scene as? UIWindowScene { actualiserOrientation(fenetre) }
    }

    func actualiserOrientation(_ scene: UIWindowScene) {
        guard scene.activationState == .foregroundActive else { return }
        let racine = scene.keyWindow?.rootViewController
        racine?.setNeedsUpdateOfSupportedInterfaceOrientations()
        racine?.presentedViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        if !cuisineOuverte && scene.effectiveGeometry.interfaceOrientation.isLandscape {
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait)) { erreur in
                Logger(subsystem: "xyz.g1lom.persillade", category: "Orientation")
                    .error("Retour au portrait impossible : \(erreur.localizedDescription)")
            }
        }
    }
}

@MainActor
func autoriserPaysageCuisine(_ autoriser: Bool) {
    for case let scene as UIWindowScene in UIApplication.shared.connectedScenes {
        guard let orientation = scene.delegate as? OrientationScene else { continue }
        orientation.cuisineOuverte = autoriser
        orientation.actualiserOrientation(scene)
    }
}
