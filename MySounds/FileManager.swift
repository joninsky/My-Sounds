//
//  FileManager.swift
//  MySounds
//
//  Created by Jon Vogel on 2/1/17.
//  Copyright © 2017 Jon Vogel. All rights reserved.
//

import Foundation


class MyFileManager {
    
    let m = FileManager.default
    
    init(){
        
    }
    
    
    func makeFileForRecording( fileName name: String) -> URL? {
        
        let documentURL = self.m.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
        
        return documentURL?.appendingPathComponent(name)
        
        
    }
    
    
    func removeFile( fileURL url: URL) throws {
        do{
            try self.m.removeItem(at: url)
        }catch{
            throw error
        }
    }
    
    
}
