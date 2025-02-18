//
//  SettingsList.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.12.2022.
//

import SwiftUI

struct SettingsList: View {
    
    @StateObject var viewModel: SettingsModel
    @State var showAlert: Bool = false
    @State var message: String? = nil
    
    @State private var selection: Int?
    
    var body: some View {
        NavigationView {
            List(selection: $selection) {
                NavigationLink(destination: SettingsGeneralView(showAlert: $showAlert, message: $message)) {
                    Text("General")
                }
                .tag(0)
                
                NavigationLink(destination: SettingsGrabView()) {
                    Text("Video")
                }
                .tag(1)

                NavigationLink(destination: SettingsImageStripView()) {
                    Text("Image")
                }
                .tag(2)
                
                NavigationLink(destination: SettingsStripView()) {
                    Text("Strip")
                }
                .tag(3)
            }
            .onAppear() {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.selection = .zero
                }
            }
            
            Text("Select menu")
        }
        .alert(message ?? "Alert", isPresented: $showAlert, actions: {
            Button("OK", action: {})
        })
        .environmentObject(viewModel)
        .frame(minWidth: AppGrid.pt512, minHeight: AppGrid.pt300)
    }
    
}

struct SettingsList_Previews: PreviewProvider {
    static var previews: some View {
        SettingsList(viewModel: SettingsModel())
    }
}
