//
//  GrabOperationManager.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 30.11.2022.
//

import SwiftUI
import FirebaseCrashlytics

protocol GrabManagerDelegate: AnyObject {
    var scoreController: ScoreController? { get set }
    
    func hasError(_ error: Error)
    func started(video: Video)
    func updatedProgress(for video: Video, isCreated: Int, on timecode: Duration, by url: URL)
    func completed(for video: Video)
    func completedAll(grab count: Int)
}

class GrabManager {
    typealias Timecode = TimeInterval
    
    var videoStore: VideoStore
    var videos: [Video] {
        videoStore.sortedVideos.filter({ $0.isEnable == true })
    }
    weak var delegate: GrabManagerDelegate?
    
    private var videoService: FFmpegVideoService
    private var period: Double
    private var stripColorCount: Int
    private var timecodes: [ UUID : [Duration] ]
    private var error: Error?
    private var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .utility
        operationQueue.maxConcurrentOperationCount = 1
        return operationQueue
    }()
    private var grabCounter: Int = .zero
    private let format: FileService.Format
    
    init(videoStore: VideoStore, period: Double, format: FileService.Format, stripColorCount: Int) {
        self.videoStore = videoStore
        self.videoService = FFmpegVideoService()
        self.period = period
        self.stripColorCount = stripColorCount
        self.format = format
        self.timecodes = [:]
    }
    
    //MARK: - Public control
    
    func start() throws {
        guard let firstID = videos.first?.id else { return }
        try start(for: firstID)
    }
    
    func pause() {
        operationQueue.isSuspended = true
    }
    
    func resume() {
        operationQueue.isSuspended = false
    }
    
    func cancel() {
        self.operationQueue.cancelAllOperations()
    }
    
    
    func isPaused() -> Bool {
        operationQueue.isSuspended
    }
    
    //MARK: - Private
    
    private func start(for id: UUID, flags: [Flag] = [.autoAddImageGrabbing]) throws {
        guard let video = videos.first(where: { $0.id == id }) else { return }
        
        guard let exportDirectory = video.exportDirectory else {
            delegate?.completed(for: video)
            let error = GrabError.exportDirectoryFailure(title: video.title)
            throw error
        }
        
        guard FileManager.default.fileExists(atPath: exportDirectory.relativePath) else {
            delegate?.completed(for: video)
            let error = GrabError.exportDirectoryFailure(title: video.title)
            throw error
        }
        
        let operations = createOperations(for: video, with: period, format: format, flags: flags)
        operations.forEach { operation in
            operationQueue.addOperation(operation)
        }
        
        delegate?.started(video: video)
    }
    
    private func createOperations(for video: Video, with period: Double, format: FileService.Format, flags: [Flag] = []) -> [GrabOperation] {
        let timecodes = timecodes(for: video)
        self.timecodes[video.id] = timecodes
        let grabOperations = timecodes.map { timecode in
            let grabOperation = GrabOperation(video: video, period: period, timecode: timecode, quality: UserDefaultsService.default.quality, format: format)
            grabOperation.completionBlock = { [weak self] in
                if let result = grabOperation.result {
                    switch result {
                    case .success(let success):
                        let imageURL = success
                        self?.options(on: flags, video: video, imageURL: imageURL)
                        DispatchQueue.main.async {
                            self?.grabCounter += 1
                            video.progress.current += 1
                        }
                        self?.delegate?.updatedProgress(for: video, isCreated: video.progress.current, on: timecode, by: imageURL)
                    case .failure(let failure):
                        self?.error = failure
                        self?.delegate?.hasError(failure)
                    }
                }
                
                do {
                    try self?.onNextOperation(for: video, flags: flags)
                } catch let error {
                    Crashlytics.crashlytics().record(error: error, userInfo: ["function": #function, "object": type(of: self)])
                    self?.delegate?.hasError(error)
                }
            }
            return grabOperation
        }
        return grabOperations
    }
    
    private func options(on flags: [Flag], video: Video, imageURL: URL) {
        flags.forEach { [weak self] flag in
            switch flag {
            case .autoAddImageGrabbing:
                self?.addImage(to: video, by: imageURL)
            }
        }
    }
    
    private func addImage(to video: Video, by url: URL) {
        video.images.append(url)
    }
    
    private func timecodes(for video: Video) -> [Duration] {
        let shotsCount = video.progress.total
        var timecodes = [Duration]()
        
        for shot in 0..<shotsCount {
            let startTimecode: Duration
            switch video.range {
            case .full:
                startTimecode = .zero
            case .excerpt:
                startTimecode = video.rangeTimecode.lowerBound
            }
            let timecode: Duration = .seconds(startTimecode.seconds + Double(shot) * period)
            timecodes.append(timecode)
        }
        return timecodes
    }
    
    private func onNextOperation(for video: Video, flags: [Flag]) throws {
        if isGrabCompleteForCurrentVideo() {
            self.delegate?.completed(for: video)
            
            if self.isLastVideoFromSession(video: video) {
                self.delegate?.completedAll(grab: grabCounter)
            } else {
                guard let currentIndex = videos.firstIndex(of: video) else { return }
                let nextIndex = videos.index(after: currentIndex)
                guard videos.indices ~= nextIndex else { return }
                let nextId = videos[nextIndex].id
                try self.start(for: nextId, flags: flags)
            }
        }
    }
    
    private func isGrabCompleteForCurrentVideo() -> Bool {
        return self.operationQueue.operationCount == .zero ? true : false
    }
    
    private func isLastVideoFromSession(video: Video) -> Bool {
        return video.id == videos.last?.id || videos.isEmpty
    }
}

extension GrabManager {
    enum Flag {
        case autoAddImageGrabbing
    }
}
