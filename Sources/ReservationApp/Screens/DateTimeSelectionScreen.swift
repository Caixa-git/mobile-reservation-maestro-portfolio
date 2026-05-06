import SwiftUI

struct DateTimeSelectionScreen: View {
    let selectedService: Service
    @State private var selectedDate: String? = nil
    @State private var selectedTime: String? = nil
    @State private var goToConfirmation = false

    var body: some View {
        VStack(spacing: 20) {
            Text("날짜 및 시간 선택")
                .font(.title)
                .fontWeight(.bold)
                .accessibilityIdentifier("datetime_title")

            Text("서비스: \(selectedService.name)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                Text("날짜 선택")
                    .font(.headline)

                HStack {
                    ForEach(sampleDates, id: \.1) { date, id in
                        Button(date) {
                            selectedDate = date
                        }
                        .buttonStyle(.bordered)
                        .tint(selectedDate == date ? .blue : .gray)
                        .accessibilityIdentifier(id)
                    }
                }
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                Text("시간 선택")
                    .font(.headline)

                HStack {
                    ForEach(sampleTimes.prefix(3), id: \.1) { time, id in
                        Button(time) {
                            selectedTime = time
                        }
                        .buttonStyle(.bordered)
                        .tint(selectedTime == time ? .blue : .gray)
                        .accessibilityIdentifier(id)
                    }
                }
            }
            .padding(.horizontal)

            Button("다음") {
                if selectedDate != nil && selectedTime != nil {
                    goToConfirmation = true
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedDate == nil || selectedTime == nil)
            .padding(.horizontal, 32)
            .accessibilityIdentifier("next_button")

            Spacer()
        }
        .navigationDestination(isPresented: $goToConfirmation) {
            ConfirmationScreen(
                selectedService: selectedService,
                selectedDate: selectedDate ?? "",
                selectedTime: selectedTime ?? ""
            )
        }
    }
}

#Preview {
    DateTimeSelectionScreen(selectedService: sampleServices[0])
}
