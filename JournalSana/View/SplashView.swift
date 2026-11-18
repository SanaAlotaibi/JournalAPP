//
//  SplashView.swift
//  JournalSana
//
//  Created by Sana Alotaibi on 02/06/1448 AH.
//
import SwiftUI
struct SplashView: View {
    //عشان يعرض الشعار اول بعدين يتحول لصح ويعرض الصفحه الرئيسيه
    @State private var isActive = false
    //سوينا فيو مودل لاننا نبيه يبقي
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
        // الشاشه دارك 
        .preferredColorScheme(.dark)
        //task يشغل كود أول ما تظهر الشاشة. ولو انقفلت الشاشة قبل ما يخلص، يلغيه تلقائياً
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

                Text("Journali")
                    .font(.system(size: 42, weight: .black))
                    .foregroundColor(.white)

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
