//
//  TechDemoView.swift
//  Painty
//
//  Created by Davido Hyer on 12/13/21.
//

import ARKit
import Combine
import SwiftUI
import RemodelAR

final class SettingsData: ObservableObject {
    @Published var uiVisible = true
    @Published var tabSwitchingActive = true
    @Published var debugString = ""
    @Published var debugTimer: Timer?
    @Republished var model = ARStateModel()
}

struct TechDemoView: View {
    @State var currentTab = 0
    @StateObject var settings = SettingsData()
    
    var body: some View {
        ZStack {
            if currentTab == 0 {
                if supportsLidar {
                    LidarView()
                } else {
                    Color.white
                        .edgesIgnoringSafeArea(.all)
                    Text("Lidar not supported on this device")
                        .foregroundColor(.black)
                }
            } else if currentTab == 1 {
                LegacyView()
            } else if currentTab == 2 {
                ShaderPaintView()
            } else if currentTab == 3 {
                AbnormalitiesView()
            }
            if settings.uiVisible {
                VStack {
                    Spacer()
                    viewModePicker
                }
            }
            VStack {
                HStack {
                    Spacer()
                    uiVisibleButton
                        .padding(.trailing, 10)
                }
                Spacer()
            }
        }
        .environmentObject(settings)
    }
    
    var supportsLidar: Bool {
        ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
    }
    
    var uiVisibleButton: some View {
        Button(action: {
            settings.uiVisible.toggle()
        }, label: {
            Image(systemName: settings.uiVisible ? "eye.fill" : "eye.slash.fill")
                .foregroundColor(.white)
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
    }
    
    var viewModePicker: some View {
        let modes = ["Lidar", "Legacy", "Shader", "Defects"]
        return HStack(spacing: 5) {
            ForEach(0..<modes.count, id: \.self) {
                let index = $0
                let mode = modes[index]
                Button(action: {
                    currentTab = index
                    settings.tabSwitchingActive = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        settings.tabSwitchingActive = true
                    }
                },
                       label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 17)
                            .strokeBorder(lineWidth: index == currentTab ? 2 : 0)
                            .background(
                                VStack(spacing: 3) {
                                    Image("\(modes[index].lowercased())")
                                    Text("\(mode)")
                                        .fontWeight(.bold)
                                        .font(.system(size: 16))
                                }
                            )
                            .foregroundColor(settings.tabSwitchingActive ? .white : .gray)
                            .background(Color(.sRGB, white: 0, opacity: currentTab == index ? 0.75 : 0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 17))
                            .frame(height: 60)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .animation(Animation.interpolatingSpring(stiffness: 60, damping: 15))

                    }
                })
            }
        }
        .padding([.leading, .trailing], 10)
        .disabled(!settings.tabSwitchingActive)
    }
}

struct TechDemoView_Previews: PreviewProvider {
    static var previews: some View {
        TechDemoView()
    }
}
