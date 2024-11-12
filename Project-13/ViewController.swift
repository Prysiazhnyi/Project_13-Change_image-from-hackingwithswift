//
//  ViewController.swift
//  Project-13
//
//  Created by Serhii Prysiazhnyi on 11.11.2024.
//

import UIKit
import CoreImage
var context: CIContext!
var currentFilter: CIFilter!

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!
    @IBOutlet var changeFilterButton: UIButton!
    
    var currentImage: UIImage!
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Instafilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }

    @IBAction func changeFilter(_ sender: Any) {
        
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
           ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
           ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
           ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
           ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
           ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
           ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
           ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
           ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
           present(ac, animated: true)
        
    }
    
    @IBAction func save(_ sender: Any) {
        guard let image = imageView.image else {
            let ac = UIAlertController(title: "Save error", message: "No image to save", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }

         UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
     }
    
    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        dismiss(animated: true)

        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)

        applyProcessing()
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys

        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey) }
        if inputKeys.contains(kCIInputCenterKey) { currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey) }

        if let outputImage = currentFilter.outputImage,
               let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                let processedImage = UIImage(cgImage: cgimg)
                imageView.image = processedImage
        }
    }
    
    func setFilter(action: UIAlertAction) {
        // Убеждаемся, что изображение выбрано
        guard currentImage != nil else { return }

        // Получаем название выбранного фильтра
        guard let actionTitle = action.title else { return }

        // Устанавливаем фильтр
        currentFilter = CIFilter(name: actionTitle)

        // Присваиваем изображение для фильтра
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)

        // Применяем обработку изображения
        applyProcessing()
        
        // Изменяем название кнопки `changeFilterButton`
        changeFilterButton.setTitle(actionTitle, for: .normal)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}

