//
//  TimeInterval+Helpers.swift
//  quizmaker
//
//  Created by Atilla Özder on 13.12.2018.
//  Copyright © 2018 Atilla Özder. All rights reserved.
//

import Foundation

/// :nodoc:
extension TimeInterval {
    private var minutes: Int {
        return (Int(self) / 60 ) % 60
    }
    
    private var hours: Int {
        return Int(self) / 3600
    }
    
    var stringTime: String {
        if hours != 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes != 0 {
            return "\(minutes)m"
        } else {
            return "0s"
        }
    }
}
