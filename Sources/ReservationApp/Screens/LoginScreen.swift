import SwiftUI

struct LoginScreen: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showHome = false
    @State private var loginError = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 60)

                    Text("예약 미니 앱")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .accessibilityIdentifier("app_title")

                    Text("로그인하여 예약 서비스를 이용하세요")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    VStack(spacing: 12) {
                        TextField("이메일", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .accessibilityIdentifier("email_field")

                        SecureField("비밀번호", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .accessibilityIdentifier("password_field")
                    }
                    .padding(.horizontal, 32)

                    if loginError {
                        Text("이메일 또는 비밀번호가 올바르지 않습니다")
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    Button("로그인") {
                        if email == "test@example.com" && password == "password123" {
                            showHome = true
                        } else {
                            loginError = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 32)
                    .accessibilityIdentifier("login_button")

                    Text("테스트 계정: test@example.com / password123")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Button("테스트 계정으로 빠른 로그인") {
                        showHome = true
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 32)
                    .accessibilityIdentifier("quick_login_button")

                    Spacer()
                }
                .padding(.vertical, 40)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationDestination(isPresented: $showHome) {
                HomeScreen()
            }
        }
    }
}

#Preview {
    LoginScreen()
}
