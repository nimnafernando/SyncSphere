//
//  EncodableExtension.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-07.
//

import Foundation

extension Encodable{
    
    func asDist()-> [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }
        
        do { let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            return jsonSerialized ?? [:]
        } catch {
            return [:]
        }
    }
}
