//
//  File.swift
//  Draw Beat Maker
//
//  Created by Kasper Munch on 08/04/2022.
//

import SwiftUI
import PencilKit

class Session {
    static var shared = Session()
    var playbackTime: Double = 8 // 8 seconds in playback time
    var geometry: GeometryProxy?
    var currentPlayPosition: CGFloat = 0 // Current global playing position
    var strokes: [PKStroke] = []
    var audioPlayerQueue: [AudioPlayer] = []
    var activeAudioPlayers: [AudioPlayer] = []
    
    /// Do all setup of strokes and sorting when the user presses the play button.
    /// This is done asynchronously as to not keep the user waiting and reduce
    /// the waiting time on play start.
    func prepare() async {
        // Do initial setup of Audio Players
        if audioPlayerQueue.isEmpty {
            for _ in 1...3 {
                let audioPlayer = AudioPlayer()
                Session.shared.audioPlayerQueue.append(audioPlayer)
            }
        }
        
        // Flip strokes if necessary
        var removedCounter = 0
        for (index, stroke) in strokes.enumerated() {
            guard let first = stroke.path.first, let last = stroke.path.last else {
                continue
            }
            
            // Flip the path if it ends before it begins
            if first.location.x > last.location.x {
                let reversed = stroke.path.reversed()
                let newPath = PKStrokePath(controlPoints: reversed, creationDate: Date.now)
                let newStroke = PKStroke(ink: stroke.ink, path: newPath)

                strokes.remove(at: index - removedCounter)
                strokes.append(newStroke)
                removedCounter += 1
            }
        }
        
        strokes.sort { stroke1, stroke2 in
            if let p1 = stroke1.path.first, let p2 = stroke2.path.first {
                if p1.location.x < p2.location.x {
                    return true
                }
            }
            return false
        }
    }
    
    func reset() {
        audioPlayerQueue.forEach({ player in
            player.stop()
        })
        
        activeAudioPlayers.forEach({ player in
            player.stop()
        })
        
        currentPlayPosition = 0
    }
}
