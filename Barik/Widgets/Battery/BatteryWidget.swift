//
//  BatteryWidgetTest.swift
//  Barik
//
//  Created by Pengy X on 12/24/25.
//
import SwiftUI

struct BatteryWidget: View {
    let showPercentage: Bool
    let warningLevel: Int
    let criticalLevel: Int

    @StateObject private var batteryManager = BatteryManager()
    private var level: Int { batteryManager.batteryLevel }
    private var isCharging: Bool { batteryManager.isCharging }
    private var isPluggedIn: Bool { batteryManager.isPluggedIn }

    @State private var rect: CGRect = CGRect()

    var body: some View {
        ZStack {
            ZStack(alignment: .leading) {
                BatteryBodyView(mask: false, showPercentage: showPercentage)
                    .opacity(showPercentage ? 0.3 : 0.4)
                BatteryBodyView(mask: true, showPercentage: showPercentage)
                    .clipShape(
                        Rectangle().path(
                            in: CGRect(
                                x: showPercentage ? 0 : 2,
                                y: 0,
                                width: 30 * Int(level)
                                    / (showPercentage ? 110 : 130),
                                height: .bitWidth
                            )
                        )
                    )
                    .foregroundStyle(batteryColor)
                BatteryText(
                    level: level,
                    isCharging: isCharging,
                    isPluggedIn: isPluggedIn,
                    showPercentage: showPercentage
                )
                .foregroundStyle(batteryTextColor)
            }
            .frame(width: 30, height: 10)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            rect = geometry.frame(in: .global)
                        }
                        .onChange(of: geometry.frame(in: .global)) {
                            oldState, newState in
                            rect = newState
                        }
                }
            )
        }
//      .experimentalConfiguration(cornerRadius: 15)
        .frame(maxHeight: .infinity)
        .background(.black.opacity(0.001))
        .onTapGesture {
            MenuBarPopup.show(rect: rect, id: "battery") { BatteryPopup() }
        }
    }

    private var batteryTextColor: Color {
        if isCharging {
            return .foregroundOutsideInvert
        } else {
            return level > warningLevel ? .foregroundOutsideInvert : .black
        }
    }

    private var batteryColor: Color {
        if isCharging {
            return .green
        } else {
            if level <= criticalLevel {
                return .red
            } else if level <= warningLevel {
                return .yellow
            } else {
                return .icon
            }
        }
    }
}

private struct BatteryText: View {
    let level: Int
    let isCharging: Bool
    let isPluggedIn: Bool
    let showPercentage: Bool

    var body: some View {
        HStack(alignment: .center, spacing: -1) {
            if showPercentage {
                Text("\(level)")
                    .font(.system(size: 12))
                    .transition(.blurReplace)
            }

            if isCharging && level != 100 {
                Image(systemName: "bolt.fill")
                    .font(.system(size: showPercentage ? 8 : 10))
            }

            if !isCharging && isPluggedIn && level != 100 {
                Image(systemName: "powerplug.portrait.fill")
                    .font(.system(size: 8))
                    .padding(.leading, 1)
            }
        }
        .foregroundStyle(
            showPercentage ? .foregroundOutsideInvert : .foregroundOutside
        )
        .fontWeight(.semibold)
        .transition(.blurReplace)
        .animation(.smooth, value: isCharging)
        .frame(width: 26, height: 15)
    }
}

private struct BatteryBodyView: View {
    let mask: Bool
    let showPercentage: Bool

    var body: some View {
        ZStack {
            if showPercentage || !mask {
                Image(systemName: "battery.0")
                    .resizable()
                    .scaledToFit()
            }
            if showPercentage || mask {
                Rectangle()
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                    .padding(.horizontal, showPercentage ? 3 : 4.4)
                    .padding(.vertical, showPercentage ? 2 : 3.5)
                    .offset(
                        x: showPercentage ? -2 : -1.77,
                        y: showPercentage ? 0 : 0.2)
            }
        }
        .compositingGroup()
    }
}

struct BatteryWidget_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            BatteryWidget(
                showPercentage: true,
                warningLevel: 30,
                criticalLevel: 10
            )
        }.frame(width: 200, height: 100)
            .background(.yellow)
    }
}
