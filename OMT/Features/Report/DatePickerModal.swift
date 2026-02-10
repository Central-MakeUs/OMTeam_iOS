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
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    store.send(.closeDatePicker)
                }
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        store.send(.closeDatePicker)
                    } label: {
                        Image("arrow_close")
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
                        VStack(alignment: .leading, spacing: 4) {
                            Text("년")
                                .typography(.sub_btn3_disabled)
                                .foregroundStyle(.gray9)
                            
                            TextField("",
                                      text: $store.yearInput.sending(\.yearInputChanged),
                                      prompt: Text("YY")
                                .typography(.sub_btn3_disabled)
                                .foregroundStyle(.gray7)
                            )
                            .focused($isFocused)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 13)
                            .typography(.sub_btn3_enabled)
                            .foregroundStyle(.gray11)
                            .background(.gray1)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("월")
                                .typography(.sub_btn3_disabled)
                                .foregroundStyle(.gray9)
                            
                            TextField("",
                                      text: $store.monthInput.sending(\.monthInputChanged),
                                      prompt: Text("MM")
                                .typography(.sub_btn3_disabled)
                                .foregroundStyle(.gray7)
                            )
                            .focused($isFocused)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 13)
                            .typography(.sub_btn3_enabled)
                            .foregroundStyle(.gray11)
                            .background(.gray1)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("주")
                                .typography(.sub_btn3_disabled)
                                .foregroundStyle(.gray9)
                            
                            TextField("",
                                      text: $store.weekInput.sending(\.weekInputChanged),
                                      prompt: Text("WW")
                                .typography(.sub_btn3_disabled)
                                .foregroundStyle(.gray7)
                            )
                            .focused($isFocused)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 13)
                            .typography(.sub_btn3_enabled)
                            .foregroundStyle(.gray11)
                            .background(.gray1)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                
                if let errorMessage = store.errorMessage {
                    HStack(spacing: 4) {
                        Image("error_icon")
                        Text(errorMessage)
                            .typography(.sub_btn3_disabled)
                            .foregroundStyle(.error)
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                } else {
                    Spacer()
                        .frame(height: 28)
                }
                
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
            .background(.gray0)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(maxWidth: .infinity)
            .padding()
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = false
            }
        }
    }
}

