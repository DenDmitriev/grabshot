//
//  PlayheadViewNew.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 10.01.2024.
//

import SwiftUI

struct PlayheadView: View {
    @Binding var bounds: ClosedRange<Duration>
    @Binding var playhead: Duration
    @State var size: CGSize = .zero
    @Binding var frameRate: Double
    @State private var showPopover = false
    let head: CGFloat = 20
    let thickness: CGFloat = 4
    @State private var stepWidthInPixel: CGFloat = .zero
    static let scrollId: String = "Playhead"
    
    var body: some View {
        // Вычисление исходного положения курсора
        let playheadLocationX = CGFloat(playhead.seconds) * stepWidthInPixel
        let playheadLocationY = size.height / 2
        
        PlayheadShape(head: head, thickness: thickness)
            .fill(Color.accentColor)
            .onChange(of: bounds) { newBounds in
                stepWidthInPixel = calcStep(bounds: newBounds)
            }
            .id(Self.scrollId)
            .popover(isPresented: $showPopover, content: {
                contextView(value: playhead)
            })
            .frame(width: head)
            .background {
                PlayheadShape(head: head, thickness: thickness)
                    .stroke(.black.opacity(0.25), style: .init(lineWidth: 1, lineCap: .round, lineJoin: .round))
            }
            .position(CGPoint(x: playheadLocationX, y: playheadLocationY))
            .readSize(onChange: { size in
                self.size = size
                stepWidthInPixel = calcStep(bounds: bounds)
            })
            .gesture(
                DragGesture()
                    .onChanged{ dragValue in
                        showContext(isShow: true)
                        let dragLocation = dragValue.location
                        let xThumbOffset = min(dragLocation.x, size.width)
                        
                        var newValue = xThumbOffset / stepWidthInPixel // convert back the value bound
                        newValue = min(newValue, bounds.upperBound.seconds)
                        newValue = max(newValue, bounds.lowerBound.seconds)
                        
                        // Stop the range thumbs from colliding each other
                        let newCursor = Duration.seconds(newValue)
                        if bounds ~= newCursor {
                            playhead = newCursor
                        }
                    }
                    .onEnded { dragValue in
                        showContext(isShow: false)
                    }
            )
    }
    
    private func calcStep(bounds: ClosedRange<Duration>) -> CGFloat {
        // Длина общего диапазона
        let sliderBound = bounds.upperBound.seconds - bounds.lowerBound.seconds
        // Шаг в пикселях на 1 секунду
        let stepWidthInPixel = size.width / sliderBound
        return stepWidthInPixel
    }
    
    private func contextView(value: Duration) -> some View {
        Text(value.formatted(.timecode(frameRate: frameRate)))
            .lineLimit(1)
            .font(.callout.weight(.light))
            .frame(width: AppGrid.pt72)
            .padding(AppGrid.pt8)
    }
    
    private func showContext(isShow: Bool) {
        withAnimation(.easeInOut(duration: 0.25)) {
            showPopover = isShow
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        
        @State var bounds: ClosedRange<Duration> = .init(uncheckedBounds: (lower: .seconds(0), upper: .seconds(100)))
        @State var playhead: Duration = .seconds(50)
        @State var frameRate: Double = 25
        
        var body: some View {
            PlayheadView(
                bounds: $bounds,
                playhead: $playhead,
                frameRate: $frameRate
            )
        }
    }
    
    return PreviewWrapper()
        .padding()
}
