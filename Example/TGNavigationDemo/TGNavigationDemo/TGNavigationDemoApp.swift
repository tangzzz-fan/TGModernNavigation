//
//  TGNavigationDemoApp.swift
//  TGNavigationDemo
//
//  Created by 小苹果 on 2026/1/16.
//

import SwiftUI
import TGModernNavigation
import AppCore
import HomeFeature
import NavigationFeature
import SettingsFeature
import UIComponents

// MARK: - Example App

@main
struct TGModernNavigationExampleApp: App {
    
    init() {
        // 注册路由模块
        // 在实际项目中，这里可以通过依赖注入容器自动完成
        let registry = RouteRegistry<AppRoute>.shared
        registry.register(HomeRouteModule())
        registry.register(NavigationRouteModule())
        registry.register(PresentationRouteModule())
        registry.register(DetailRouteModule())
        registry.register(UserRouteModule())
        registry.register(SettingsRouteModule())
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

// MARK: - App Theme

enum AppTheme {
    static let primary = Color.indigo
    static let secondary = Color.purple
    static let background = Color.systemGroupedBackground
    static let cardBackground = Color.secondarySystemGroupedBackground
}
