//
//  AbnormalitiesView.swift
//  RemodelAR-Demo
//
//  Copyright © 2021 Passio Inc. All rights reserved.
//

import ARKit
import Combine
import SwiftUI
import RemodelAR

struct AbnormalitiesView: View {
    @EnvironmentObject var settings: SettingsData
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack(alignment: .bottom, content: {
                    arView
                        .edgesIgnoringSafeArea(.all)
                    if settings.uiVisible {
                        viewFinder(cornerRadius: 30)
                        VStack {
                            HStack {
                                savePhotoButton
                                resetSceneButton
                            }
                            if !settings.debugString.isEmpty {
                                debugText
                            }
                            Spacer()
                        }
                        HStack {
                            captureImageButton
                            retrieveAbnormalitiesButton
                        }.offset(y: -80)
                    }
                })
            }.onAppear(perform: {
                setScanArea(geometry: geometry)
                setupBindings()
            })
        }
    }
    
    var arView: some View {
        RemodelARLib.makeARView(model: settings.model, arMethod: .Abnormalities)
    }
    
    var debugText: some View {
        VStack(alignment: .center, spacing: nil, content: {
            Text(settings.debugString)
                .bold()
                .padding(.all)
                .foregroundColor(.white)
                .background(Color(.sRGB, white: 0, opacity: 0.25))
                .cornerRadius(10)
            Spacer()
        })
    }
    
    func showDebugMessage(message: String) {
        settings.debugString = message
        settings.debugTimer?.invalidate()
        settings.debugTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
            settings.debugString = ""
        })
    }
    
    func setupBindings() {
        settings.model.$selectedAbnormality.sink { [self] abnormality in
            guard let abnormality = abnormality else { return }
            settings.model.updateAbnormality(
                abnormality: AbnormalityInfo(identifier: abnormality.identifier,
                                             name: "New Crack")
            )
        }.store(in: &settings.model.cancellables)
        
        settings.model.$capturedAbnormalityImage.sink { [self] capturedImage in
            // Feed image to Passio SDK
            settings.model.addAbnormality(name: "Crack")
        }.store(in: &settings.model.cancellables)
        
        settings.model.$addedAbnormalityId.sink { abnormalityId in
            guard let abnormalityId = abnormalityId
            else { return }
            showDebugMessage(message: "Added abnormality: \(abnormalityId)")
        }.store(in: &settings.model.cancellables)
        
        settings.model.$capturedPhoto.sink { capturedPhoto in
            guard let img = capturedPhoto else { return }
            // Do something with the saved photo
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
        }.store(in: &settings.model.cancellables)
        
        settings.model.$abnormalitiesInfo.sink { abnormalities in
            guard let abnormalities = abnormalities?.abnormalities else { return }
            var output = [String]()
            for abnormality in abnormalities {
                output.append("\(abnormality.identifier), \(abnormality.name), \(abnormality.area.width)x\(abnormality.area.height)")
            }
            showDebugMessage(message: output.joined(separator: "\n"))
        }.store(in: &settings.model.cancellables)
    }
}

private extension AbnormalitiesView {
    var captureImageButton: some View {
        Button(action: {
            settings.model.captureAbnormalityImage()
        }, label: {
            Text("Scan Abnormality")
                .bold()
                .foregroundColor(.black)
        })
        .padding()
        .background(Color.white)
        .cornerRadius(14)
    }
    
    var resetSceneButton: some View {
        Button(action: {
            settings.model.resetScene()
            showDebugMessage(message: "Scene reset!")
        },
               label: {
                Image("reset")
                    .foregroundColor(.white)
               })
        .padding()
        .background(Color(.sRGB, white: 0, opacity: 0.15))
        .cornerRadius(10)
    }
    
    var retrieveAbnormalitiesButton: some View {
        Button(action: {
            settings.model.retrieveAbnormalitiesInfo()
        }, label: {
            Text("Retrieve Abnormalities")
                .bold()
                .foregroundColor(.black)
        })
        .padding()
        .background(Color.white)
        .cornerRadius(14)
    }
    
    var savePhotoButton: some View {
        Button(action: {
            settings.model.savePhoto()
            showDebugMessage(message: "Image Saved!")
        }, label: {
            Image(systemName: "camera.fill")
                .foregroundColor(.white)
        })
        .padding()
        .background(Color(.sRGB, white: 0, opacity: 0.15))
        .cornerRadius(10)
    }
    
    func viewFinder(cornerRadius: CGFloat) -> some View {
        GeometryReader { geometry in
            ZStack {
                viewFinderBackground(geometry: geometry, cornerRadius: cornerRadius)
                viewFinderForeground(geometry: geometry, cornerRadius: cornerRadius)
            }
        }
        .allowsHitTesting(false)
    }
    
    func viewFinderBackground(geometry: GeometryProxy, cornerRadius: CGFloat) -> some View {
        ZStack(alignment: .center) {
            Color(.sRGB, white: 0.25, opacity: 1)
                .edgesIgnoringSafeArea(.all)
            Color.black
                .aspectRatio(1.0, contentMode: .fit)
                .frame(width: geometry.size.width * 2 / 3,
                       alignment: .center)
                .cornerRadius(cornerRadius)
                .clipped()
        }
        .compositingGroup()
        .luminanceToAlpha()
    }
    
    func viewFinderForeground(geometry: GeometryProxy, cornerRadius: CGFloat) -> some View {
        ZStack(alignment: .center) {
            Color(.sRGB, white: 1, opacity: 1)
                .aspectRatio(1.0, contentMode: .fit)
                .frame(width: geometry.size.width * 2 / 3,
                       alignment: .center)
                .cornerRadius(cornerRadius)
            Color(.sRGB, white: 0, opacity: 1)
                .aspectRatio(1.0, contentMode: .fit)
                .frame(width: geometry.size.width * 2 / 3 - 10,
                       alignment: .center)
                .cornerRadius(cornerRadius - 4)
            Color(.sRGB, white: 0, opacity: 1)
                .frame(width: geometry.size.width * 2 / 3,
                       height: geometry.size.width / 4,
                       alignment: .center)
            Color(.sRGB, white: 0, opacity: 1)
                .frame(width: geometry.size.width / 4, height: geometry.size.width * 2 / 3, alignment: .center)
        }
        .compositingGroup()
        .luminanceToAlpha()
    }
}

extension AbnormalitiesView {
    func setScanArea(geometry: GeometryProxy) {
        let viewSize = geometry.frame(in: .global)
        let width: CGFloat = viewSize.size.width * 2 / 3
        let paddingX: CGFloat = (viewSize.size.width - width) / 2 + viewSize.origin.x
        let paddingY: CGFloat = (viewSize.size.height - width) / 2 + viewSize.origin.y
        let cropRect = CGRect(x: paddingX,
                          y: paddingY,
                          width: width,
                          height: width)
        settings.model.setScanArea(rect: cropRect)
    }
}

struct AbnormalitiesView_Previews: PreviewProvider {
    static var previews: some View {
        AbnormalitiesView()
    }
}
