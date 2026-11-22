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
}

@MainActor
func autoriserPaysageCuisine(_ autoriser: Bool) {
    for case let scene as UIWindowScene in UIApplication.shared.connectedScenes
    where scene.activationState == .foregroundActive {
        guard let orientation = scene.delegate as? OrientationScene else { continue }
        orientation.cuisineOuverte = autoriser
        let racine = scene.keyWindow?.rootViewController
        racine?.setNeedsUpdateOfSupportedInterfaceOrientations()
        racine?.presentedViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        if !autoriser && scene.effectiveGeometry.interfaceOrientation.isLandscape {
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait)) { erreur in
                Logger(subsystem: "xyz.g1lom.persillade", category: "Orientation")
                    .error("Retour au portrait impossible : \(erreur.localizedDescription)")
            }
        }
    }
}
