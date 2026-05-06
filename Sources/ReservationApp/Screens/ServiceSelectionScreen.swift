import SwiftUI

struct ServiceSelectionScreen: View {
    @State private var selectedService: Service? = nil
    @State private var goToDateTime = false

    var body: some View {
        VStack(spacing: 20) {
            Text("서비스 선택")
                .font(.title)
                .fontWeight(.bold)
                .accessibilityIdentifier("service_selection_title")

            Text("원하시는 서비스를 선택해주세요")
                .font(.subheadline)
                .foregroundColor(.secondary)

            List(sampleServices) { service in
                HStack {
                    Text(service.name)
                        .font(.body)
                    Spacer()
                    if selectedService?.id == service.id {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedService = service
                }
                .accessibilityIdentifier("service_\(service.name)")
            }
            .listStyle(.insetGrouped)

            Button("다음") {
                if selectedService != nil {
                    goToDateTime = true
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedService == nil)
            .padding(.horizontal, 32)
            .accessibilityIdentifier("next_button")

            Spacer()
        }
        .navigationDestination(isPresented: $goToDateTime) {
            if let service = selectedService {
                DateTimeSelectionScreen(selectedService: service)
            }
        }
    }
}

#Preview {
    ServiceSelectionScreen()
}
