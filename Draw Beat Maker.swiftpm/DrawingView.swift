//
//  File.swift
//  Draw Beat Maker
//
//  Created by Kasper Munch on 07/04/2022.
//

import SwiftUI
import PencilKit

struct Grid: View {
    let geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            ForEach(0..<21, id: \.self) { i in
                Rectangle()
                    .frame(width: geometry.size.width, height: 2)
                    .position(x: geometry.size.width/2, y: (geometry.size.height/20)*CGFloat(i))
                    .foregroundColor(.blue)
                    .opacity(0.4)
                
                Rectangle()
                    .frame(width: 2, height: geometry.size.height)
                    .position(x: (geometry.size.width/20)*CGFloat(i), y: geometry.size.height/2)
                    .foregroundColor(.blue)
                    .opacity(0.4)
            }
        }
    }
}

struct ColoredButton: View {
    @Binding var isActive: Bool
    let color: Color
    let onTap: (_ color: Color) -> Void
    
    var body: some View {
        if color == .clear {
            Button {
                onTap(color)
                isActive = true
            } label: {
                if isActive {
                    Image(systemName: "pencil.slash")
                        .imageScale(.large)
                        .frame(width: 40, height: 40)
                } else {
                    Image(systemName: "pencil.slash")
                        .imageScale(.large)
                        .frame(width: 40, height: 40)
                }
            }
            .buttonStyle(BorderedProminentButtonStyle())
        } else {
            if isActive {
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: 80, height: 80)
                    .foregroundColor(color)
                    .onTapGesture {
                        onTap(color)
                        isActive = true
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(lineWidth: 8)
                            .foregroundColor(color)
                    )
            }
            else {
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: 80, height: 80)
                    .foregroundColor(color)
                    .onTapGesture {
                        onTap(color)
                        isActive = true
                    }
            }
        }
    }
}

struct DrawingView: View {
    @State private var canvasView = PKCanvasView()
    @StateObject private var viewModel = DrawingViewModel()
    
    @State private var yellowActive = true
    @State private var greenActive = false
    @State private var blueActive = false
    @State private var purpleActive = false
    @State private var redActive = false
    @State private var eraserActive = false
    
    @State private var isGridShown = false
    
    @Binding var isHelpShown: Bool
    @Binding var blurRadius: CGFloat
    
    var body: some View {
        GeometryReader { geometry in 
            ZStack {
                // Drawing canvas
                CanvasView(canvasView: $canvasView)
                
                // Current playback indicator
                Rectangle()
                    .frame(width: 2, height: geometry.size.height * 2)
                    .position(x: viewModel.currentPlayPosition, y: 0)
                
                // Grid
                if isGridShown {
                    Grid(geometry: geometry)
                        .allowsHitTesting(false)
                }
                
                HStack {
                    VStack {
                        Spacer()
                        HStack {
                            
                            // Play button
                            Button {
                                viewModel.isPlaying.toggle()
                                if viewModel.isPlaying {
                                    Session.shared.strokes = canvasView.drawing.strokes
                                    viewModel.play()
                                } else {
                                    viewModel.stop()
                                }
                            } label: {
                                if viewModel.isPlaying {
                                    withAnimation(.spring(), {
                                        Image(systemName: "stop.fill")
                                            .frame(width: 80, height: 80)
                                    })
                                } else {
                                    withAnimation(.spring(), {
                                        Image(systemName: "play.fill")
                                            .frame(width: 80, height: 80)
                                    })
                                }
                            }
                            .padding()
                            .buttonStyle(BorderedProminentButtonStyle())
                            
                            ColoredButton(isActive: $yellowActive, color: .yellow, onTap: onColorButtonTap(color:))
                            ColoredButton(isActive: $greenActive, color: .green, onTap: onColorButtonTap(color:))
                            ColoredButton(isActive: $blueActive, color: .blue, onTap: onColorButtonTap(color:))
                            ColoredButton(isActive: $purpleActive, color: .purple, onTap: onColorButtonTap(color:))
                            ColoredButton(isActive: $redActive, color: .red, onTap: onColorButtonTap(color:))
                            ColoredButton(isActive: $eraserActive, color: .clear, onTap: onColorButtonTap(color:))
                        }
                    }
                    
                    Spacer()
                    VStack {
                        
                        // Help button
                        Button {
                            blurRadius = 20
                            isHelpShown = true
                            saveToFile()
                        } label: {
                            Text("?")
                                .frame(width: 40, height: 40)
                        }
                        .buttonStyle(BorderedProminentButtonStyle())
                        
                        // Grid button
                        Button {
                            isGridShown.toggle()
                        } label: {
                            Image(systemName: "grid")
                                .frame(width: 40, height: 40)
                        }
                        .buttonStyle(BorderedProminentButtonStyle())
                        
                        // Delete all button (trash can)
                        Button {
                            canvasView.drawing = PKDrawing()
                            Session.shared.strokes = canvasView.drawing.strokes
                            viewModel.stop()
                        } label: {
                            Image(systemName: "trash.fill")
                                .frame(width: 40, height: 40)
                        }
                        .buttonStyle(BorderedProminentButtonStyle())
                        
                        
                        Spacer()
                    }
                }
                .padding()
            }
            .onAppear {
                Session.shared.geometry = geometry
                loadFromFile()
            }
        }
    }
    
    private func loadFromFile() {
        do {
            let data = NSDataAsset(name: "initDrawing")?.data
            let drawing = try PKDrawing(data: data!)
            self.canvasView.drawing = drawing
        } catch {
            print("Error", error.localizedDescription)
        }
    }
    
    private func saveToFile() {
        let data = self.canvasView.drawing.dataRepresentation()
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("openingDrawing")
        
        do {
            try data.write(to: path)
        } catch {
            print("Could not save data.")
        }
    }
    
    private func onColorButtonTap(color: Color) {
        withAnimation(.spring(), {
            yellowActive = false
            greenActive = false
            blueActive = false
            purpleActive = false
            redActive = false
        })
        
        switch color {
        case .red:
            canvasView.tool = PKInkingTool(.pen, color: .red, width: 10)
        case .blue:
            canvasView.tool = PKInkingTool(.pen, color: .blue, width: 10)
        case .yellow:
            canvasView.tool = PKInkingTool(.pen, color: .yellow, width: 10)
        case .green:
            canvasView.tool = PKInkingTool(.pen, color: .green, width: 10)
        case .purple:
            canvasView.tool = PKInkingTool(.pen, color: .purple, width: 10)
        case .clear:
            canvasView.tool = PKEraserTool(.vector)
        default:
            canvasView.tool = PKInkingTool(.pen, color: .red, width: 10)
            
        }
    }
}
