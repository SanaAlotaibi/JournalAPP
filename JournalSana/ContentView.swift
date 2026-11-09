import SwiftUI
import Playgrounds

struct ContentView: View {
    var body: some View {
        VStack{
            Color("Background  Primary")
                .ignoresSafeArea()
            VStack(spacing: 16){
                Image("2321")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                
                
                
                
                
                
                
            }
            
        }
        
   
        
    }
}

#Preview {
    ContentView()
}

