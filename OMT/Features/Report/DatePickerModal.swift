//
//  DatePickerModal.swift
//  OMT
//
//  Created by 이인호 on 1/26/26.
//

import SwiftUI
import ComposableArchitecture

struct DatePickerModal: View {
    @Bindable var store: StoreOf<ReportFeature>
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
//                .onTapGesture {
//                    store.send(.closeDatePicker)
//                }
            
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Button {
                        store.send(.closeDatePicker)
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                
                Text("시작 날짜")
                
                HStack {
                    TextField("1-12를 입력하세요", text: $store.monthInput.sending(\.monthInputChanged))
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: store.monthInput) { oldValue, newValue in
                            if let month = Int(newValue), month < 1 || month > 12 {
                                store.send(.monthInputChanged(oldValue))
                            }
                        }
                        
                    Text("월")
                    
                    TextField("1-5를 입력하세요", text: $store.weekInput.sending(\.weekInputChanged))
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: store.weekInput) { oldValue, newValue in
                            if let week = Int(newValue), week < 1 || week > 5 {
                                store.send(.weekInputChanged(oldValue))
                            }
                        }
                    
                    Text("주")
                }
                
                Button {
                    store.send(.confirmDateSelection)
                } label: {
                    Text("분석하기")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(store.isConfirmButtonEnabled ? .primary5 : .gray)
                        .cornerRadius(12)
                }
                .disabled(!store.isConfirmButtonEnabled)
            }
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .frame(maxWidth: .infinity)
            .padding()
            .offset(y: -50)
        }
    }
}

