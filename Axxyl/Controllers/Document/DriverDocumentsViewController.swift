//
//  DriverDocumentsViewController.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 02/10/22.
//

import UIKit
import Kingfisher
import AVFoundation
import Photos

class DriverDocumentsViewController: UIViewController {
    
    @IBOutlet weak var tlcHireBtn1_del: UIButton!
    @IBOutlet weak var commercialVehicleRegBtn2_del: UIButton!
    @IBOutlet weak var commercialVehicleRegBtn1_del: UIButton!
    @IBOutlet weak var insuranceCertBtn1_del: UIButton!
    @IBOutlet weak var vehicleRegBtn1_del: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var driverLicenseBtn1_del: UIButton!
    @IBOutlet weak var tlcHireBtn1: UIButton!
    @IBOutlet weak var headerStepLbl: UILabel!
    @IBOutlet weak var commercialVehicleRegBtn1: UIButton!
    @IBOutlet weak var insuranceCertBtn1: UIButton!
    @IBOutlet weak var vehicleRegBtn1: UIButton!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var driverLicenseBtn1: UIButton!
    
    var userRegistrationData : UserRegistrationPayload!
    var imagePicker = UIImagePickerController()
    var driverDocument : GetDriverDocumentResponse?
    var driverLicenseImage : UIImage?
    var vehicleRegestrationImage : UIImage?
    var insuranceCertificationImage : UIImage?
    var commercialVehicleRegImage : UIImage?
    var tlcHireImage : UIImage?
    
    var imageTag : Int?
    var driverRegistrationData : DriverRegistrationPayload!
    var physicalAddressData : PhysicalAddressData!
    var screenMode: DocumentsUploadScreenMode = DocumentsUploadScreenMode.menuMode
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.screenMode == DocumentsUploadScreenMode.menuMode) {
            getDriverDocuments()
        }
    }
    
    func getDriverDocuments() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        DriverService.instance.getDriverDocuments { [weak self] documentResponse in
            LoadingSpinner.manager.hideLoadingAnimation()
            guard let weakSelf = self else { return }
            if (documentResponse.isSuccess()){
//                DispatchQueue.main.async {
//                    weakSelf.setupScreen(data: documentResponse)
//                }
            }else{
//                DispatchQueue.main.async {
//                    weakSelf.setupScreen(data: documentResponse)
//                }
                AlertManager.showErrorAlert(message: documentResponse.msg ?? "Error fetching the documents, please try after sometime.")
            }
            weakSelf.driverDocument = documentResponse
            weakSelf.downloadDriverDocs()
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
    }
    
    func downloadDriverDocs() {
        if let data = driverDocument, data.isDriverLicencePresent() {
            self.downloadImage(with: (driverDocument?.DriverLicence)!) { image in
                self.driverLicenseImage = UIImage(data: image.jpegData(compressionQuality: CGFloat())!)
                DispatchQueue.main.async {
                    self.upDateScreen()
                }
            } errorCallBack: { error in
                print("error downloading image")
                DispatchQueue.main.async {
                    self.upDateScreen()
                }
            }
        }
        
        if let data = driverDocument, data.isTlcLicencePresent() {
            self.downloadImage(with: (driverDocument?.TlcLicence)!) { image in
                self.tlcHireImage = UIImage(data: image.jpegData(compressionQuality: CGFloat())!)
                DispatchQueue.main.async {
                    self.upDateScreen()
                }
            } errorCallBack: { error in
                print("error downloading image")
                DispatchQueue.main.async {
                    self.upDateScreen()
                }
            }
        }
        
        if let data = driverDocument, data.isInsuranceCertificatePresent() {
            self.downloadImage(with: (driverDocument?.InsuranceCertificate)!) { image in
                self.insuranceCertificationImage = UIImage(data: image.jpegData(compressionQuality: CGFloat())!)
                DispatchQueue.main.async {
                    self.upDateScreen()
                }
            } errorCallBack: { error in
                print("error downloading image")
                DispatchQueue.main.async {
                    self.upDateScreen()
                }
            }
        }
        
        if let data = driverDocument, data.isRegistrationCertificatePresent() {
            self.downloadImage(with: (driverDocument?.RegistrationCertificate)!) { image in
                self.vehicleRegestrationImage = UIImage(data: image.jpegData(compressionQuality: CGFloat())!)
                DispatchQueue.main.async {
                    self.upDateScreen()
                }
            } errorCallBack: { error in
                print("error downloading image")
                DispatchQueue.main.async {
                    self.upDateScreen()
                }
            }
        }
        
        if let data = driverDocument, data.isCertificateofRegistrationCarriagePermitPresent() {
            self.downloadImage(with: (driverDocument?.CertificateofRegistrationCarriagePermit)!) { image in
                self.commercialVehicleRegImage = UIImage(data: image.jpegData(compressionQuality: CGFloat())!)
                DispatchQueue.main.async {
                    self.upDateScreen()
                }
            } errorCallBack: { error in
                print("error downloading image")
                DispatchQueue.main.async {
                    self.upDateScreen()
                }
            }
        }
    }
    
    func upDateScreen() {

        if let data = driverLicenseImage {
            driverLicenseBtn1.setBackgroundImage(data, for: .normal)
         //   driverLicenseBtn1_del.isHidden = false
        } else {
            driverLicenseBtn1.setBackgroundImage(UIImage(named: "Document_Upload.png"), for: .normal)
            driverLicenseBtn1_del.isHidden = true
        }
        
        if let data = vehicleRegestrationImage {
            vehicleRegBtn1.setBackgroundImage(data, for: .normal)
         //   vehicleRegBtn1_del.isHidden = false
        } else {
            vehicleRegBtn1.setBackgroundImage(UIImage(named: "Document_Upload.png"), for: .normal)
            vehicleRegBtn1_del.isHidden = true
        }
        
        if let data = insuranceCertificationImage {
            insuranceCertBtn1.setBackgroundImage(data, for: .normal)
         //   insuranceCertBtn1_del.isHidden = false
        } else {
            insuranceCertBtn1.setBackgroundImage(UIImage(named: "Document_Upload.png"), for: .normal)
            insuranceCertBtn1_del.isHidden = true
        }
        
        if let data = commercialVehicleRegImage {
            commercialVehicleRegBtn1.setBackgroundImage(data, for: .normal)
        //    commercialVehicleRegBtn1_del.isHidden = false
        } else {
            commercialVehicleRegBtn1.setBackgroundImage(UIImage(named: "Document_Upload.png"), for: .normal)
            commercialVehicleRegBtn1_del.isHidden = true
        }
        
        if let data = tlcHireImage {
            tlcHireBtn1.setBackgroundImage(data, for: .normal)
          //  tlcHireBtn1_del.isHidden = false
        } else {
            tlcHireBtn1.setBackgroundImage(UIImage(named: "Document_Upload.png"), for: .normal)
            tlcHireBtn1_del.isHidden = true
        }
        
    }
    
    @IBAction func imageUploadBtnClicked(_ sender: UIButton) {
        imageTag = sender.tag
        let actionMenu = UIAlertController(title: "Choose User's Photo", message: nil, preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { (UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                DispatchQueue.main.async {
                    self.checkCameraPermission()
                }
//                self.imagePicker.delegate = self
//                self.imagePicker.sourceType = .camera
//                self.imagePicker.allowsEditing = false
//                
//                self.present(self.imagePicker, animated: true, completion: nil)
            }
        })
        let chooseLibraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: { (UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                DispatchQueue.main.async {
                    self.checkPhotoLibraryPermission()
                }
//                self.imagePicker.delegate = self
//                self.imagePicker.sourceType = .savedPhotosAlbum
//                self.imagePicker.allowsEditing = false
//                
//                self.present(self.imagePicker, animated: true, completion: nil)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
            self.dismiss(animated: true)
        })
        
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            actionMenu.addAction(takePhotoAction)
        }
        actionMenu.addAction(chooseLibraryAction)
        actionMenu.addAction(cancelAction)
        self.present(actionMenu, animated: true, completion: nil)
    }
    
    @IBAction func imageDeleteBtnClicked(_ sender: UIButton) {
        switch sender.tag {
        case 11:
            driverLicenseBtn1.setBackgroundImage(driverLicenseImage != sender.backgroundImage(for: .normal) ? driverLicenseImage : UIImage(named: "Document_Upload"), for: .normal)
            driverLicenseBtn1_del.isHidden = true
        case 21:
            vehicleRegBtn1.setBackgroundImage(vehicleRegestrationImage != sender.backgroundImage(for: .normal) ? vehicleRegestrationImage : UIImage(named: "Document_Upload"), for: .normal)
            vehicleRegBtn1_del.isHidden = true
        case 31:
            insuranceCertBtn1.setBackgroundImage(insuranceCertificationImage != sender.backgroundImage(for: .normal) ? insuranceCertificationImage : UIImage(named: "Document_Upload"), for: .normal)
            insuranceCertBtn1_del.isHidden = true
        case 41:
            commercialVehicleRegBtn1.setBackgroundImage(commercialVehicleRegImage != sender.backgroundImage(for: .normal) ? commercialVehicleRegImage : UIImage(named: "Document_Upload"), for: .normal)
            commercialVehicleRegBtn1_del.isHidden = true
        case 51:
            tlcHireBtn1.setBackgroundImage(tlcHireImage != sender.backgroundImage(for: .normal) ? tlcHireImage : UIImage(named: "Document_Upload"), for: .normal)
            tlcHireBtn1_del.isHidden = true
        default :
            print("Default case")
        }
    }
    
    @IBAction func continueBtnClicked(_ sender: Any) {
        var mediaArray: [Media] = []
        let driverLic_ = Media(withImage: driverLicenseBtn1.backgroundImage(for: .normal), forKey: "file1")
        let vehicleReg_ = Media(withImage: vehicleRegBtn1.backgroundImage(for: .normal), forKey: "file2")
        let insurenceCert_ = Media(withImage: insuranceCertBtn1.backgroundImage(for: .normal), forKey: "file3")
        let commercialVehicleReg_ = Media(withImage: commercialVehicleRegBtn1.backgroundImage(for: .normal), forKey: "file4")
        let tlcHire_ = Media(withImage: tlcHireBtn1.backgroundImage(for: .normal), forKey: "file5")
//        if driverLicenseBtn1.backgroundImage(for: .normal) != UIImage(named: "Document_Upload") {
//            if let data = driverLicenseImage, data == driverLicenseBtn1.backgroundImage(for: .normal) {
//               print("No image change")
//            } else {
//                mediaArray.append(driverLic_!)
//            }
//        }
        
        if !driverLicenseBtn1_del.isHidden {
            mediaArray.append(driverLic_!)
        }
        
        if !vehicleRegBtn1_del.isHidden {
            mediaArray.append(vehicleReg_!)
        }
        
        if !insuranceCertBtn1_del.isHidden {
            mediaArray.append(insurenceCert_!)
        }
        
        if !commercialVehicleRegBtn1_del.isHidden {
            mediaArray.append(commercialVehicleReg_!)
        }
        
        if !tlcHireBtn1_del.isHidden {
            mediaArray.append(tlcHire_!)
        }

        if !mediaArray.isEmpty {
           // if mediaArray.count == 5 {
                
                LoadingSpinner.manager.showLoadingAnimation(delegate: self)
                var email = ""
                if (self.driverRegistrationData != nil) {
                    email = self.driverRegistrationData.emailId
                }
                
                DriverService.instance.uploadDriverDocument(documents: mediaArray, emailId: email, mode: screenMode) {  uploadResponse in
                    LoadingSpinner.manager.hideLoadingAnimation()
                    if uploadResponse.isSuccess() {
                        DispatchQueue.main.async {
                            LoadingSpinner.manager.hideLoadingAnimation()
                            
                            if (self.screenMode == DocumentsUploadScreenMode.signupMode) {
                                let okAction = UIAlertAction(title: "Continue", style: UIAlertAction.Style.cancel) { action in
                                    let sb = UIStoryboard(name: "Account", bundle: nil)
                                    let vcToOpen = sb.instantiateViewController(withIdentifier: "MailingPayoutDetailsViewController") as! MailingPayoutDetailsViewController
                                    vcToOpen.driverRegistrationData = self.driverRegistrationData
                                    vcToOpen.physicalAddressData = self.physicalAddressData
                                    vcToOpen.screenMode = MailingPayoutDetaisScreenMode.registerDriverMailingPayoutDetails
                                    self.navigationController?.pushViewController(vcToOpen, animated: true)
                                }
                                AlertManager.showCustomAlertWith("Information", message: "Documents Updated Successfully!", actions: [okAction])
                            } else {
                                AlertManager.showInfoAlert(message: "Documents Updated Successfully!")
                            }
                        }
                    }else{
                        LoadingSpinner.manager.hideLoadingAnimation()
                        AlertManager.showErrorAlert(message: uploadResponse.msg ?? "Document upload failed")
                    }
                    
                } errorCallBack: { errMsg in
                    LoadingSpinner.manager.hideLoadingAnimation()
                    AlertManager.showErrorAlert(message: errMsg)
                }
//            } else {
//                AlertManager.showInfoAlert(message: "You can not upload partial documents. It is mandetory to upload all listed document at once.")
//            }
        } else {
            AlertManager.showInfoAlert(message: "No Image change to upload")
        }
   // }
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("Camera access granted.")
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = false
            
            self.present(self.imagePicker, animated: true, completion: nil)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { response in
                if response {
                    DispatchQueue.main.async {
                        self.imagePicker.delegate = self
                        self.imagePicker.sourceType = .camera
                        self.imagePicker.allowsEditing = false
                        
                        self.present(self.imagePicker, animated: true, completion: nil)
                    }
                } else {
                    print("Camera access denied after request.")
                    // Show settings alert if denied
                    DispatchQueue.main.async {
                        self.showSettingsAlert(for: "Camera")
                    }
                }
            }
        case .denied, .restricted:
            print("Camera access denied.")
            // Show settings alert if denied
            self.showSettingsAlert(for: "Camera")
        @unknown default:
            print("Unknown camera authorization status.")
        }
    }

    func checkPhotoLibraryPermission() {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized:
            print("Photo library access granted.")
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.imagePicker.allowsEditing = false
            
            self.present(self.imagePicker, animated: true, completion: nil)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    DispatchQueue.main.async {
                        self.imagePicker.delegate = self
                        self.imagePicker.sourceType = .savedPhotosAlbum
                        self.imagePicker.allowsEditing = false
                        
                        self.present(self.imagePicker, animated: true, completion: nil)
                    }
                case .denied, .restricted:
                    print("Photo library access denied after request.")
                    // Show settings alert if denied
                    DispatchQueue.main.async {
                        self.showSettingsAlert(for: "Photo Library")
                    }
                default:
                    break
                }
            }
        case .denied, .restricted:
            print("Photo library access denied.")
            // Show settings alert if denied
            self.showSettingsAlert(for: "Photo Library")
        case .limited:
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.imagePicker.allowsEditing = false
            
            self.present(self.imagePicker, animated: true, completion: nil)
        @unknown default:
            print("Unknown photo library authorization status.")
        }
    }

    func showSettingsAlert(for type: String) {
        var msg = ""
        if (type == "Photo Library") {
            msg = "You’ve denied \(type.lowercased()) access. To upload documents, we need access to your camera/photo library. This allows you to upload your driver’s license, and car documents from your gallery. You can enable it by following this path:\n\nSettings → Axxyl → Photos → Select 'Full Access' or 'Limited Access'."
        } else {
            msg = "You’ve denied \(type.lowercased()) access. To update your profile photo, we need access to your camera. This allows you to upload your driver’s license, and car documents by capturing photos of it. You can enable it by following this path:\n\nSettings → Axxyl → Camera → Select 'Allows'."
        }
        let alertController = UIAlertController(
            title: "\(type) Access Denied",
            message: msg,
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { action in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings)
            }
        }))

        self.present(alertController, animated: true, completion: nil)
    }
}

extension DriverDocumentsViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            switch imageTag {
            case 111:
                driverLicenseBtn1.setBackgroundImage(image, for: .normal)
                driverLicenseBtn1_del.isHidden = false
            case 211:
                vehicleRegBtn1.setBackgroundImage(image, for: .normal)
                vehicleRegBtn1_del.isHidden = false
            case 311:
                insuranceCertBtn1.setBackgroundImage(image, for: .normal)
                insuranceCertBtn1_del.isHidden = false
            case 411:
                commercialVehicleRegBtn1.setBackgroundImage(image, for: .normal)
                commercialVehicleRegBtn1_del.isHidden = false
            case 511:
                tlcHireBtn1.setBackgroundImage(image, for: .normal)
                tlcHireBtn1_del.isHidden = false
            default :
                print("Default case")
            }
        }
        self.dismiss(animated: true)
    }
    
    func downloadImage(`with` urlString : String, successCallBack: @escaping (UIImage) -> (), errorCallBack: @escaping (String) -> ()) {
        guard let url = URL.init(string: urlString) else {
            return
        }
        let resource = Kingfisher.ImageResource(
            downloadURL: url,
            cacheKey: url.absoluteString
        )

        KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
            switch result {
            case .success(let value):
                print("Image: \(value.image). Got from: \(value.cacheType)")
                successCallBack(value.image)
            case .failure(let error):
                print("Error: \(error)")
                errorCallBack(error.localizedDescription)
            }
        }
    }
}
