//
//  ChatFeature.swift
//  OMT
//
//  Created by 이인호 on 1/22/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ChatFeature {
    @ObservableState
    struct State: Equatable {
        var messages: [Message] = Message.messages

        var inputText: String = ""
        var isLoading: Bool = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case sendButtonTapped
        case sendToServer
        case optionSelected(String)
        
        case delegate(Delegate)
        
        enum Delegate {
            
        }
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .sendButtonTapped:
                let message = Message(id: UUID().uuidString, content: state.inputText, isFromUser: true, timestamp: Date(), type: .text, options: nil)
                state.messages.append(message)
                state.inputText = ""
                return .send(.sendToServer)
            case .optionSelected(let option):
                if let index = state.messages.firstIndex(where: { $0.options != nil && $0.selectedOption == nil}) {
                    state.messages[index].selectedOption = option
                }
                
                let message = Message(id: UUID().uuidString, content: option, isFromUser: true, timestamp: Date(), type: .text, options: nil)
                state.messages.append(message)
            default:
                break
            }
            
            return .none
        }
    }
}
