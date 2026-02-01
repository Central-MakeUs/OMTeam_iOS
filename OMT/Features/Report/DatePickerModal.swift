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
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        store.send(.closeDatePicker)
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                .padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("분석을 보고 싶은 주간을 입력해주세요.")
                        .typography(.h4)
                        .foregroundStyle(.gray13)
                    Text("분석은 월요일을 기준으로 1주 단위로 진행돼요!")
                        .typography(.sub_b4_3)
                        .foregroundStyle(.gray9)
                }
                .padding(.bottom, 28)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("시작 날짜")
                        .typography(.sub_btn3_enabled)
                        .foregroundStyle(.gray11)
                    
                    HStack(spacing: 11) {
                        HStack(spacing: 4) {
                            TextField("",
                                      text: $store.monthInput.sending(\.monthInputChanged),
                                      prompt: Text("1-12를 입력하세요")
                                .typography(.sub_btn3_disabled)
                                .foregroundStyle(.gray7)
                            )
                            .keyboardType(.numberPad)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 13)
                            .typography(.sub_btn3_enabled)
                            .foregroundStyle(.gray11)
                            .background(.gray1)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .onChange(of: store.monthInput) { oldValue, newValue in
                                if let month = Int(newValue), month < 1 || month > 12 {
                                    store.send(.monthInputChanged(oldValue))
                                }
                            }
                            
                            Text("월")
                                .typography(.sub_btn3_disabled)
                                .foregroundStyle(.gray9)
                        }
                        
                        HStack(spacing: 4) {
                            TextField("",
                                      text: $store.weekInput.sending(\.weekInputChanged),
                                      prompt: Text("1-5를 입력하세요")
                                .typography(.sub_btn3_disabled)
                                .foregroundStyle(.gray7)
                            )
                            .keyboardType(.numberPad)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 13)
                            .typography(.sub_btn3_enabled)
                            .foregroundStyle(.gray11)
                            .background(.gray1)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .onChange(of: store.weekInput) { oldValue, newValue in
                                if let week = Int(newValue), week < 1 || week > 5 {
                                    store.send(.weekInputChanged(oldValue))
                                }
                            }
                            
                            Text("주")
                                .typography(.sub_btn3_disabled)
                                .foregroundStyle(.gray9)
                        }
                    }
                }
                .padding(.bottom, 64)
                
                Button {
                    store.send(.confirmDateSelection)
                } label: {
                    Text("분석 보기")
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .typography(store.isConfirmButtonEnabled ? .btn2_enabled : .btn2_disabled)
                        .foregroundStyle(store.isConfirmButtonEnabled ? .gray12 : .gray9)
                        .background(store.isConfirmButtonEnabled ? .primary7 : .primary4)
                        .cornerRadius(12)
                }
                .disabled(!store.isConfirmButtonEnabled)
            }
            .padding(20)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(maxWidth: .infinity)
            .padding()
            .offset(y: -50)
        }
    }
}

