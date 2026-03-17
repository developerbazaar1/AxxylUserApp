//
//  DriverDocument.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 29/01/23.
//

import Foundation

struct UploadDriverDocumentPayload {
    var action = Actions.uploadDriverDocuments.rawValue
    var userId : String
    var docs: [Media?]
}

struct GetDriverDocuments: Encodable {
    var action = Actions.getUploadedDriverDocuments.rawValue
    var emailId : String
}

struct UploadDriverDocumentResponse: Decodable {
    var status : Int
    var msg : String?
    var DriverLicence: String?
    var TlcLicence: String?
    var InsuranceCertificate: String?
    var RegistrationCertificate: String?
    var CertificateofRegistrationCarriagePermit: String?
    
    func isSuccess() -> Bool {
        return status == 1
    }
}

struct GetDriverDocumentResponse: Decodable {
    var status : Int
    var msg : String?
    var DriverLicence: String?
    var TlcLicence: String?
    var InsuranceCertificate: String?
    var RegistrationCertificate: String?
    var CertificateofRegistrationCarriagePermit: String?
    
    func isSuccess() -> Bool {
        return status == 1
    }
    
    func isTlcLicencePresent() -> Bool {
        return (TlcLicence != nil) ? TlcLicence != "No" : false
    }
    
    func isDriverLicencePresent() -> Bool {
        return (DriverLicence != nil) ? DriverLicence != "No" : false
    }
    
    func isInsuranceCertificatePresent() -> Bool {
        return (InsuranceCertificate != nil) ? InsuranceCertificate != "No" : false
    }
    
    func isRegistrationCertificatePresent() -> Bool {
        return (RegistrationCertificate != nil) ? RegistrationCertificate != "No" : false
    }
    
    func isCertificateofRegistrationCarriagePermitPresent() -> Bool {
        return (CertificateofRegistrationCarriagePermit != nil) ? CertificateofRegistrationCarriagePermit != "No" : false
    }
}
