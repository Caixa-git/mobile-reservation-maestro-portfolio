import SwiftUI

struct HomeScreen: View {
    @State private var goToReservation = false
    @AppStorage("reservationNumber") private var reservationNumber: String = ""

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("환영합니다!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .accessibilityIdentifier("welcome_text")

            Text("간편하게 예약하고 관리하세요")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            VStack(spacing: 16) {
                Button("예약하기") {
                    goToReservation = true
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 32)
                .accessibilityIdentifier("reserve_button")

                if !reservationNumber.isEmpty {
                    NavigationLink("내 예약 보기") {
                        ReservationDetailScreen()
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 32)
                    .accessibilityIdentifier("my_reservations_button")
                }
            }

            Text("서비스를 선택하고 원하는 날짜와 시간에 예약하세요")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
        .navigationDestination(isPresented: $goToReservation) {
            ServiceSelectionScreen()
        }
    }
}

#Preview {
    HomeScreen()
}
