//
//  File.swift
//  Draw Beat Maker
//
//  Created by Kasper Munch on 13/04/2022.
//

import Foundation
import PencilKit

class AudioPlayer: ObservableObject {
    private var oscillator = Oscillator()
    private var synth = Synth()
    
    private (set) var stroke: PKStroke?
    private (set) var isActive = false
    
    private var index = 0
    
    init() {
    }
    
    func update() {
        /*
         Compare current play position to where the next stroke point is.
         */
        while Session.shared.currentPlayPosition > stroke!.path[index].location.x {
            index += 1
            if index >= stroke!.path.count {
                isActive = false
                stop()
                break
            }
        }
        setSynthFrequency(with: stroke!.path[index].location)
    }
    
    func start(with stroke: PKStroke) {
        synth.start()
        self.isActive = true
        self.stroke = stroke
        updateSound()
    }
    
    func stop() {
        index = 0
        synth.stop()
        Session.shared.audioPlayerQueue.append(self)
        Session.shared.activeAudioPlayers.removeAll(where: { player in
            player.isActive == false
        })
    }
    
    private func setSynthFrequency(with point: CGPoint) {
        synth.frequency = ((1.0 - Float(point.y) / Float((Session.shared.geometry?.size.height ?? 0))) * 600 + 32)
    }
    
    private func setSynthAmplitude(with point: CGPoint) {
        // TODO: - Set the amplitude according to pen pressure
        // Oscillator.amplitude = Float((geometry.size.height - coord.y) / geometry.size.height)
    }
    
    private func updateSound() {
        switch stroke!.ink.color {
        case .green:
            synth.setWaveformTo(Oscillator.sawtooth)
        case .yellow:
            synth.setWaveformTo(Oscillator.square)
        case .purple:
            synth.setWaveformTo(Oscillator.triangle)
        case .blue:
            synth.setWaveformTo(Oscillator.whiteNoise)
        default:
            synth.setWaveformTo(Oscillator.sine)
        }
    }
}
