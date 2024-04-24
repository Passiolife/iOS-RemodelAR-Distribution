//
//  AbnormalitiesView.swift
//  Painty
//
//  Copyright © 2022 Passio Inc. All rights reserved.
//

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
                            scanModeButton
                            Spacer()
                        }.padding([.top], 40)
                        VStack {
                            Spacer()
                            HStack {
                                captureImageButton
                                retrieveAbnormalitiesButton
                            }
                        }.padding([.bottom], 100)
                    }
                })
            }.onAppear(perform: {
                DispatchQueue.main.asyncAfter(deadline: .now() + settings.contextSwitchDelay) {
                    settings.reset()
                    setScanArea(geometry: geometry)
                    settings.model.startScene()
                    setupBindings()
                }
            })
        }
    }

    var arView: some View {
        RemodelARLib.makeARView(model: settings.model, arMethod: .Abnormalities)
    }

    func setupBindings() {
        settings.model.selectedAbnormality.sink { [self] abnormality in
            guard let abnormality = abnormality else { return }
            settings.model.updateAbnormality(
                abnormality:
                    AbnormalityInfo(identifier: abnormality.identifier,
                                    name: "New Crack")
            )
        }.store(in: &settings.model.cancellables)
        settings.model.capturedAbnormalityImage.sink { [self] _ in
            // Feed image to Passio SDK
            settings.model.addAbnormality(name: "Crack")
        }.store(in: &settings.model.cancellables)

        settings.model.addedAbnormalityId.sink { abnormalityId in
            guard let abnormalityId = abnormalityId
            else { return }
            print("Added abnormality: \(abnormalityId)")
        }.store(in: &settings.model.cancellables)

        settings.model.capturedPhoto.sink { capturedPhoto in
            guard let img = capturedPhoto else { return }
            // Do something with the saved photo
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
        }.store(in: &settings.model.cancellables)

        settings.model.abnormalitiesInfo.sink { abnormalities in
            guard let abnormalities = abnormalities?.abnormalities else { return }
            for abnormality in abnormalities {
                print("\(abnormality.identifier), \(abnormality.name), \(abnormality.area.width)x\(abnormality.area.height)")
            }
        }.store(in: &settings.model.cancellables)
    }

    var scanModeButton: some View {
        Button(action: {
            switch settings.scanMode {
            case .scanning:
                settings.model.stopLidarScan()
                settings.scanMode = .paused

            case .paused:
                settings.model.startLidarScan()
                settings.scanMode = .scanning
            }
        },
               label: {
            Text(settings.scanMode == .scanning ? "Pause Lidar" : "Start Lidar")
                .bold()
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
            settings.reset()
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
        }, label: {
            Image(systemName: "camera.fill")
                .foregroundColor(.white)
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
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
