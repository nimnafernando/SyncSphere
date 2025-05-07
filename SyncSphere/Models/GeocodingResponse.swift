//
//  GeocodingResponse.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-05-07.
//

import Foundation

struct GeocodingResponse: Codable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
} 
