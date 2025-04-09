//
//  DateFormatExtension.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-09.
//

import Foundation

struct DateFormatExtension {
    
    static func formatDate(_ date: Date, format: String = "MMM dd, yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    static func formatDate(from timeInterval: TimeInterval, format: String = "MMM dd, yyyy") -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        return formatDate(date, format: format)
    }
}
