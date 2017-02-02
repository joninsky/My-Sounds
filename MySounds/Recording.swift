//
//  Recording.swift
//  MySounds
//
//  Created by Jon Vogel on 2/1/17.
//  Copyright © 2017 Jon Vogel. All rights reserved.
//

import Foundation
import RealmSwift



class Recording: Object {
    
    dynamic var name: String?
    
    dynamic var localFileName: String?
    
    dynamic var remoteFileURLString: String?
    
    dynamic var uploaded = false
    
    dynamic var recordedDate: Date?
    
    dynamic var uploadDate: Date?
    
    var localURL: URL? {
        guard let string = self.localFileName else {
            return nil
        }
        
        let m = MyFileManager()
        
        return m.makeFileForRecording(fileName: string)
    }
    
    var remoteURL: URL? {
        guard let string = self.remoteFileURLString else {
            return nil
        }

        return URL(string: string)
    }
    
    func removeRecording() throws {
        if let realm = self.realm {
            do{
                try realm.write {
                    realm.delete(self)
                }
            }catch{
                throw error
            }
        }
    }
    
    func markAsUploaded(remoteURL url: URL) throws {
        do{
            try self.realm?.write {
                self.remoteFileURLString = url.absoluteString
                self.uploaded = true
                self.uploadDate = Date()
            }
        }catch{
            throw error
        }
    }
    
    
}
