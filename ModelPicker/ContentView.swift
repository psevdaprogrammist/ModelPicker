//
//  ContentView.swift
//  ModelPicker
//
//  Created by Egor Korchagin on 07.08.2020.
//  Copyright © 2020 Egor Korchagin. All rights reserved.
//

import SwiftUI
import RealityKit
import ARKit
import FocusEntity


struct ContentView : View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel: Model?
    @State private var modelConfirmForPlacement: Model?
    
    
    private var models: [Model] = {
        //Dynamically get our model filename
        let filemanager = FileManager.default
        
        guard let path = Bundle.main.resourcePath, let
        files = try?
            filemanager.contentsOfDirectory(atPath: path) else {
                return[]
        }
        
        var avialableModels: [Model] = []
        for filename in files where
            filename.hasSuffix("usdz") {
                let modelName = filename.replacingOccurrences(of: ".usdz", with: "")
                
                let model = Model(modelName: modelName)
                
                avialableModels.append(model)
        }
        return avialableModels
    }()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(modelConfirmForPlacement: self.$modelConfirmForPlacement)
            
            if self.isPlacementEnabled {
                PlacementButtonsView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, modelConfirmForPlacement: self.$modelConfirmForPlacement)
            } else {
                ModelPickerView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, models: self.models)
            }
            //PlacementButtonsView()
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmForPlacement: Model?
    func makeUIView(context: Context) -> ARView {
        
        let arView = CustomARView(frame: .zero)//ARView(frame: .zero)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let model = self.modelConfirmForPlacement {
            
            if let modelEntity = model.modelEntity {
                print("DEBUG: adding model to scene -\(model.modelName)")
                
                let anchorEntity = AnchorEntity(plane: .any)
                anchorEntity.addChild(modelEntity.clone(recursive: true))
                
                uiView.scene.addAnchor(anchorEntity)
            } else {
                print("DEBUG: Unable to load modelEntity for \(model.modelName)")

                
            }
            
                DispatchQueue.main.async {
                self.modelConfirmForPlacement = nil
            }
        }
    }
    
}
    class CustomARView: ARView, FEDelegate {
           let focusSquare = FESquare()
           required init(frame frameRect: CGRect) {
               super.init(frame: frameRect)
               
               focusSquare.viewDelegate = self
               focusSquare.delegate = self
               focusSquare.setAutoUpdate(to: true)
            
                self.setupARView()
           }
        
        @objc required dynamic init?(coder decoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        func setupARView() {
          let config = ARWorldTrackingConfiguration()
          config.planeDetection = [.horizontal, .vertical]
          config.environmentTexturing = .automatic
          
          if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
              config.sceneReconstruction = .mesh
              
          }
          
          self.session.run(config)
        }
    }
    



struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    
    var models: [Model]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 30) {
                    ForEach(0 ..< self.models.count) {
                        index in
                        Button(action: {
                            print("DEBUG: selected model wirh name:\(self.models[index].modelName)")
                            
                            self.selectedModel = self.models[index]
                            
                            self.isPlacementEnabled = true
                        }) {
                            Image(uiImage: self.models[index].image)
                                .resizable()
                                .frame(height: 80)
                                .aspectRatio(1/1,contentMode: .fit)
                                .background(Color.white)
                            .cornerRadius(12)
                        }
                    .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        .padding(20)
            .background(Color.black.opacity(0.5))
    }
}
    
    struct PlacementButtonsView: View {
        @Binding var isPlacementEnabled: Bool
        @Binding var selectedModel: Model?
        @Binding var modelConfirmForPlacement: Model?
        
        var body: some View {
            HStack {
                    // Cancel Button
                    Button(action: {
                        print("DEBUG: Cancel model canceled.")
                        self.resetPlacemenrParameters()
                    }) {
                        Image(systemName: "xmark")
                            .frame(width: 60, height: 60)
                            .font(.title)
                            .background(Color.white.opacity(0.75))
                            .cornerRadius(30)
                            .padding(20)
                    }
                    // Confirm Button
                    Button(action: {
                        print("DEBUG: Model placement confirmed.")
                        
                        self.modelConfirmForPlacement = self.selectedModel
                        
                        self.resetPlacemenrParameters()
                    }) {
                        Image(systemName: "checkmark")
                            .frame(width: 60, height: 60)
                            .font(.title)
                            .background(Color.white.opacity(0.75))
                            .cornerRadius(30)
                            .padding(20)
                }
            }
        }
        
        func resetPlacemenrParameters() {
            self.isPlacementEnabled = false
            self.selectedModel = nil
        }
    }

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
}
