//
//  QRScannerController.swift
//  PayMESDK
//
//  Created by HuyOpen on 11/8/20.
//

import UIKit
import AVFoundation

class QRScannerController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // @IBOutlet var topbar: UIView!
    var imagePicker = UIImagePickerController()
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    weak var shapeLayer: CAShapeLayer?
    
    let getPhoto: UIButton = {
        let button = UIButton()
        let bundle = Bundle(for: QRScannerController.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        button.layer.cornerRadius = 72/2
        button.clipsToBounds = true
        button.backgroundColor = UIColor(28,28,28)
        let image = UIImage(named: "photo", in: resourceBundle, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let flash: UIButton = {
        let button = UIButton()
        let bundle = Bundle(for: QRScannerController.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        button.layer.cornerRadius = 72/2
        button.clipsToBounds = true
        button.backgroundColor = UIColor(28,28,28)
        let image = UIImage(named: "flash", in: resourceBundle, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let titleChoiceButton : UIButton = {
        let button = UIButton()
        button.setTitle("Chọn ảnh", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let titleToggleFlash : UIButton = {
        let button = UIButton()
        button.setTitle("Bật flash", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var onScanSuccess: ((String) -> ())? = nil
    private var onScanFail: ((String) -> ())? = nil
   
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                     AVMetadataObject.ObjectType.code39,
                                     AVMetadataObject.ObjectType.code39Mod43,
                                     AVMetadataObject.ObjectType.code93,
                                     AVMetadataObject.ObjectType.code128,
                                     AVMetadataObject.ObjectType.ean8,
                                     AVMetadataObject.ObjectType.ean13,
                                     AVMetadataObject.ObjectType.aztec,
                                     AVMetadataObject.ObjectType.pdf417,
                                     AVMetadataObject.ObjectType.itf14,
                                     AVMetadataObject.ObjectType.dataMatrix,
                                     AVMetadataObject.ObjectType.interleaved2of5,
                                     AVMetadataObject.ObjectType.qr]
    
   let backButton: UIButton = {
       let button = UIButton()
       let bundle = Bundle(for: QRScannerController.self)
       let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
       let resourceBundle = Bundle(url: bundleURL!)
       let image = UIImage(named: "previous", in: resourceBundle, compatibleWith: nil)?.resizeWithWidth(width: 16)
       button.setImage(image, for: .normal)
       button.translatesAutoresizingMaskIntoConstraints = false
       return button
   }()
   
   let logoPayME: UIImageView = {
       let bundle = Bundle(for: QRScannerController.self)
       let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
       let resourceBundle = Bundle(url: bundleURL!)
       let image = UIImage(named: "iconPayme", in: resourceBundle, compatibleWith: nil)?.resizeWithWidth(width: 32)
       var bgImage = UIImageView(image: image)
       bgImage.isHidden = true
       bgImage.translatesAutoresizingMaskIntoConstraints = false
       return bgImage
   }()
    public func setScanSuccess(onScanSuccess: @escaping (String) -> ()) {
        self.onScanSuccess = onScanSuccess
    }
    public func setScanFail(onScanFail: @escaping (String) -> ()){
        self.onScanFail = onScanFail
    }
    
    @objc func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { return }
        do {
            try device.lockForConfiguration()

            if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                device.torchMode = AVCaptureDevice.TorchMode.off
            } else {
                do {
                    try device.setTorchModeOn(level: 1.0)
                } catch {
                    print(error)
                }
            }
            device.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
    
    @objc func choiceImage() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
            let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!

        let ciImage:CIImage = CIImage(image:pickedImage)!

        var qrCodeLink = ""

            let features=detector.features(in: ciImage)

        for feature in features as! [CIQRCodeFeature] {

            qrCodeLink += feature.messageString!
        }
        launchApp(decodedURL:qrCodeLink)
        }
        dismiss(animated: true, completion: nil)
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(backButton)
        view.addSubview(logoPayME)
        view.addSubview(getPhoto)
        view.addSubview(flash)
        view.addSubview(titleChoiceButton)
        view.addSubview(titleToggleFlash)
        // Get the back-facing camera for capturing videos
        if let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) {
        
        if(captureDevice.isFocusModeSupported(.continuousAutoFocus)) {
            try! captureDevice.lockForConfiguration()
            captureDevice.focusMode = .continuousAutoFocus
            captureDevice.unlockForConfiguration()
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
//            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        }
        
        
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        if #available(iOS 11, *) {
          let guide = view.safeAreaLayoutGuide
          NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
            getPhoto.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -40),
            flash.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -40)
           ])
        } else {
           let standardSpacing: CGFloat = 8.0
           NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing),
            getPhoto.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -40),
            flash.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -40)
           ])
        }
        
        backButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        
        getPhoto.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        getPhoto.widthAnchor.constraint(equalToConstant: 72).isActive = true
        getPhoto.heightAnchor.constraint(equalToConstant: 72).isActive = true

        flash.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        flash.widthAnchor.constraint(equalToConstant: 72).isActive = true
        flash.heightAnchor.constraint(equalToConstant: 72).isActive = true
        
        titleChoiceButton.centerXAnchor.constraint(equalTo: getPhoto.centerXAnchor).isActive = true
        titleChoiceButton.topAnchor.constraint(equalTo: getPhoto.bottomAnchor).isActive = true
        
        titleToggleFlash.centerXAnchor.constraint(equalTo: flash.centerXAnchor).isActive = true
        titleToggleFlash.topAnchor.constraint(equalTo: flash.bottomAnchor).isActive = true
        
        backButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        // Move the message label and top bar to the front
        view.bringSubviewToFront(backButton)
        view.bringSubviewToFront(logoPayME)
        view.bringSubviewToFront(getPhoto)
        view.bringSubviewToFront(flash)
        view.bringSubviewToFront(titleChoiceButton)
        view.bringSubviewToFront(titleToggleFlash)

        self.shapeLayer?.removeFromSuperlayer()

        // create whatever path you want

        let path = UIBezierPath()
        path.move(to: CGPoint(x: self.view.frame.minX + 30, y: (self.view.frame.maxY / 2) - 100))
        path.addLine(to: CGPoint(x: self.view.frame.maxX - 30, y: (self.view.frame.maxY / 2) - 100))

        // create shape layer for that path

        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        shapeLayer.strokeColor = UIColor(8,148,31).cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.path = path.cgPath
        view.layer.addSublayer(shapeLayer)
        
        let animationDown = CABasicAnimation(keyPath: "position")
        animationDown.fromValue = shapeLayer.position
        animationDown.toValue = CGPoint(x: shapeLayer.position.x, y: shapeLayer.position.y + 150)
        animationDown.duration = 2
        shapeLayer.position = CGPoint(x: shapeLayer.position.x, y: shapeLayer.position.y + 150)
        animationDown.autoreverses = true
        animationDown.repeatCount = .infinity

        shapeLayer.add(animationDown, forKey: "test")
        
        self.shapeLayer = shapeLayer
        qrCodeFrameView = UIView()
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        getPhoto.addTarget(self, action: #selector(choiceImage), for: .touchUpInside)
        flash.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        
        
        if let qrCodeFrameView = qrCodeFrameView {
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func back () {
        navigationController?.popViewController(animated: true)
    }
    // MARK: - Helper methods
    func launchApp(decodedURL: String) {
        self.onScanSuccess!(decodedURL)
        self.navigationController?.popViewController(animated: true)
    }
  private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
    layer.videoOrientation = orientation
    videoPreviewLayer?.frame = self.view.bounds
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    if let connection =  self.videoPreviewLayer?.connection  {
      let currentDevice: UIDevice = UIDevice.current
      let orientation: UIDeviceOrientation = currentDevice.orientation
      let previewLayerConnection : AVCaptureConnection = connection
      
      if previewLayerConnection.isVideoOrientationSupported {
        switch (orientation) {
        case .portrait:
          updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
          break
        case .landscapeRight:
          updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
          break
        case .landscapeLeft:
          updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
          break
        case .portraitUpsideDown:
          updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
          break
        default:
          updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
          break
        }
      }
    }
  }
}

extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            logoPayME.frame = CGRect.zero
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            logoPayME.isHidden = false
            logoPayME.centerXAnchor.constraint(equalTo: qrCodeFrameView!.centerXAnchor).isActive = true
            logoPayME.centerYAnchor.constraint(equalTo: qrCodeFrameView!.centerYAnchor).isActive = true
            
            if metadataObj.stringValue != nil {
                self.captureSession.stopRunning()
                launchApp(decodedURL: metadataObj.stringValue!)
            }
        }
    }
    
}

