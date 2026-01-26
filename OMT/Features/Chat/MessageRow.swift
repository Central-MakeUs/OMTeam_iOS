//
//  MessageRow.swift
//  OMT
//
//  Created by 이인호 on 1/22/26.
//

import SwiftUI

struct MessageRow: View {
    let message: Message
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isFromUser {
                Spacer()
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(18)
                    .frame(maxWidth: 250, alignment: .trailing)
            } else {
                if message.type == .text {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(18)
                        .frame(maxWidth: 250, alignment: .leading)
                } else {
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "heart") // 프로필
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                            
                            Text("채팅봇") // 봇 이름
                        }
                        
                        VStack(alignment: .leading) {
                            Text(message.content)
                                .padding(.bottom, 10)
                            
                            VStack {
                                if let options = message.options {
                                    ForEach(options, id: \.self) { option in
                                        Button {
                                            print(option)
                                        } label: {
                                            Text(option)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .frame(maxWidth: .infinity)
                                                .background(Color.white)
                                                .foregroundColor(.blue)
                                                .cornerRadius(18)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(18)
                        .frame(maxWidth: 250, alignment: .leading)
                    }
                }
                
                Spacer()
            }
        }
    }
}
