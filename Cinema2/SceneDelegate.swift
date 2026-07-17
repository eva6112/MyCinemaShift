import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?   //главное окно приложения

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let tabBarController = UITabBarController()
        
        //объект внешнего вида для таббара
        let appearance = UITabBarAppearance()
        //фон не меняет прозрачность
        appearance.configureWithOpaqueBackground()
        //светлая/темная тема
        appearance.backgroundColor = .systemBackground
        
        //применяюся на все состояния таббара
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        
        tabBarController.tabBar.tintColor = .label
        tabBarController.tabBar.unselectedItemTintColor = .systemGray
        
        //MARK: - Создание экранов
        
        //экран фильмы
        let filmsVC = FilmsViewController()
        let filmsNC = UINavigationController(rootViewController: filmsVC)
        filmsNC.navigationBar.prefersLargeTitles = true
        filmsNC.tabBarItem = UITabBarItem(title: "Фильмы",
                                          image: UIImage(systemName: "film"), tag: 0)
        
        //экран билеты
        let ticketsVC = TicketsViewController()
        let ticketsNC = UINavigationController(rootViewController: ticketsVC)
        ticketsNC.navigationBar.prefersLargeTitles = true
        ticketsNC.tabBarItem = UITabBarItem(title: "Билеты",
                                            image: UIImage(systemName: "ticket"), tag: 1)
        
        //экран профиль
        let profileVC = ProfileViewController()
        let profileNC = UINavigationController(rootViewController: profileVC)
        profileNC.navigationBar.prefersLargeTitles = true
        profileNC.tabBarItem = UITabBarItem(title: "Профиль",
                                            image: UIImage(systemName: "person"), tag: 2)
        
        //собираем вкладки в массив
        tabBarController.viewControllers = [filmsNC, ticketsNC, profileNC]
        
        //запускаем окно
        window.rootViewController = tabBarController
        
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        
        self.window = window
        //окно видимое и главное
        window.makeKeyAndVisible()
    }
}
