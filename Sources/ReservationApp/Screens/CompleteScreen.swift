import SwiftUI

struct CompleteScreen: View {
    let service: String
    let date: String
    let time: String

    var reservationNumber: String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let nums = String(format: "%04d", Int.random(in: 1000...9999))
        return String((0..<2).map { _ in letters.randomElement()! }) + nums
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)

            Text("예약이 완료되었습니다!")
                .font(.title)
                .fontWeight(.bold)
                .accessibilityIdentifier("complete_title")

            VStack(spacing: 12) {
                HStack {
                    Text("예약 번호")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("#\(reservationNumber)")
                        .fontWeight(.bold)
                        .accessibilityIdentifier("reservation_number")
                }
                Divider()
                HStack {
                    Text("서비스")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(service)
                }
                Divider()
                HStack {
                    Text("날짜")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(date)
                }
                Divider()
                HStack {
                    Text("시간")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(time)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 32)

            NavigationLink("홈으로 돌아가기") {
                HomeScreen()
            }
            .buttonStyle(.bordered)
            .padding(.horizontal, 32)
            .accessibilityIdentifier("home_button")

            Spacer()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    CompleteScreen(service: "기본 케어", date: "5월 7일 (목)", time: "09:00")
}
