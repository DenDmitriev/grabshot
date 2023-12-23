//
//  VideoGallery.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 09.09.2023.
//

import SwiftUI

struct VideoGallery: View {
    
    @State private var itemSize: CGFloat = AppGrid.pt192
    @EnvironmentObject var videoStore: VideoStore
    @ObservedObject var viewModel: VideosModel
    @Binding var selection: Set<Video.ID>
    @Binding var state: GrabState
    @Binding var sortOrder: [KeyPathComparator<Video>]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .leading, spacing: AppGrid.pt8) {
                ForEach(videos) { video in
                    VideoGalleryVideoItem(video: video, size: itemSize, selection: $selection, state: $state)
                        .environmentObject(viewModel)
                        .contextMenu {
                            ItemVideoContextMenu(video: video, selection: $selection)
                                .environmentObject(viewModel)
                        }
                        .onTapGesture {
                            didSelect(video: video)
                        }
                }
            }
            .padding(AppGrid.pt12)
        }
        .onTapGesture {
            selection.removeAll()
        }
        .background(AnyShapeStyle(.bar))
        .cornerRadius(AppGrid.pt8)
        .contextMenu {
            VideosContextMenu(selection: $selection)
        }
    }
    
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: itemSize, maximum: itemSize), spacing: AppGrid.pt8)]
    }
    
    private func didSelect(video: Video) {
        switch NSEvent.modifierFlags {
        case .command:
            selection.insert(video.id)
        case .shift:
            let from = selection.first
            let to = video.id
            guard let fromIndex = videos.firstIndex(where: { $0.id == from }),
            let toIndex = videos.firstIndex(where: { $0.id == to })
            else { return }
            var willSelectVideos: [Video] = []
            if fromIndex < toIndex {
                willSelectVideos = Array(videos[fromIndex...toIndex])
            } else if fromIndex > toIndex {
                willSelectVideos = Array(videos[toIndex...fromIndex])
            } else {
                return
            }
            selection = Set(willSelectVideos.map({ $0.id }))
        default:
            selection = [video.id]
        }
    }
}

struct VideoGallery_Previews: PreviewProvider {
    static var previews: some View {
        let video: Video = .placeholder
        let store: VideoStore = {
            let store = VideoStore()
            store.videos = [video]
            return store
        }()
        let scoreController = ScoreController(caretaker: Caretaker())
        let selection: Set<Video.ID> = [video.id]
        
        VideoGallery(
            viewModel: VideosModel(),
            selection: .constant(selection),
            state: .constant(.ready),
            sortOrder: .constant([KeyPathComparator<Video>(\.title, order: SortOrder.forward)])
        )
        .previewLayout(.fixed(width: AppGrid.pt500, height: AppGrid.pt300))
        .environmentObject(store)
        .environmentObject(GrabBuilder.build(store: store, score: scoreController, coordinator: GrabCoordinator(videoStore: store, scoreController: scoreController)))
    }
}

extension VideoGallery {
    var videos: [Video] {
        return videoStore.sortedVideos
    }
}
