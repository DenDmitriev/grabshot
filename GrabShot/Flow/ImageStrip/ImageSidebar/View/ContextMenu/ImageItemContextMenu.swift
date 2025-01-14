//
//  ImageItemContextMenu.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 17.09.2023.
//

import SwiftUI

struct ImageItemContextMenu: View {
    
    @EnvironmentObject var coordinator: ImageStripCoordinator
    @EnvironmentObject var item: ImageStrip
    @EnvironmentObject var viewModel: ImageSidebarModel
    @Binding var selectedItemIds: Set<ImageStrip.ID>
    @Binding var export: ExportImages
    @Binding var showFileExporter: Bool
    
    var body: some View {
        Button("Export selected") {
            if !selectedItemIds.contains(item.id) {
                export = .context(id: item.id)
                showFileExporter.toggle()
            } else {
                export = .selected
                showFileExporter.toggle()
            }
        }
        
        Divider()
        
        Button("Show in Finder", action: { showInFinder(url: item.url) })
        
        Divider()
        
        Button("Delete", role: .destructive) {
            if !selectedItemIds.contains(item.id) {
                delete(ids: [item.id])
            } else {
                delete(ids: selectedItemIds)
            }
        }
    }
    
    private func showInFinder(url: URL?) {
        guard let url else { return }
        coordinator.openFile(by: url)
    }
    
    private func delete(ids: Set<ImageStrip.ID>) {
        withAnimation {
            viewModel.delete(ids: ids)
            ids.forEach { id in
                selectedItemIds.remove(id)
            }
        }
    }
}
