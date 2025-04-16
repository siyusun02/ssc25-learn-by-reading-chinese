import AVFoundation
import SwiftUI

class SpeechHelper: NSObject {
    var synth: AVSpeechSynthesizer
    
    let locale: String = "zh-CN"
    
    @Binding var isPlaying: Bool
    
    override init() {
        self.synth = AVSpeechSynthesizer()
        self._isPlaying = .constant(false)
        super.init()
        self.synth.delegate = self
    }

    
    func speak(text: String, isPlaying: Binding<Bool>) {
        self._isPlaying = isPlaying
        synth.stopSpeaking(at: .immediate) // prevent overlap
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: locale)
        
        synth.speak(utterance)
    }
    
    func stop() {
        synth.stopSpeaking(at: .immediate)
    }
}

extension SpeechHelper: AVSpeechSynthesizerDelegate  {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.isPlaying = false
    }
}


