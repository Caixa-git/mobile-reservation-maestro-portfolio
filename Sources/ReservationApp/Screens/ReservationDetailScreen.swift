import SwiftUI

struct ReservationDetailScreen: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("내 예약")
                .font(.title)
                .fontWeight(.bold)
            Text("현재 예약 내역이 없습니다")
                .foregroundColor(.secondary)
        }
        .navigationTitle("내 예약")
    }
}

#Preview {
    ReservationDetailScreen()
}
