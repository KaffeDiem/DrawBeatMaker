//
//  File.swift
//  Draw Beat Maker
//
//  Created by Kasper Munch on 07/04/2022.
//

import SwiftUI
import PencilKit

struct CanvasView: View {
    @Binding var canvasView: PKCanvasView
    @State var toolPicker = PKToolPicker()
    
    init(canvasView: Binding<PKCanvasView>) {
        self._canvasView = canvasView
        toolPicker.selectedTool = PKInkingTool(.pen, color: .yellow, width: 10)
    }
}

extension CanvasView: UIViewRepresentable {
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .gray, width: 10)
        canvasView.drawingPolicy = .anyInput
        showToolPicker()
        canvasView.delegate = context.coordinator
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(canvasView: $canvasView)
    }
}

private extension CanvasView {
    func showToolPicker() {
        toolPicker.setVisible(false, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }
}

class Coordinator: NSObject {
    var canvasView: Binding<PKCanvasView>
    
    init(canvasView: Binding<PKCanvasView>) {
        self.canvasView = canvasView
    }
}

extension Coordinator: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        if !canvasView.drawing.bounds.isEmpty {
            Session.shared.strokes = canvasView.drawing.strokes
        }
    }
}
