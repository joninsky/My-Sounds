//
//  S3Controller.swift
//  MySounds
//
//  Created by Jon Vogel on 2/1/17.
//  Copyright © 2017 Jon Vogel. All rights reserved.
//

import Foundation
import AWSS3


enum UploadError: Error {
    case badUploadRequest
    case noLocalFileName
    case noLocalFile
    case transferError(Error)
    case realmError(Error)
    case noResult
    case couldNotMakeRemoteURL
}

class S3Controller {
    
    
    let poolID = "us-west-2:a05c7d39-d69c-495c-a571-b4d74207fd7d"
    let poolARN = "arn:aws:cognito-idp:us-west-2:266649249854:userpool/us-west-2_JdQvCLpUI"
    
    var s3Manager: AWSS3TransferManager?
    
    let mainThread = DispatchQueue.main
    
    let uniqueDeviceID: String
    //MARK: Init
    init?() {
        
        guard let ID = UIDevice.current.identifierForVendor?.uuidString else {
            return nil
        }
        
        self.uniqueDeviceID = ID
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USWest2, identityPoolId: self.poolID)
        
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USWest2, credentialsProvider: credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        self.s3Manager = AWSS3TransferManager.default()
        
    }
    
    
    func uploadSound(theRecording recording: Recording, completion: @escaping(_ error: UploadError?) -> Void, progress: @escaping(_ p: Float) -> Void) {
        
        guard let uploadRequest = AWSS3TransferManagerUploadRequest() else {
            completion(UploadError.badUploadRequest)
            return
        }
        
        uploadRequest.bucket = "audiobucketfunsounds"
        
        guard let fileName = recording.localFileName else {
            completion(UploadError.noLocalFileName)
            return
        }
        
        uploadRequest.key = "\(self.uniqueDeviceID)_\(fileName)"
        
        guard let url = recording.localURL else {
            completion(UploadError.noLocalFile)
            return
        }
        
        uploadRequest.body = url
        
        self.s3Manager?.upload(uploadRequest).continueWith(block: { (theTask) -> Any? in
            if let error = theTask.error {
                DispatchQueue.main.async {
                    completion(UploadError.transferError(error))
                }
            }else if let _ = theTask.result as? AWSS3TransferManagerUploadOutput {
                
                guard let remoteURL = URL(string: "https://s3-us-west-2.amazonaws.com/audiobucketfunsounds")?.appendingPathComponent("\(self.uniqueDeviceID)_\(fileName)") else {
                    DispatchQueue.main.async {
                        completion(UploadError.couldNotMakeRemoteURL)
                    }
                    return nil
                }
                
                DispatchQueue.main.async {
                    do{
                        try recording.markAsUploaded(remoteURL: remoteURL)
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }catch{
                        DispatchQueue.main.async {
                            completion(UploadError.realmError(error))
                        }
                    }
                    
                }
            }else{
                DispatchQueue.main.async {
                    completion(UploadError.noResult)
                }
            }
            return nil
        })
        
        
        uploadRequest.uploadProgress = {(bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) in
            
            let p = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
            
            DispatchQueue.main.async {
                progress(p)
            }
        }
        
        
        
    }
    
    
}
