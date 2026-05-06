import Foundation

struct Service: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

struct Reservation: Identifiable {
    let id = UUID()
    let reservationNumber: String
    let service: Service
    let date: String
    let time: String
}

struct AppState {
    var isLoggedIn = false
    var selectedService: Service? = nil
    var selectedDate: String? = nil
    var selectedTime: String? = nil
    var reserved: Reservation? = nil
}

let sampleServices = [
    Service(name: "기본 케어"),
    Service(name: "프리미엄 케어"),
    Service(name: "상담 예약")
]

let sampleDates = [("5월 7일 (목)", "date_01"), ("5월 8일 (금)", "date_02"), ("5월 9일 (토)", "date_03")]
let sampleTimes = [("09:00", "time_01"), ("10:00", "time_02"), ("11:00", "time_03"), ("14:00", "time_04"), ("15:00", "time_05")]
