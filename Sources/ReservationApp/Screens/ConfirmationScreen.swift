import SwiftUI

struct ConfirmationScreen: View {
    let selectedService: Service
    let selectedDate: String
    let selectedTime: String
    @State private var goToComplete = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("예약 확인")
                .font(.title)
                .fontWeight(.bold)
                .accessibilityIdentifier("confirmation_title")

            VStack(spacing: 16) {
                HStack {
                    Text("서비스")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(selectedService.name)
                        .fontWeight(.semibold)
                }
                Divider()
                HStack {
                    Text("날짜")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(selectedDate)
                        .fontWeight(.semibold)
                }
                Divider()
                HStack {
                    Text("시간")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(selectedTime)
                        .fontWeight(.semibold)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 32)

            Button("예약 확정") {
                goToComplete = true
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 32)
            .accessibilityIdentifier("confirm_button")

            Spacer()
        }
        .navigationDestination(isPresented: $goToComplete) {
            CompleteScreen(
                service: selectedService.name,
                date: selectedDate,
                time: selectedTime
            )
        }
    }
}

#Preview {
    ConfirmationScreen(
        selectedService: sampleServices[0],
        selectedDate: "5월 7일 (목)",
        selectedTime: "09:00"
    )
}
