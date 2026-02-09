//
//  WebView.swift
//  OMT
//
//  Created by 이인호 on 2/10/26.
//

import SwiftUI
import WebKit

struct WebView: View {
    let url: URL
    let title: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        WebViewRepresentable(url: url)
            .customNavigationBar(
                centerView: {
                    Text(title)
                        .typography(.h2_2)
                        .foregroundStyle(.gray11)
                },
                leftView: {
                    Button {
                        dismiss()
                    } label: {
                        Image("arrow_back_01")
                    }
                }
            )
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
