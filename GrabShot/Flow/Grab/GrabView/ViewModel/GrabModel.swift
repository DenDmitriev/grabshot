//
//  GrabModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.11.2022.
//

import SwiftUI
import Combine

class GrabModel: ObservableObject {
    
    // MARK: - Properties
    
    @ObservedObject var session: Session
    @Published var grabState: GrabState
    @Published var grabbingID: Video.ID?
    @Published var selection = Set<Video.ID>()
    @Published var progress: Progress
    @Published var durationGrabbing: TimeInterval = .zero
    @Published var error: GrabError?
    @Published var showAlert: Bool = false
    
    var dropDelegate: VideoDropDelegate
    var strip: NSImage?
    
    private var grabOperationManager: GrabOperationManager?
    private var stripManager: StripManager?
    private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private var store = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init() {
        session = Session.shared
        grabState = .ready
        progress = .init(total: .zero)
        dropDelegate = VideoDropDelegate()
        dropDelegate.errorHandler = self
        bindOnTimer()
    }
    
    // MARK: - Functions
    
    // MARK: - Operation control functions
    
    func grabbingButtonRouter() {
        switch grabState {
        case .ready, .complete, .canceled:
            start()
        case .pause:
            resume()
        case .grabbing:
            pause()
        case .calculating:
            return
        }
    }
    
    func start() {
        createGrabOperationManager()
        createStripManager()
        
        clearDataForViews()
        
        guard let video = grabOperationManager?.videos.first else { return }
        
        createTimer()
        
        self.session.isGrabbing = true
        self.grabState = .grabbing(log: buildLog(video: video))
        
        configureInitDataForViews(on: video)
        
        grabOperationManager?.start()
    }
    
    func resume() {
        guard
            grabOperationManager != nil,
            let id = grabbingID,
            let video = grabOperationManager?.videos.first(where: { $0.id == id })
        else { return }
        
        createTimer()
        
        self.session.isGrabbing = true
        self.grabState = .grabbing(log: buildLog(video: video))
        
        grabOperationManager?.resume()
    }
    
    func pause() {
        guard grabOperationManager != nil else { return }
        
        grabOperationManager?.pause()
        
        self.session.isGrabbing = false
        self.grabState = .pause()
    }
    
    func cancel() {
        session.isGrabbing = false
        grabState = .canceled
        grabOperationManager?.cancel()
        grabOperationManager = nil
        stripManager = nil
        clearDataForViews()
    }
    
    // MARK: - Other public functions
    
    func didAppendVideos(videos: [Video]) {
        bind(on: videos)
    }
    
    func didDeleteVideos(by selection: Set<Int>) {
        guard
            !selection.isEmpty,
            !isDisabledUIForUserInterActive(by: grabState)
        else { return }
        
        let operation = BlockOperation {
            selection.forEach { id in
                self.session.videos.removeAll(where: { $0.id == id })
                self.grabOperationManager?.videos.removeAll(where: { $0.id == id })
            }
        }
        operation.completionBlock = {
            self.updateProgress()
        }
        
        DispatchQueue.main.async {
            operation.start()
        }
    }
    
    func getColorsVideo(id: Video.ID?) -> [Color]? {
        guard
            let id = id,
            let video = session.videos.first(where: { $0.id == id }),
            let colors = video.colors
        else { return nil }
        
        return colors
    }
    
    func getTitleForGrabbingButton() -> String {
        let title: String
        switch grabState {
        case .ready, .calculating, .complete, .canceled:
            title = "Start"
        case .grabbing:
            title = "Pause"
        case .pause:
            title = "Resume"
        }
        return NSLocalizedString(title, comment: "Button title")
    }
    
    func isEnableGrabbingButton() -> Bool {
        session.videos.filter { $0.isEnable }.isEmpty
    }
    
    func isEnableCancelButton() -> Bool {
        switch grabState {
        case .ready, .calculating, .canceled, .complete:
            return false
        case .grabbing, .pause:
            return true
        }
    }
    
    func isDisableRemoveButton() -> Bool {
        session.videos.isEmpty || session.isGrabbing || session.isCalculating
    }
    
    func updateProgress() {
        let totalShots = session.videos
            .filter { video in
                video.isEnable
            }
            .map { video in
                video.progress.total
            }
            .reduce(.zero) { $0 + $1 }
        
        let currentShots = session.videos
            .filter { video in
                video.isEnable
            }
            .map { video in
                video.progress.current
            }
            .reduce(.zero) { $0 + $1 }
        
        DispatchQueue.main.async {
            self.progress.current = currentShots
            self.progress.total = totalShots
        }
    }
    
    func getVideoForStripView() -> Video? {
        guard let grabbedID = grabbingID else { return nil }
        if selection.isEmpty {
            DispatchQueue.main.async {
                self.selection.insert(grabbedID)
            }
        }
        guard let id = selection.first else { return nil }
        return session.videos.first(where: { $0.id == id })
    }
    
    // MARK: - Private functions
    
    private func isDisabledUIForUserInterActive(by state: GrabState) -> Bool {
        switch state {
        case .ready, .canceled, .complete:
            return false
        case .calculating, .grabbing, .pause:
            return true
        }
    }
    
    private func createGrabOperationManager() {
        let videos = session.videos.filter({ $0.isEnable == true })
        grabOperationManager = GrabOperationManager(videos: videos, period: session.period, stripColorCount: session.stripCount)
        grabOperationManager?.delegate = self
    }
    
    private func createStripManager() {
        stripManager = StripManager(stripColorCount: session.stripCount)
    }
    
    private func configureInitDataForViews(on video: Video) {
        grabbingID = video.id
    }
    
    private func createTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
    
    private func bindOnTimer() {
        timer.sink { date in
            switch self.grabState {
            case .grabbing:
                self.durationGrabbing += 1
            case .complete, .pause:
                self.timer.upstream.connect().cancel()
            default:
                return
            }
        }
        .store(in: &store)
    }
    
    private func bind(on videos: [Video]) {
        videos.forEach { video in
            video.$didUpdated
                .sink { _ in
                    self.updateProgress()
                }
                .store(in: &store)
        }
    }
    
    private func clearDataForViews() {
        durationGrabbing = .zero
        progress.current = .zero
        session.videos
            .filter { $0.isEnable }
            .forEach { video in
            video.clear()
        }
    }
    
    private func buildLog(video: Video?) -> String {
        guard let video = video else { return "" }
        let title = video.title
        let progress = video.progress
        return title + " – " + progress.status
    }
    
    private func createStripView(for video: Video) {
        // TODO: Create with builder
        let stripModel = StripModel(video: video)
        let stripView = StripView(viewModel: stripModel)
        stripModel.saveImage(view: stripView)
    }
}

extension GrabModel: GrabOperationManagerDelegate {
    
    func started(video: Video) {
        DispatchQueue.main.async {
            self.grabbingID = video.id
            self.session.isGrabbing = true
            self.grabState = .grabbing(log: self.buildLog(video: video))
        }
    }
    
    func progress(for video: Video, isCreated: Int, on timecode: TimeInterval, by url: URL) {
        DispatchQueue.main.async {
            switch self.grabState {
            case .canceled:
                video.progress.current = .zero
            case .grabbing, .pause:
                self.progress.current += 1
                
                self.stripManager?.appendAverageColors(for: video, from: url)
                
                let log = self.buildLog(video: video)
                if self.grabState == .pause() {
                    self.grabState = .pause(log: log)
                } else {
                    self.grabState = .grabbing(log: log)
                }
            default:
                return
            }
        }
    }
    
    func completed(for video: Video) {
        if session.openDirToggle {
            // TODO: Extract to router method
            FileService.openDir(by: video.url.deletingPathExtension())
        }
        
        DispatchQueue.main.async {
            if video.progress.current == video.progress.total {
                video.isEnable = false
            }
        }
        
        createStripView(for: video)
    }
    
    func completedAll() {
        DispatchQueue.main.async {
            self.grabState = .complete(shots: self.progress.total)
            self.session.isGrabbing = false
            self.session.updateGrabCounter(self.progress.current)
        }
    }
    
    func error(_ error: Error) {
        DispatchQueue.main.async {
            if let localizedError = error as? LocalizedError {
                self.error = GrabError.map(errorDescription: localizedError.localizedDescription, recoverySuggestion: nil)
            } else {
                self.error = GrabError.unknown
            }
            self.showAlert = true
        }
    }
}

extension GrabModel: DropErrorHandler {
    func presentError(error: DropError) {
        DispatchQueue.main.async {
            self.error = GrabError.map(errorDescription: error.localizedDescription, recoverySuggestion: error.recoverySuggestion)
            self.showAlert = true
        }
    }
}
