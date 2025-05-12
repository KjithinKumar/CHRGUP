//
//  ChargingStausLiveActivityLiveActivity.swift
//  ChargingStausLiveActivity
//
//  Created by Jithin Kamatham on 25/04/25.
//

import ActivityKit
import WidgetKit
import SwiftUI
import UIKit



struct ChargingLiveStausLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ChargingLiveActivityAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack(alignment: .leading){
                HStack(){
                    Text(context.state.chargingTitle)
                        .font(.headline)
                    Spacer()
                    AppLogo(size: 30)
                }
                HStack(){
                    VStack{
                        Text(context.attributes.energyTitle)
                            .font(.caption)
                        Text(context.state.energy)
                            .font(.title3)
                    }
                    Spacer()
                    VStack{
                        Text(context.attributes.timeTitle)
                            .font(.caption)
                        Text(context.state.time)
                            .font(.title3)
                    }
                }
                .padding()
            }
            .padding()
            .activityBackgroundTint(Color(.systemBackground))
            .activitySystemActionForegroundColor(Color.blue)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                }
                DynamicIslandExpandedRegion(.trailing) {
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .center){
                        HStack(){
                            Text(context.state.chargingTitle)
                                .font(.headline)
                                .foregroundStyle(.green)
                            Spacer()
                            AppLogo(size: 30)
                        }
                        HStack(){
                            VStack{
                                Text(context.attributes.energyTitle)
                                    .font(.caption)
                                Text(context.state.energy)
                                    .font(.title3)
                            }
                            Spacer()
                            VStack{
                                Text(context.attributes.timeTitle)
                                    .font(.caption)
                                Text(context.state.time)
                                    .font(.title3)
                            }
                        }
                        .padding()
                        
                    }
                    
                    .activityBackgroundTint(Color.gray)
                    .activitySystemActionForegroundColor(Color.black)
                    // more content
                }
            } compactLeading: {
                AppLogo(size: 20)
            } compactTrailing: {
                let originalString = context.state.time
                // Remove "h" and "m" and split
                let components = originalString
                    .replacingOccurrences(of: "h", with: "")
                    .replacingOccurrences(of: "m", with: "")
                    .split(separator: ":")

                if components.count == 2,
                   let hours = Int(components[0].trimmingCharacters(in: .whitespaces)),
                   let minutes = Int(components[1].trimmingCharacters(in: .whitespaces)) {
                    
                    let totalMinutes = hours * 60 + minutes
                    let minutesString = "\(totalMinutes) min"
                    Text(minutesString)
                        .font(.footnote)
                }
                
            } minimal: {
                AppLogo(size: 20)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension ChargingLiveActivityAttributes {
    fileprivate static var preview: ChargingLiveActivityAttributes {
        ChargingLiveActivityAttributes(timeTitle: "Time Consumed", energyTitle: "Units Consumed")
    }
}

extension ChargingLiveActivityAttributes.ContentState {
    fileprivate static var smiley: ChargingLiveActivityAttributes.ContentState {
        ChargingLiveActivityAttributes.ContentState(time: "00h:00m",energy: "0.000kWH", title: "Charging is in Progress")
     }
     
     fileprivate static var starEyes: ChargingLiveActivityAttributes.ContentState {
         ChargingLiveActivityAttributes.ContentState(time : "00h:12m", energy: "0.001kWH", title: "Charging is in Progress")
     }
}

#Preview("Notification", as: .content, using: ChargingLiveActivityAttributes.preview) {
   ChargingLiveStausLiveActivity()
} contentStates: {
    ChargingLiveActivityAttributes.ContentState.smiley
    ChargingLiveActivityAttributes.ContentState.starEyes
}

#Preview("Live Activity (Dynamic Island)", as: .dynamicIsland(.expanded), using: ChargingLiveActivityAttributes.preview) {
    ChargingLiveStausLiveActivity()
} contentStates: {
    ChargingLiveActivityAttributes.ContentState.smiley
}

#Preview("Live Activity (Compact)", as: .dynamicIsland(.compact), using: ChargingLiveActivityAttributes.preview) {
    ChargingLiveStausLiveActivity()
} contentStates: {
    ChargingLiveActivityAttributes.ContentState.smiley
}
#Preview("Live Activity (Compact - Leading & Trailing)", as: .dynamicIsland(.minimal),using: ChargingLiveActivityAttributes.preview) {
    ChargingLiveStausLiveActivity()
} contentStates: {
    ChargingLiveActivityAttributes.ContentState.smiley
}

struct AppLogo: View {
    let size: CGFloat
    
    var body: some View {
        Image(systemName: "bolt.car.fill")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(.green)
    }
}

