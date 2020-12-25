//
//  Model.swift
//  ModelPicker
//
//  Created by Egor Korchagin on 08.08.2020.
//  Copyright © 2020 Egor Korchagin. All rights reserved.
//

import UIKit
import RealityKit
import Combine


class Model  {
    var modelName: String
    var image: UIImage
    var modelEntity: ModelEntity?
    
    private var cancellable: AnyCancellable? = nil
    
    init(modelName: String) {
        self.modelName = modelName
        
        self.image = UIImage(named: modelName)!
        
        let fileName = modelName + ".usdz"
        self.cancellable = ModelEntity.loadModelAsync(named: fileName).sink(receiveCompletion: { (loadCompletion) in
            //Handle our error
            print("DEBUG: Unable to load modelEntity for modelName: \(self.modelName)")
        }, receiveValue: { modelEntity in
            //Get our modelEntity
            self.modelEntity = modelEntity
            print("DEBUG: Successfully loaded modelEntity for modelName: \(self.modelName) ")
        })
        
        
    }
}
