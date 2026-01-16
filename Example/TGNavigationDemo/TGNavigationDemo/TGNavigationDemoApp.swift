//
//  TGNavigationDemoApp.swift
//  TGNavigationDemo
//
//  Created by 小苹果 on 2026/1/16.
//

import SwiftUI
import TGModernNavigation

// MARK: - Example App

@main
struct TGModernNavigationExampleApp: App {
    
    /// 使用组合路由器管理导航和展示
    @State private var router = Router<AppRoute>()
    
    var body: some Scene {
        WindowGroup {
            RouterNavigationStack(router: router) {
                HomeView()
            }
            .tint(.indigo)
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
