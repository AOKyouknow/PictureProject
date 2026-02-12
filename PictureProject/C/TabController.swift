//
//  TabController.swift
//  HZ
//
//  Created by Алик on 01.10.2025.
//

//import UIKit
//
//final class TabController: UITabBarController { //TODO: final class. ПОЩЕМУ????
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupTabs() // можно без self, почему?!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//    }
//    private func setupTabs(){
//        //ЭТО ПОЯВЛЕНИЕ ДВУХ ВКЛАДОК!!!!!!!!!!!!!
//        let oneTab = createNav(with: "One", and: UIImage(systemName: "check_circle"), vc: One()) //TODO: это точно должно тут инициализироваться? В ГДЕ ЕЩË?
//        let twoTab = createNav(with: "Two", and: UIImage(systemName: "favorite"), vc: Two())
//        self.setViewControllers([oneTab, twoTab], animated: true)
//        //это появление двух вкладок
//    }
//    private func createNav(with title: String, and image: UIImage?, vc: UIViewController) -> UINavigationController {
//        
//        let nav = UINavigationController(rootViewController: vc)
//        
//        //TODO: 1 - данный метод отвечает за создание и настройку вьюшки, а не за настройку таббара. Во первых, метод выполняет не свою задачку, во вторых, он вызывается два раза и ты два раза задаешь тайтл и картинку таббару
//        nav.tabBarItem.title = title
//        nav.tabBarItem.image = image //TODO: 1 - а картинки в итоге то где?
//        nav.viewControllers.first?.navigationItem.title = title + " Controller"
//        nav.viewControllers.first?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Button", style: .plain, target: nil, action: nil)
//        return nav
//    }

    //
    //  TabBarController.swift
    //  HZ
    //
    //  Created by Алик on 12.02.2026.
    //

    import UIKit

    final class TabBarController: UITabBarController {
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            configureAppearance()
            configureViewControllers()
        }
        
        // MARK: - Configuration
        private func configureAppearance() {
            // Настройка Tab Bar
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            tabBar.standardAppearance = tabBarAppearance
            tabBar.scrollEdgeAppearance = tabBarAppearance
            
            // Настройка Navigation Bar
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithDefaultBackground()
            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        }
        
        private func configureViewControllers() {
            viewControllers = [
                createNavigationController(
                    rootViewController: One(),
                    title: "Главная",
                    image: "photo.on.rectangle",
                    selectedImage: "photo.on.rectangle.fill"
                ),
                createNavigationController(
                    rootViewController: Two(),
                    title: "Избранное",
                    image: "heart",
                    selectedImage: "heart.fill"
                ),
                createProfileViewController()
            ]
        }
        
        private func createNavigationController(rootViewController: UIViewController,
                                               title: String,
                                               image: String,
                                               selectedImage: String) -> UINavigationController {
            rootViewController.title = title
            rootViewController.tabBarItem = UITabBarItem(
                title: title,
                image: UIImage(systemName: image),
                selectedImage: UIImage(systemName: selectedImage)
            )
            return UINavigationController(rootViewController: rootViewController)
        }
        
        private func createProfileViewController() -> UINavigationController {
            let profileVC = UIViewController()
            profileVC.view.backgroundColor = .systemBackground
            profileVC.title = "Профиль"
            profileVC.tabBarItem = UITabBarItem(
                title: "Профиль",
                image: UIImage(systemName: "person"),
                selectedImage: UIImage(systemName: "person.fill")
            )
            return UINavigationController(rootViewController: profileVC)
        }
    }
