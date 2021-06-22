//
//  Copyright © 2021 Mac SE. All rights reserved.
//

import UIKit

extension UIWindow {
    
    class func makeWindow(with viewController: UIViewController) -> UIWindow? {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: viewController)
        return window
    }
    
    @available(iOS 13.0, *)
    class func makeWindow(
        with windowScene: UIWindowScene,
        viewController: UIViewController
    ) -> UIWindow {
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: viewController)
        return window
    }
}
