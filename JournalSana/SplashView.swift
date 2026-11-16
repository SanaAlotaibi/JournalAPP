//
//  SplashView.swift
//  JournalSana
//
//  Created by Sana Alotaibi on 02/06/1448 AH.
//
import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @StateObject private var viewModel = JournalViewModel()

    var body: some View {
        ZStack {
            if isActive {
                // بعد السبلاش ننتقل للصفحة الرئيسية ونمرر الـ ViewModel
                MainJournalView()
                    .environmentObject(viewModel)
                    .transition(.opacity)
            } else {
                splashContent
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        // المؤقت على الـ ZStack نفسه عشان يشتغل مرة وحدة أكيد
        .task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.easeInOut(duration: 0.5)) {
                isActive = true
            }
        }
    }

    private var splashContent: some View {
        ZStack {
            Color("BackgroundPrimary")
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Image("2321")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)

                // عنوان التطبيق
                Text("Journali")
                    .font(.system(size: 42, weight: .black))
                    .foregroundColor(.white)

                // الجملة التوضيحية
                Text("Your thoughts, your story")
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    SplashView()
}
