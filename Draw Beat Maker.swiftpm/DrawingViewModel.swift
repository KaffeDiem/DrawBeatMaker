//
//  File.swift
//  Draw Beat Maker
//
//  Created by Kasper Munch on 09/04/2022.
//

import Foundation
import SwiftUI

class DrawingViewModel: ObservableObject {
    
    @Published var currentPlayPosition: CGFloat = 0 // X-coordinate for playing indicator
    @Published var isPlaying = false
    
    private var displayLink: CADisplayLink?
    private var elapsedTime: Double?
    private var startTime: Double?
    
    private func createDisplayLink() {
        guard displayLink == nil else { return }
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .current, forMode: .default)
    }
    
    private func destroyDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    // Update the currently playing sound (called every tick by Display Link)
    @objc func update(displayLink: CADisplayLink) {
        if startTime == nil {
            startTime = displayLink.timestamp
        }
        
        elapsedTime = displayLink.timestamp - startTime!
        
        guard elapsedTime! < Session.shared.playbackTime else {
            stop()
            return // Stop updating if we do not want to play
        }
        
        if let screenWidth = Session.shared.geometry?.size.width, let playTime = self.elapsedTime {
            Session.shared.currentPlayPosition = screenWidth / CGFloat(Session.shared.playbackTime) * playTime
            self.currentPlayPosition = Session.shared.currentPlayPosition
        }
        
        // Update the active audio players with new frequencies.
        Session.shared.activeAudioPlayers.forEach { player in
            player.update()
        }
        
        guard let nextStrokeXPosition = Session.shared.strokes.first?.path.first?.location.x else {
            return
        }
        
        if Session.shared.currentPlayPosition > nextStrokeXPosition {
            // Pop an AudioPlayer if one is avaiable and start it.
            if !Session.shared.audioPlayerQueue.isEmpty {
                let audioPlayer = Session.shared.audioPlayerQueue.removeFirst()
                let stroke = Session.shared.strokes.removeFirst()
                audioPlayer.start(with: stroke)
                Session.shared.activeAudioPlayers.append(audioPlayer)
            }
        }
    }
    
    func play() {
        Task {
            await Session.shared.prepare()
        }
        createDisplayLink()
    }
    
    func stop() {
        destroyDisplayLink()
        startTime = nil
        isPlaying = false
        Session.shared.reset()
    }
}
