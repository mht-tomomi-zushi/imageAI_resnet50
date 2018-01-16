//
//  ViewController.swift
//  ImageAI
//
//  Created by 図師ともみ on 2018/01/14.
//  Copyright © 2018年 おいもファクトリー. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var photoInfoDisplayTextView: UITextView!
    @IBOutlet weak var photoDisplayImageView: UIImageView!
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func takePhoto(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        photoDisplayImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imagePicker.dismiss(animated: true, completion: nil)
        imageinference(image: (info[UIImagePickerControllerOriginalImage] as? UIImage)!)
    }
    
    func imageinference(image: UIImage) {
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
            fatalError("モデルをロードできません")
        }
        
        let request = VNCoreMLRequest(model: model) {
            [weak self] request, error in
            
            guard let results = request.results as? [VNClassificationObservation],
                let firstResult = results.first else {
                    fatalError("判別ができません")
            }

            DispatchQueue.main.async {
                self?.photoInfoDisplayTextView.text = "確率 = \(Int(firstResult.confidence * 100))% \n\n解析結果\n \((firstResult.identifier))"
            }

        }
        
        guard let ciImage = CIImage(image: image) else { fatalError("画像変換できまへん") }
        
        let imageHandler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try imageHandler.perform([request])
            } catch {
                print("エラー \(error)!")
            }
        }
    }
}

