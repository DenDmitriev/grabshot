//
//  TabCoordinator.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 22.12.2023.
//

import SwiftUI

class TabCoordinator: ObservableObject, NavigationCoordinator {
    
    var childCoordinators: [any NavigationCoordinator] = []
    weak var finishDelegate: NavigationCoordinatorFinishDelegate?
    var viewModels: [any ObservableObject] = []
    
    @Published var route: TabRouter
    @Published var path: NavigationPath = .init()
    @Published var sheet: TabRouter?
    @Published var cover: TabRouter?
    @Published var hasError: Bool = false
    var error: AppError?
    
    @ObservedObject var videoStore: VideoStore
    @ObservedObject var imageStore: ImageStore
    @ObservedObject var scoreController: ScoreController
    
    init(tab: TabRouter, videoStore: VideoStore, imageStore: ImageStore, scoreController: ScoreController) {
        self.route = tab
        self.videoStore = videoStore
        self.imageStore = imageStore
        self.scoreController = scoreController
    }
    
    func change(_ route: TabRouter) {
        self.route = route
    }
    
    func push(_ page: TabRouter) {
        path.append(page)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func present(sheet: TabRouter) {
        self.sheet = sheet
    }
    
    func dismissSheet() {
        sheet = nil
    }
    
    func present(cover: TabRouter) {
        self.cover = cover
    }
    
    func dismissCover() {
        cover = nil
    }
    
    func presentAlert(error: AppError) {
        self.error = error
        hasError = true
    }
    
    @ViewBuilder
    func build(_ route: TabRouter) -> some View {
        route.view(coordinator: self)
            .tag(route)
    }
    
    func buildViewModel(_ route: TabRouter) -> (any ObservableObject)? {
        return nil
    }
    
    func getCoordinator(tab: TabRouter) -> (any NavigationCoordinator)? {
        tab.buildCoordinator(in: self)
    }
}

extension TabCoordinator: NavigationCoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: any NavigationCoordinator) {
        childCoordinators = childCoordinators.filter({ coordinator in
            type(of: coordinator.route) != type(of: childCoordinator.route)
        })
    }
}
