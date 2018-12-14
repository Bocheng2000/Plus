//
//  QRScaneViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/26.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit
import AVFoundation

class QRScaneViewController: FatherViewController, AVCaptureMetadataOutputObjectsDelegate, TZImagePickerControllerDelegate {
    private var session:AVCaptureSession!
    private var lineImageView: UIImageView!
    @IBOutlet weak var tipLabel: UILabel!
    private var runAnimate: Bool = true
    @IBOutlet weak var heightConst: NSLayoutConstraint!
    open var scanFinish: ((String) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
        checkPermission()
    }
    
    //MARK: ==== 检测权限 ========
    private func checkPermission() {
        let helper = PermissionHelper()
        helper.checkCameraIsAllow { [weak self] (isAllow) in
            if isAllow {
                self?.session.startRunning()
                self?.startAnimate()
            } else {
                let title = LanguageHelper.localizedString(key: "UnableScan")
                let msg = LanguageHelper.localizedString(key: "OpenCameraPermission")
                self?.presentAlert(title: title, msg: msg, helper: helper)
            }
        }
    }
    
    private func presentAlert(title: String, msg: String, helper: PermissionHelper) {
        let alert = JCAlertController.alert(withTitle: title, message: msg)
        alert?.addButton(withTitle: LanguageHelper.localizedString(key: "Cancel"), type: JCButtonType(rawValue: 0), clicked: nil)
        alert?.addButton(withTitle: LanguageHelper.localizedString(key: "Go"), type: JCButtonType(rawValue: 0), clicked: {
            helper.toAppSetting()
        })
        present(alert!, animated: true, completion: nil)
    }
    
    private func makeUI() {
        navBar?.setBorderLine(position: .bottom, number: 0.5, color: BORDER_COLOR)
        setCamera()
        lineImageView = UIImageView(frame: CGRect(x: 50, y: (kSize.height - (kSize.width - 100)) / 2 + 44, width: kSize.width - 100, height: 10))
        lineImageView.image = UIImage(named: "QRScanLine")
        view.addSubview(lineImageView)
        let title = LanguageHelper.localizedString(key: "PutQRInArea")
        let size = title.getTextSize(font: tipLabel.font, lineHeight: 0, maxSize: CGSize(width: kSize.width - 100, height: CGFloat(MAXFLOAT)))
        tipLabel.text = title
        heightConst.constant = size.height
        tipLabel.setNeedsLayout()
        tipLabel.layoutIfNeeded()
    }
    
    func setCamera(){
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            return
        }
        do {
            let input =  try AVCaptureDeviceInput(device: device)
            let output = AVCaptureMetadataOutput()
            session = AVCaptureSession()
            if session.canAddInput(input){
                session.addInput(input)
            }
            if session.canAddOutput(output){
               session.addOutput(output)
               output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
               output.metadataObjectTypes = [ AVMetadataObject.ObjectType.qr]
               let rect = CGRect(x: 50, y: (kSize.height - (kSize.width - 100)) / 2 + 44, width: kSize.width - 100, height: kSize.width - 100)
               output.rectOfInterest = CGRect(x: rect.origin.y / kSize.height, y: rect.origin.x / kSize.width, width: rect.size.height / kSize.height, height: rect.size.width / kSize.width)
            }
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = self.view.layer.bounds
            self.view.layer.insertSublayer(previewLayer, at: 0)
            if device.isFocusModeSupported(.continuousAutoFocus){
                try input.device.lockForConfiguration()
                input.device.focusMode = .continuousAutoFocus
                input.device.unlockForConfiguration()
            }
        } catch  {
            
        }
    }
    
    // MARK: ===== 开启动画 ==========
    private func startAnimate() {
        if runAnimate {
            self.lineImageView.y = (kSize.height - (kSize.width - 100)) / 2 + 44
            UIView.animate(withDuration: 2, animations: {
                self.lineImageView.y = (kSize.height + kSize.width - 56) / 2
            }, completion: { (finish) in
                self.startAnimate()
            })
        }
    }
    
    // MARK: ====== 停止扫描 ==========
    private func stopScane() {
        runAnimate = false
        session.stopRunning()
    }
    
    // MARK: ======= rightBtnClick ======
    override func rightBtnDidClick() {
        let helper = PermissionHelper()
        helper.checkLibraryIsAllow { [weak self] (isAllow) in
            if isAllow {
                let pickerController = TZImagePickerController(maxImagesCount: 1, delegate: self)
                pickerController?.hideWhenCanNotSelect = true
                pickerController?.allowPickingVideo = false
                pickerController?.allowTakePicture = false
                pickerController?.allowPickingGif = false
                self?.present(pickerController!, animated: true, completion: nil)
            } else {
                let title = LanguageHelper.localizedString(key: "UnablePicker")
                let msg = LanguageHelper.localizedString(key: "OpenAlbumPermission")
                self?.presentAlert(title: title, msg: msg, helper: helper)
            }
        }
    }
    
    private func didScanResult(_ result: String) {
        print(result)
        if scanFinish != nil {
            navigationController?.popViewController(animated: true)
            scanFinish!(result)
            return
        }
        if result == "" {
            return
        }
    }
    
    // MARK: ======= delegate ======
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        stopScane()
        if let metadataObject = metadataObjects.first {
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject
            let result = readableObject.stringValue!
            didScanResult(result)
        }
    }

    // MARK: ======== TZImagePickerControllerDeleagte ======
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool, infos: [[AnyHashable : Any]]!) {
        let ciImage:CIImage=CIImage(image:photos[0])!
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options:[CIDetectorAccuracy:CIDetectorAccuracyHigh])
        let feature = detector?.features(in: ciImage)
        didScanResult((feature?.first as? CIQRCodeFeature)?.messageString ?? "")
    }
}
