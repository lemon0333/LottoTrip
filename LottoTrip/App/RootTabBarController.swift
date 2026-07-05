//
//  RootTabBarController.swift
//  LottoTrip
//
//  홈(지도퍼즐) · 슬롯 · 공동체 · 미션 · MY
//

import UIKit

final class RootTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.ivory
        configureTabs()
        configureAppearance()
    }

    private func configureTabs() {
        let tabs: [(title: String, icon: String, vc: UIViewController)] = [
            ("홈",     "puzzlepiece.fill",         PuzzleHomeViewController()),
            ("슬롯",   "dice.fill",                SlotMachineViewController()),
            ("공동체", "person.2.fill",            CommunityFeedViewController()),
            ("미션",   "camera.viewfinder",        MissionCaptureViewController()),
            ("MY",     "person.crop.circle.fill",  MyPageViewController())
        ]

        viewControllers = tabs.map { tab in
            tab.vc.title = tab.title
            let nav = UINavigationController(rootViewController: tab.vc)
            nav.tabBarItem = UITabBarItem(title: tab.title,
                                          image: UIImage(systemName: tab.icon),
                                          selectedImage: UIImage(systemName: tab.icon))
            return nav
        }
    }

    private func configureAppearance() {
        tabBar.tintColor = AppColor.coral
        tabBar.unselectedItemTintColor = AppColor.sub

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColor.card
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = AppColor.ivory
        navAppearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }
}
