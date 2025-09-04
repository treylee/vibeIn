// Path: vibeIn/BizzPortal/Components/DashboardFlowLayout.swift

import SwiftUI

// MARK: - Dashboard Flow Layout
// This is a custom Layout protocol implementation for creating a flow layout
// It automatically wraps content to the next line when it doesn't fit
@available(iOS 16.0, *)
struct DashboardFlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return CGSize(width: proposal.replacingUnspecifiedDimensions().width, height: result.height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for row in result.rows {
            for item in row.items {
                let frame = CGRect(
                    x: bounds.minX + item.x,
                    y: bounds.minY + row.y,
                    width: item.width,
                    height: row.height
                )
                subviews[item.index].place(at: frame.origin, proposal: ProposedViewSize(frame.size))
            }
        }
    }
    
    struct FlowResult {
        var rows: [Row] = []
        var height: CGFloat = 0
        
        struct Row {
            var items: [Item] = []
            var y: CGFloat = 0
            var height: CGFloat = 0
        }
        
        struct Item {
            let index: Int
            let x: CGFloat
            let width: CGFloat
        }
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentRow = Row()
            var x: CGFloat = 0
            var y: CGFloat = 0
            
            for (index, subview) in subviews.enumerated() {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > width && !currentRow.items.isEmpty {
                    currentRow.y = y
                    rows.append(currentRow)
                    y += currentRow.height + spacing
                    currentRow = Row()
                    x = 0
                }
                
                currentRow.items.append(Item(index: index, x: x, width: size.width))
                currentRow.height = max(currentRow.height, size.height)
                x += size.width + spacing
            }
            
            if !currentRow.items.isEmpty {
                currentRow.y = y
                rows.append(currentRow)
                y += currentRow.height
            }
            
            height = y
        }
    }
}

// MARK: - Example Usage View
// This demonstrates how to use DashboardFlowLayout
struct DashboardFlowLayoutExample: View {
    let tags = ["Swift", "SwiftUI", "iOS", "Development", "Mobile", "App", "Design", "User Interface"]
    
    var body: some View {
        if #available(iOS 16.0, *) {
            DashboardFlowLayout(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(15)
                }
            }
            .padding()
        } else {
            // Fallback for iOS 15 and earlier
            FlowLayoutFallback(tags: tags)
        }
    }
}

// MARK: - Fallback for iOS 15 and earlier
struct FlowLayoutFallback: View {
    let tags: [String]
    
    var body: some View {
        // Simple wrapping HStack fallback for older iOS versions
        VStack(alignment: .leading, spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(15)
            }
        }
        .padding()
    }
}

// Preview for the example usage, not the layout itself
#Preview("Flow Layout Example") {
    DashboardFlowLayoutExample()
}
