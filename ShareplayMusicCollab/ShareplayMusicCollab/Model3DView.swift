//
//  Model3DView.swift
//  ShareplayMusicCollab
//
//  Created by Mosadoluwa Obatusin on 9/14/24.
//

import SwiftUI
import RealityKit

struct Model3DView: View {
    var modelName: String
    @State private var angle: Angle = .degrees(0)

    var body: some View {
            VStack(spacing: 18.0) {
                Model3D(named: modelName) { model in
                    switch model {
                    case .empty:
                        ProgressView()
                    case .success(let resolvedModel3D):
                        resolvedModel3D
//                            .scaleEffect(0.1)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .rotation3DEffect(angle, axis: .x)
                            .rotation3DEffect(angle, axis: .y)
                            .animation(.linear(duration: 18).repeatForever(), value: angle)
                            .onAppear {
                                angle = .degrees(359)
                            }
                    case .failure(let error):
                        Text(error.localizedDescription)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
    }
