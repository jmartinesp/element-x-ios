//
// Copyright 2023 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import SwiftUI

struct LocationRoomTimelineView: View {
    let timelineItem: LocationRoomTimelineItem
    
    var body: some View {
        TimelineStyler(timelineItem: timelineItem) {
            mainContent
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(accessibilityLabel)
        }
    }
                                    
    @ViewBuilder
    private var mainContent: some View {
        if let geoURI = timelineItem.content.geoURI {
            VStack(alignment: .leading, spacing: 0) {
                descriptionView
                    .frame(maxWidth: mapAspectRatio * mapMaxHeight, alignment: .leading)
                
                MapLibreStaticMapView(geoURI: geoURI, mapSize: .init(width: mapAspectRatio * mapMaxHeight, height: mapMaxHeight)) {
                    LocationMarkerView()
                }
                .frame(maxHeight: mapMaxHeight)
                .aspectRatio(mapAspectRatio, contentMode: .fit)
                .clipped()
            }
        } else {
            FormattedBodyText(text: timelineItem.body, additionalWhitespacesCount: timelineItem.additionalWhitespaces())
        }
    }

    // MARK: - Private
    
    private var accessibilityLabel: String {
        if let description = timelineItem.content.description {
            return "\(L10n.commonSharedLocation), \(description)"
        }
        
        return L10n.commonSharedLocation
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let description = timelineItem.content.description, !description.isEmpty {
            FormattedBodyText(text: description)
                .padding(8)
        }
    }

    private let mapAspectRatio: Double = 3 / 2
    private let mapMaxHeight: Double = 300
}

private extension MapLibreStaticMapView {
    init(geoURI: GeoURI, mapSize: CGSize, @ViewBuilder pinAnnotationView: () -> PinAnnotation) {
        self.init(coordinates: .init(latitude: geoURI.latitude, longitude: geoURI.longitude),
                  zoomLevel: 15,
                  attributionPlacement: .bottomLeft,
                  mapTilerStatic: MapTilerStaticMap(baseURL: ServiceLocator.shared.settings.mapTilerBaseURL,
                                                    key: ServiceLocator.shared.settings.mapTilerApiKey),
                  mapSize: mapSize,
                  pinAnnotationView: pinAnnotationView)
    }
}

struct LocationRoomTimelineView_Previews: PreviewProvider, TestablePreview {
    static let viewModel = TimelineViewModel.mock

    static var previews: some View {
        ScrollView {
            VStack(spacing: 8) {
                states
            }
        }
        .environmentObject(viewModel.context)
        .previewDisplayName("Bubbles")
    }

    @ViewBuilder
    static var states: some View {
        LocationRoomTimelineView(timelineItem: .init(id: .random,
                                                     timestamp: "Now",
                                                     isOutgoing: false,
                                                     isEditable: false,
                                                     canBeRepliedTo: true,
                                                     isThreaded: false,
                                                     sender: .init(id: "Bob"),
                                                     content: .init(body: "Fallback geo uri description")))

        LocationRoomTimelineView(timelineItem: .init(id: .random,
                                                     timestamp: "Now",
                                                     isOutgoing: false,
                                                     isEditable: false,
                                                     canBeRepliedTo: true,
                                                     isThreaded: false,
                                                     sender: .init(id: "Bob"),
                                                     content: .init(body: "Fallback geo uri description",
                                                                    geoURI: .init(latitude: 41.902782, longitude: 12.496366), description: "Location description description description description description description description description")))
        LocationRoomTimelineView(timelineItem: .init(id: .random,
                                                     timestamp: "Now",
                                                     isOutgoing: false,
                                                     isEditable: false,
                                                     canBeRepliedTo: true,
                                                     isThreaded: true,
                                                     sender: .init(id: "Bob"),
                                                     content: .init(body: "Fallback geo uri description",
                                                                    geoURI: .init(latitude: 41.902782, longitude: 12.496366), description: "Location description description description description description description description description"),
                                                     replyDetails: .loaded(sender: .init(id: "Someone"),
                                                                           eventID: "123",
                                                                           eventContent: .message(.text(.init(body: "The thread content goes 'ere."))))))
    }
}
