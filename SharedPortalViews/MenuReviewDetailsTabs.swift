import SwiftUI

struct TabbedDetailsView: View {
    let menuItems: [String]
    let reviews: [GPlaceDetails.Review]
    
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 12) {
            Picker("Details", selection: $selectedTab) {
                Text("Menu").tag(0)
                Text("Google").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            if selectedTab == 0 {
                ForEach(menuItems, id: \.self) { item in
                    Text("🍽️ \(item)")
                        .padding()
                        .background(Color.white.opacity(0.4))
                        .cornerRadius(12)
                }
            } else {
                ForEach(reviews, id: \.text.text) { review in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(review.authorAttribution?.displayName ?? "Anonymous")
                                .font(.headline)
                            Spacer()
                            Text("⭐️ \(review.rating ?? 0)")
                                .font(.subheadline)
                        }
                        Text(review.text.text)
                            .font(.body)
                        if let time = review.publishTime {
                            Text(time)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Divider()
                    }
                    .padding()
                    .background(Color.white.opacity(0.4))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
