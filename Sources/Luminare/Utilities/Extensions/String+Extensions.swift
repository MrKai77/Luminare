//
//  File.swift
//  
//
//  Created by KrLite on 2024/11/5.
//

import Foundation

extension String: @retroactive Identifiable {
    public var id: Self {
        self
    }
}
