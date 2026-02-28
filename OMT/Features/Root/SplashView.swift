//
//  SplashView.swift
//  OMT
//
//  Created by 이인호 on 2/10/26.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image("splash")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            Image("splash_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 139, height: 56)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.primary7)
    }
}

#Preview {
    SplashView()
}
