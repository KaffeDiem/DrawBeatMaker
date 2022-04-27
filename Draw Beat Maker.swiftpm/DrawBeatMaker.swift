import SwiftUI

@main
struct DrawBeatMaker: App {
    @State var isLandingShown = true
    @State var blurRadius: CGFloat = 20
    
    var body: some Scene {
        WindowGroup {
            
            ZStack {
                DrawingView(isHelpShown: $isLandingShown, blurRadius: $blurRadius)
                    .blur(radius: blurRadius, opaque: false)
                if isLandingShown {
                    LandingPageView(isLandingShown: $isLandingShown, blurRadius: $blurRadius)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
}


struct LandingPageView: View {
    @Binding var isLandingShown: Bool
    @Binding var blurRadius: CGFloat
    
    var notUsed = 0
    
    var body: some View {
        VStack {
            Text("Draw Beat Maker")
                .font(.system(size: 42, weight: .heavy, design: .monospaced))
                .foregroundColor(.blue)
                .padding()
            Text("Draw a beat and listen to it afterwards! I already drew something for you to listen to, but feel free to delete it. Up to 3 strokes will play at the same time!")
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: 400)
            Spacer()
                .frame(height: 50)
            Text("Getting started")
                .font(.title2)
                .padding()
            Text("1. Pick a color, all colors sound different.\n2. Draw something with your color.\n3. Press play to hear your drawing come to life.")
                .multilineTextAlignment(.leading)
                .frame(maxWidth: 400)
            Spacer()
                .frame(height: 50)
            Button {
                isLandingShown = false
                blurRadius = 0
            } label: {
                Text("Continue")
                    .padding()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
