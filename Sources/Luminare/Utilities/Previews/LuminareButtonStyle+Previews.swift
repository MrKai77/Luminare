//
//  LuminareButtonStyle+Previews.swift
//
//
//  Created by KrLite on 2024/11/4.
//

import SwiftUI

#Preview("LuminareButtonStyle") {
    VStack {
        LuminareSection {
            Button {
            } label: {
                HStack {
                    Image(systemName: "app.gift.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 60)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cosmetic")
                            .fontWeight(.medium)
                        
                        Text("Custom Layout")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(4)
            }
            .buttonStyle(LuminareCosmeticButtonStyle(.init(systemName: "star.fill")))
            .frame(height: 72)
            
            Button {
            } label: {
                HStack {
                    Image(systemName: "app.gift.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 60)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cosmetic Hovering")
                            .fontWeight(.medium)
                        
                        Text("Custom Layout")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(4)
            }
            .buttonStyle(LuminareCosmeticButtonStyle(.init(systemName: "star.fill"), isHovering: true))
            .frame(height: 72)
        }
        
        LuminareSection {
            HStack {
                Button("Prominent Tinted") {
                }
                .buttonStyle(LuminareProminentButtonStyle())
                .tint(.purple)
                
                Button("Prominent Tinted") {
                }
                .buttonStyle(LuminareProminentButtonStyle())
                .tint(.teal)
                
                Button("Prominent") {
                }
                .buttonStyle(LuminareProminentButtonStyle())
            }
            .frame(height: 40)
            
            HStack {
                Button("Normal") {
                }
                .buttonStyle(LuminareButtonStyle())
                
                Button("Destructive") {
                }
                .buttonStyle(LuminareDestructiveButtonStyle())
            }
            .frame(height: 40)
        }
    }
    .padding()
}
