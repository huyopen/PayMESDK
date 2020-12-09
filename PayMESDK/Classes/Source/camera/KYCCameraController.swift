//
//  KYCCameraController.swift
//  PayMESDK
//
//  Created by HuyOpen on 11/23/20.
//

import Foundation
import UIKit
import AVFoundation
class KYCCameraController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let session = AVCaptureSession()
    var camera : AVCaptureDevice?
    var imagePicker = UIImagePickerController()
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    var cameraCaptureOutput : AVCapturePhotoOutput?
    let screenSize:CGRect = UIScreen.main.bounds
    weak var shapeLayer_topLeft: CAShapeLayer?
    weak var shapeLayer_topRight: CAShapeLayer?
    weak var shapeLayer_bottomLeft: CAShapeLayer?
    weak var shapeLayer_bottomRight: CAShapeLayer?
    private var onSuccessCapture: ((UIImage) -> ())? = nil
    private var onBack: ((String) -> ())? = nil
    public var txtFront = ""
    public var imageFront : UIImage?
    
    let getPhoto: UIButton = {
        let button = UIButton()
        let bundle = Bundle(for: QRScannerController.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let image = UIImage(named: "photo", in: resourceBundle, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let titleButton : UIButton = {
        let button = UIButton()
        button.setTitle("Chọn hình", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc func choiceImage() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage else { return }
        dismiss(animated: true, completion: nil)
        self.onSuccessCapture!(image)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(pressCamera)
        view.addSubview(guideLabel)
        view.addSubview(choiceDocumentType)
        view.addSubview(frontSide)
        view.addSubview(getPhoto)
        view.addSubview(titleButton)
        
        initializeCaptureSession()
        if #available(iOS 11, *) {
          let guide = view.safeAreaLayoutGuide
          NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.3),
            getPhoto.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -45),
            pressCamera.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -18)
           ])
        } else {
           let standardSpacing: CGFloat = 8.0
           NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing),
            titleLabel.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing+5),
            getPhoto.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -40),
            pressCamera.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -standardSpacing)
           ])
        }
        backButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        choiceDocumentType.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
        choiceDocumentType.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 37).isActive = true
        choiceDocumentType.heightAnchor.constraint(equalToConstant: 30).isActive = true

        getPhoto.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        getPhoto.widthAnchor.constraint(equalToConstant: 32).isActive = true
        getPhoto.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        pressCamera.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pressCamera.widthAnchor.constraint(equalToConstant: 80).isActive = true
        pressCamera.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        titleLabel.text = "Chụp ảnh giấy tờ"
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        frontSide.text = self.txtFront
        frontSide.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 44).isActive = true
        frontSide.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true

        guideLabel.text = "Vui lòng cân chỉnh giấy tờ tùy thân vào giữa khung"
        guideLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        guideLabel.topAnchor.constraint(equalTo: choiceDocumentType.bottomAnchor, constant: (self.cameraPreviewLayer?.bounds.height ?? (screenSize.width-32) * 0.67) + 60).isActive = true
        guideLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        
        titleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        titleButton.topAnchor.constraint(equalTo: getPhoto.bottomAnchor).isActive = true

        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        pressCamera.addTarget(self, action: #selector(takePicture), for: .touchUpInside)
        choiceDocumentType.addTarget(self, action: #selector(choiceDocument), for: .touchUpInside)
        getPhoto.addTarget(self, action: #selector(choiceImage), for: .touchUpInside)
        titleButton.addTarget(self, action: #selector(choiceImage), for: .touchUpInside)
        view.bringSubviewToFront(backButton)
        if (self.imageFront != nil) {
            self.txtFront = "Mặt sau"
            choiceDocumentType.isHidden = true
        } else {
            self.txtFront = "Mặt trước"
        }
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    public func setSuccessCapture(onSuccessCapture: @escaping (UIImage) -> ()){
        self.onSuccessCapture = onSuccessCapture
    }
    public func setOnBack(onBack: @escaping (String) -> ()){
        self.onBack = onBack
    }
    
    
    @objc func choiceDocument() {
        self.presentPanModal(KYCDocumentController())

    }
    
    @objc func back () {
        navigationController?.popViewController(animated: true)

    }
    @objc func takePicture() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        cameraCaptureOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    
    let backButton: UIButton = {
        let button = UIButton()
        let bundle = Bundle(for: KYCCameraController.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let image = UIImage(named: "previous", in: resourceBundle, compatibleWith: nil)?.resizeWithWidth(width: 16)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let pressCamera: UIButton = {
        let button = UIButton()
        let bundle = Bundle(for: KYCCameraController.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let image = UIImage(named: "takepicBtn", in: resourceBundle, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor(255,255,255)
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let guideLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor(255,255,255)
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let frontSide : UILabel = {
        let label = UILabel()
        label.textColor = UIColor(230,230,230)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let choiceDocumentType: UIButton = {
        let button = UIButton()
        let bundle = Bundle(for: KYCCameraController.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let image = UIImage(named: "24Px", in: resourceBundle, compatibleWith: nil)
        button.setTitle("Chứng minh nhân dân", for: .normal)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleEdgeInsets = UIEdgeInsets(top:0, left: -30, bottom:0, right:0) //adjust insets to have fit how you want
        button.imageEdgeInsets = UIEdgeInsets(top:0, left: 185, bottom:0, right: 0) //adjust these to have fit right
        return button
    }()
    
    func displayCapturedPhoto(capturedPhoto : UIImage) {
        /*
        let imagePreviewViewController = storyboard?.instantiateViewController(withIdentifier: "ImagePreviewViewController") as! ImagePreviewViewController
        imagePreviewViewController.capturedImage = capturedPhoto
        navigationController?.pushViewController(imagePreviewViewController, animated: true)
        */
    }
    
    func initializeCaptureSession() {
        
        session.sessionPreset = AVCaptureSession.Preset.high
        guard let camera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        do {
            let cameraCaptureInput = try AVCaptureDeviceInput(device: camera)
            cameraCaptureOutput = AVCapturePhotoOutput()
            session.addInput(cameraCaptureInput)
            session.addOutput(cameraCaptureOutput!)
            cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            cameraPreviewLayer?.frame = CGRect(x: 16, y: 160, width: screenSize.width - 32, height: (screenSize.width-32) * 0.67)
            cameraPreviewLayer?.masksToBounds = true
            cameraPreviewLayer?.cornerRadius = 15


            cameraPreviewLayer?.connection!.videoOrientation = AVCaptureVideoOrientation.portrait
            
            view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
            
            var path = UIBezierPath()
            path.move(to: CGPoint(x: self.cameraPreviewLayer!.frame.minX + 40, y: self.cameraPreviewLayer!.frame.minY))
            path.addLine(to: CGPoint(x: self.cameraPreviewLayer!.frame.minX, y: self.cameraPreviewLayer!.frame.minY))
            path.addLine(to: CGPoint(x: self.cameraPreviewLayer!.frame.minX, y: self.cameraPreviewLayer!.frame.minY + 40))
            
            var shapeLayer = CAShapeLayer()
            shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
            shapeLayer.strokeColor = UIColor(255,255,255).cgColor
            shapeLayer.lineWidth = 4
            shapeLayer.path = path.cgPath
            view.layer.addSublayer(shapeLayer)
            self.shapeLayer_topLeft = shapeLayer
            
            path = UIBezierPath()
            path.move(to: CGPoint(x: self.cameraPreviewLayer!.frame.maxX - 40, y: self.cameraPreviewLayer!.frame.minY))
            path.addLine(to: CGPoint(x: self.cameraPreviewLayer!.frame.maxX, y: self.cameraPreviewLayer!.frame.minY))
            path.addLine(to: CGPoint(x: self.cameraPreviewLayer!.frame.maxX, y: self.cameraPreviewLayer!.frame.minY + 40))
            shapeLayer = CAShapeLayer()
            shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
            shapeLayer.strokeColor = UIColor(255,255,255).cgColor
            shapeLayer.lineWidth = 4
            shapeLayer.path = path.cgPath
            view.layer.addSublayer(shapeLayer)
            self.shapeLayer_topRight = shapeLayer
            
            path = UIBezierPath()
            path.move(to: CGPoint(x: self.cameraPreviewLayer!.frame.minX + 40, y: self.cameraPreviewLayer!.frame.maxY))
            path.addLine(to: CGPoint(x: self.cameraPreviewLayer!.frame.minX, y: self.cameraPreviewLayer!.frame.maxY))
            path.addLine(to: CGPoint(x: self.cameraPreviewLayer!.frame.minX, y: self.cameraPreviewLayer!.frame.maxY - 40))
            shapeLayer = CAShapeLayer()
            shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
            shapeLayer.strokeColor = UIColor(255,255,255).cgColor
            shapeLayer.lineWidth = 4
            shapeLayer.path = path.cgPath
            view.layer.addSublayer(shapeLayer)
            self.shapeLayer_bottomLeft = shapeLayer
            
            path = UIBezierPath()
            path.move(to: CGPoint(x: self.cameraPreviewLayer!.frame.maxX - 40, y: self.cameraPreviewLayer!.frame.maxY))
            path.addLine(to: CGPoint(x: self.cameraPreviewLayer!.frame.maxX, y: self.cameraPreviewLayer!.frame.maxY))
            path.addLine(to: CGPoint(x: self.cameraPreviewLayer!.frame.maxX, y: self.cameraPreviewLayer!.frame.maxY - 40))
            shapeLayer = CAShapeLayer()
            shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
            shapeLayer.strokeColor = UIColor(255,255,255).cgColor
            shapeLayer.lineWidth = 4
            shapeLayer.path = path.cgPath
            view.layer.addSublayer(shapeLayer)
            self.shapeLayer_bottomRight = shapeLayer
            
            session.startRunning()
        } catch {
            print(error.localizedDescription)
        }
        
        
    }
    
}

extension KYCCameraController : AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let sampleBuffer = photoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
        {
            let image : UIImage = UIImage(data: dataImage)!

            let originalSize : CGSize
            let visibleLayerFrame = self.cameraPreviewLayer!.bounds // THE ACTUAL VISIBLE AREA IN THE LAYER FRAME

            // Calculate the fractional size that is shown in the preview
            let metaRect : CGRect = (self.cameraPreviewLayer?.metadataOutputRectConverted(fromLayerRect: visibleLayerFrame))!
            if (image.imageOrientation == UIImage.Orientation.left || image.imageOrientation == UIImage.Orientation.right) {
                // For these images (which are portrait), swap the size of the
                // image, because here the output image is actually rotated
                // relative to what you see on screen.
                originalSize = CGSize(width: image.size.height, height: image.size.width)
            }
            else {
                originalSize = image.size
            }

            // metaRect is fractional, that's why we multiply here.
            let cropRect : CGRect = CGRect( x: metaRect.origin.x * originalSize.width,
                                            y: metaRect.origin.y * originalSize.height,
                                            width: metaRect.size.width * originalSize.width,
                                            height: metaRect.size.height * originalSize.height).integral
            let finalImage : UIImage =
            UIImage(cgImage: image.cgImage!.cropping(to: cropRect)!,
                scale:1,
                orientation: image.imageOrientation )
            let resizeImage = finalImage.resizeImage(targetSize: CGSize(width:512, height: 512*0.67))
            self.onSuccessCapture!(resizeImage)
        }
    }
}

