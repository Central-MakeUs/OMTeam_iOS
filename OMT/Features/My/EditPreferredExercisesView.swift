//
//  EditPreferredExercisesView.swift
//  OMT
//
//  Created by 이인호 on 2/11/26.
//

import SwiftUI
import ComposableArchitecture

struct EditPreferredExercisesView: View {
    @Bindable var store: StoreOf<MyFeature>
    @Environment(\.dismiss) var dismiss
    @FocusState private var isCustomFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading) {
            itemValueView
            Spacer()
            editButton
        }
        .padding(.top, 16)
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
        .onTapGesture {
            isCustomFieldFocused = false
        }
        .customNavigationBar(
            centerView: {
                Text("내 정보 수정하기")
                    .typography(.h2_2)
                    .foregroundStyle(.gray11)
            },
            leftView: {
                Button {
                    dismiss()
                } label: {
                    Image("arrow_back_01")
                }
            },
        )
        .onAppear {
            store.selectedPreferredExercises = store.preferredExercises
        }
        .onChange(of: store.isAddingCustomExercise) { _, isAdding in
            if isAdding {
                isCustomFieldFocused = true
            }
        }
    }
}

extension EditPreferredExercisesView {
    @ViewBuilder
    private func selectedExerciseCapsule(_ exercise: String) -> some View {
        Button {
            store.send(.preferredExerciseToggled(exercise))
        } label: {
            Text(exercise)
                .typography(.sub_btn2_enabled)
                .foregroundStyle(.gray12)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .strokeBorder(.gray3, lineWidth: 1)
                        .background(Capsule().fill(.gray1))
                )
        }
    }

    @ViewBuilder
    private func exerciseOptionButton(_ exercise: String) -> some View {
        let isSelected = store.selectedPreferredExercises.contains(exercise)
        Button {
            store.send(.preferredExerciseToggled(exercise))
        } label: {
            Text(exercise)
                .typography(.sub_btn2_enabled)
                .foregroundStyle(isSelected ? .gray12 : .gray9)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .strokeBorder(.gray3, lineWidth: 1)
                        .background(Capsule().fill(.gray1))
                )
        }
        .disabled(isSelected || !store.canAddMoreExercises)
    }

    @ViewBuilder
    private var customExerciseView: some View {
        if store.canAddMoreExercises {
            if store.isAddingCustomExercise {
                TextField("", text: $store.customExerciseText)
                    .focused($isCustomFieldFocused)
                    .typography(.sub_btn2_enabled)
                    .foregroundStyle(.gray12)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(minWidth: 115)
                    .fixedSize()
                    .background(
                        Capsule()
                            .strokeBorder(.gray3, lineWidth: 1)
                            .background(Capsule().fill(.gray1))
                    )
            } else if !store.customExerciseText.isEmpty {
                Button {
                    store.send(.customExerciseConfirmed)
                } label: {
                    Text(store.customExerciseText)
                        .typography(.sub_btn2_enabled)
                        .foregroundStyle(.gray9)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .strokeBorder(.gray3, lineWidth: 1)
                                .background(Capsule().fill(.gray1))
                        )
                }
            } else {
                Button {
                    store.send(.startAddingCustomExercise)
                } label: {
                    HStack(spacing: 4) {
                        Image("icon_plus")
                        Text("직접 추가하기")
                    }
                    .typography(.sub_btn2_enabled)
                    .foregroundStyle(.gray9)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .strokeBorder(.gray3, lineWidth: 1)
                            .background(Capsule().fill(.gray1))
                    )
                }
            }
        }
    }

    private var itemValueView: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 20) {
                Text("선호하는 운동을 선택해주세요.")
                    .typography(.sub_b3_1)
                    .foregroundStyle(.gray7)

                VStack(alignment: .leading, spacing: 4) {
                    if store.selectedPreferredExercises.isEmpty {
                        Text("")
                            .typography(.sub_btn2_enabled)
                            .foregroundStyle(.gray8)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(store.selectedPreferredExercises, id: \.self) { exercise in
                                    selectedExerciseCapsule(exercise)
                                }
                            }
                        }
                    }

                    Divider()

                    HStack(spacing: 2) {
                        Image("icon_info")
                        Text("최대 3개까지 선택 할 수 있어요.")
                            .typography(.sub_b4_2)
                            .foregroundStyle(.gray8)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("선호 운동 선택 목록")
                    .typography(.sub_btn3_enabled)
                    .foregroundStyle(.gray10)

                let options = MyFeature.State.defaultExerciseOptions
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        exerciseOptionButton(options[0])
                        exerciseOptionButton(options[1])
                    }
                    HStack(spacing: 8) {
                        exerciseOptionButton(options[2])
                        exerciseOptionButton(options[3])
                    }
                    HStack(spacing: 8) {
                        exerciseOptionButton(options[4])
                        customExerciseView
                    }
                }
            }
        }
        .padding(.horizontal, 12)
    }
}

extension EditPreferredExercisesView {
    private var isCustomTextValid: Bool {
        !store.customExerciseText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var editButton: some View {
        Group {
            if store.isAddingCustomExercise {
                Button {
                    store.send(.customExerciseAdded)
                } label: {
                    Text("저장하기")
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .typography(isCustomTextValid ? .btn2_enabled : .btn2_disabled)
                        .foregroundColor(isCustomTextValid ? .gray12 : .gray9)
                        .background(isCustomTextValid ? .primary7 : .primary4)
                        .cornerRadius(12)
                }
                .disabled(!isCustomTextValid)
            } else {
                Button {
                    store.send(.preferredExercisesEditConfirmed)
                    dismiss()
                } label: {
                    Text("선호 운동 수정하기")
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .typography(store.isPreferredExercisesChanged ? .btn2_enabled : .btn2_disabled)
                        .foregroundColor(store.isPreferredExercisesChanged ? .gray12 : .gray9)
                        .background(store.isPreferredExercisesChanged ? .primary7 : .primary4)
                        .cornerRadius(12)
                }
                .disabled(!store.isPreferredExercisesChanged)
            }
        }
        .padding(.bottom, 28)
    }
}
