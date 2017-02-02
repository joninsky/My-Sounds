//
//  File.swift
//  MySounds
//
//  Created by Jon Vogel on 2/1/17.
//  Copyright © 2017 Jon Vogel. All rights reserved.
//

import Foundation
import RealmSwift


class RecordingController {
    
    
    var recordings: [Recording] {
        
        var results: Results<Recording>
        
        do{
            results = try Realm().objects(Recording.self).sorted(byKeyPath: "recordedDate", ascending: true)
        }catch{
            return []
        }
        return Array(results)
    }
    
    
    init() {
        
    }
    
    func addRecording(theRecording recording: Recording) throws {
        
        do{
            try Realm().write {
                try Realm().add(recording)
            }
        }catch{
            throw error
        }
    }
    
    
    
}
