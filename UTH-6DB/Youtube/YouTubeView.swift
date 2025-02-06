//
//  YouTubeView.swift
//  Bench
//
//  Created by 이요섭 on 1/13/25.
//

import SwiftUI
import WebKit

struct YouTubeView: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let htmlString = """
                <!DOCTYPE html>
                <html>
                <head>
                <style>
                body, html {
                    margin: 0;
                    padding: 0;
                    overflow: hidden;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    height: 100%;
                    background-color: transparent;
                }
                </style>
                </head>
                <body>
                <iframe width="1920" height="934" src="https://www.youtube.com/embed/_PzPNlfgv2g" title="우리엘전자 리브랜딩(URIEL BRAND RENEWAL)" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
                </body>
                </html>
                """
                uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}
