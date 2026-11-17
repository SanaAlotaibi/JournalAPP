//
//  SplashView.swift
//  JournalSana
//
//  Created by Sana Alotaibi on 02/06/1448 AH.
//
import SwiftUI

// ─────────────────────────────────────────────
// شاشة البداية (Splash)
// تعرض شعار التطبيق ثانيتين، وبعدها تنتقل للصفحة الرئيسية
// ─────────────────────────────────────────────
struct SplashView: View {
    // false = نعرض السبلاش، true = نعرض الصفحة الرئيسية
    @State private var isActive = false

    // @StateObject: هنا ننشئ الـ ViewModel مرة وحدة بس، ويعيش طول عمر التطبيق
    // وبعدها نمرّره للصفحات الثانية بـ environmentObject
    @StateObject private var viewModel = JournalViewModel()

    // body: يختار وش يعرض حسب isActive
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
        // task: يشتغل أول ما تظهر الشاشة
        // ينتظر ثانيتين (async/await) وبعدها يغيّر isActive مع أنيميشن تلاشي
        .task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.easeInOut(duration: 0.5)) {
                isActive = true
            }
        }
    }

    // محتوى السبلاش: صورة الدفتر، اسم التطبيق، والجملة التوضيحية
    private var splashContent: some View {
        ZStack {
            Color("BackgroundPrimary")
                .ignoresSafeArea()

            VStack(spacing: 12) {
                // صورة الدفتر من الـ Assets
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
