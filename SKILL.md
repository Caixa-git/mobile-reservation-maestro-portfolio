# Hermes-Maestro Skill 문서

> **버전:** v2.0.0  
> **최종 업데이트:** 2026-05-07  
> **담당 도메인:** iOS Mobile E2E 테스트 자동화 (Maestro + SwiftUI)

---

## 1. 목적 (Purpose)

본 Skill은 SwiftUI 기반 iOS 애플리케이션의 엔드투엔드(E2E) 테스트를 Maestro CLI를 통해 자동화합니다. Maestro Flow를 작성하고 실행하여 시뮬레이터 환경에서 실제 사용자 시나리오를 검증하며, 테스트 결과를 문서화하고 보고서 형태로 출력합니다. iOS 26.4 시뮬레이터에서 발견된 접근성 호환성 문제에 대한 우회 방안을 포함하여 안정적인 테스트 실행을 보장합니다.

---

## 2. 사용하는 경우 (When to Use)

- SwiftUI 기반 iOS 앱의 E2E 테스트를 자동화해야 하는 경우
- Maestro CLI를 사용하여 시뮬레이터에서 UI 요소의 접근성 식별자 기반 테스트를 수행하는 경우
- 로그인 → 서비스 선택 → 날짜/시간 선택 → 확인 → 완료로 이어지는 다단계 사용자 플로우를 검증해야 하는 경우
- iOS 26.4 이상 시뮬레이터 환경에서 SwiftUI SecureField와 Maestro inputText 간 호환성 문제를 우회해야 하는 경우
- CI/CD 파이프라인에 포함할 수 있는 재현 가능한 테스트 스크립트가 필요한 경우
- 테스트 실행 결과를 구조화된 보고서로 출력해야 하는 경우

---

## 3. 사용하지 않는 경우 (When Not to Use)

- Android 앱 테스트가 필요한 경우 (Maestro는 크로스 플랫폼을 지원하나 본 Skill은 iOS 전용)
- 실제 iOS 기기(physical device)에서의 테스트가 필요한 경우 (본 Skill은 시뮬레이터 전용)
- 단위 테스트(Unit Test)나 통합 테스트(Integration Test)가 필요한 경우 (본 Skill은 E2E 전용)
- UI 요소에 접근성 식별자(accessibilityIdentifier)가 설정되지 않은 앱
- Maestro CLI가 설치되지 않은 환경
- SwiftUI 네비게이션 애니메이션 타이밍 이슈에 민감하지 않은 단순 검증이 필요한 경우

---

## 4. 입력 (Inputs)

| 항목 | 설명 | 필수 |
|------|------|:----:|
| **Maestro Flow 파일** | `.yaml` 형식의 E2E 테스트 시나리오 (`maestro-flows/` 디렉토리 내) | ✅ |
| **SwiftUI 앱 소스** | 접근성 식별자가 설정된 iOS 앱 (`Sources/ReservationApp/`) | ✅ |
| **XcodeGen 설정** | `project.yml` — 프로젝트 생성 설정 | ✅ |
| **시뮬레이터 설정** | 대상 기기 (iPhone 17 Pro Simulator, iOS 26.4) | ✅ |
| **테스트 계정 정보** | `test@example.com` / `password123` (로그인 form 우회용) | ✅ |
| **스크린샷** | 실행 결과 캡처 이미지 (`.png`, `screenshots/` 디렉토리) | ❌ |

---

## 5. 프로세스 (Process)

### 5.1 환경 설정 (Environment Setup)

1. **XcodeGen으로 프로젝트 생성**
   ```bash
   cd mobile-reservation-maestro-portfolio
   xcodegen generate
   ```

2. **Xcode에서 앱 빌드 및 시뮬레이터 실행**
   - Xcode GUI에서 `Product > Run` (⌘R) 또는 커맨드라인 빌드
   ```bash
   xcrun simctl boot "iPhone 17 Pro"
   xcrun simctl install booted /path/to/build/ReservationApp.app
   xcrun simctl launch booted com.portfolio.ReservationApp
   ```

3. **Maestro CLI 확인**
   ```bash
   maestro --version
   # Version: 2.5.1 (이상)
   ```

4. **Java 런타임 확인** (Maestro는 Java 의존성 있음)
   ```bash
   java -version
   # OpenJDK 17.0.19 이상
   ```

### 5.2 Flow 파일 준비

Maestro Flow 파일은 YAML 형식으로 작성하며, 다음 구조를 따릅니다:

```yaml
appId: com.portfolio.ReservationApp
---
# 테스트 단계 리스트
- launchApp
- waitForAnimationToEnd:
    timeout: 8000
- scrollUntilVisible:
    element:
      id: "element_id"
    direction: DOWN
    timeout: 5000
- assertVisible:
    id: "element_id"
- tapOn:
    id: "element_id"
```

### 5.3 Flow 실행 (Flow Execution)

```bash
# 단일 Flow 실행
maestro test maestro-flows/login-reservation-flow.yaml

# 여러 Flow 연속 실행
maestro test maestro-flows/
```

Maestro는 Flow 파일의 각 Step을 순차적으로 실행하며, 각 Step의 결과를 실시간으로 출력합니다.

### 5.4 scrollUntilVisible Fallback 패턴

iOS 26.4 시뮬레이터에서는 SwiftUI의 네비게이션 스택이 완전히 렌더링되기 전에 `assertVisible`이 실패하는 경우가 있습니다. 이를 해결하기 위해 `scrollUntilVisible`을 선행 배치합니다.

```yaml
# iOS 26.4 접근성 호환성 우회 패턴
- scrollUntilVisible:           # fallback: 요소가 보일 때까지 스크롤
    element:
      id: "target_element_id"
    direction: DOWN
    timeout: 5000
- assertVisible:                # 본 검증
    id: "target_element_id"
- tapOn:
    id: "target_element_id"
```

**적용 대상:** 네비게이션 트랜지션 후 표시되는 모든 화면의 첫 번째 요소

### 5.5 빠른 로그인 버튼 (quick_login_button) 패턴

SwiftUI의 `SecureField`는 Maestro의 `inputText` 명령어와 호환되지 않습니다 (`inputText`는 COMPLETED를 반환하지만 `@State` 바인딩이 업데이트되지 않음). 이 문제를 우회하기 위해 앱에 `quick_login_button` 접근성 식별자가 구현되어 있습니다.

```yaml
# SecureField 호환성 우회: form 입력 대신 빠른 로그인 버튼 사용
- scrollUntilVisible:
    element:
      id: "quick_login_button"
    direction: DOWN
    timeout: 5000
- tapOn:
    id: "quick_login_button"
```

**동작 원리:** `quick_login_button`은 `@State private var showHome = true`로 직접 설정하여 `NavigationStack`의 네비게이션을 트리거합니다. 실제 `SecureField`를 통한 인증 로직을 우회하며, debug/test 빌드 전용입니다.

### 5.6 스크린샷 캡처 (Screenshot Capture)

Maestro CLI는 실행 중 스크린샷을 자동으로 캡처하지 않습니다. 스크린샷이 필요한 경우:

```bash
# 시뮬레이터 스크린샷 수동 캡처
xcrun simctl screenshot booted screenshots/<filename>.png
```

또는 Xcode의 Debug > View Debugging 기능을 사용합니다.

### 5.7 결과 분석 (Result Analysis)

Maestro 실행 후 다음 항목을 분석합니다:

1. **종료 코드:** `0`이면 모든 Step이 COMPLETED
2. **Step별 결과:** Flow 파일의 각 Step에 대해 COMPLETED/FAILED/SKIPPED 확인
3. **assertVisible 타임아웃:** 마지막 Step에서 간헐적 타임아웃 발생 가능 (SwiftUI 네비게이션 타이밍 이슈)
4. **반복 실행 안정성:** 최소 3회 이상 실행하여 일관된 결과 확인

**분석 체크리스트:**

| 항목 | 확인 기준 |
|------|-----------|
| 전체 Step 수 | Flow 파일에 정의된 Step과 실제 실행된 Step 수 일치 |
| 통과율 | 100% (0 FAILED) |
| 반복 실행 | 3회 연속 동일 결과 |
| 종료 코드 | 0 (정상 종료) |
| 민감정보 | Flow 파일에 하드코딩된 민감정보 없음 |

---

## 6. 출력 형식 (Output Format)

### 6.1 Maestro 실행 결과

Maestro는 실행 결과를 터미널에 실시간으로 출력합니다:

```
⏳ Step 1: launchApp ... COMPLETED (0ms)
⏳ Step 2: waitForAnimationToEnd ... COMPLETED (512ms)
...
✅ Flow executed completed in N.Ns
```

### 6.2 테스트 보고서

구조화된 테스트 보고서는 `templates/maestro-test-report.md` 템플릿을 기반으로 작성합니다. 보고서에는 다음 정보가 포함됩니다:

| 섹션 | 내용 |
|------|------|
| 헤더 | Flow 이름, 실행일, 최종 결과 |
| 실행 환경 | OS, Device, Java, Maestro, Xcode 버전 |
| 실행 명령어 | 사전 준비 및 실행 명령어 |
| Step별 결과 | 각 Step의 동작, 명령어, 결과, 실행 시간 |
| 종합 통계 | 전체 Step 수, 완료/실패/건너뜀 수, 총 실행 시간 |
| 이슈 상세 | 발생한 이슈의 증상, 원인, 해결 방안, 영향 범위 |
| 스크린샷 | 각 단계별 앱 화면 캡처 |

### 6.3 출력물 구조

```
outputs/
└── cycle-<N>/
    ├── INDEX.md                    # 출력물 인덱스
    ├── CYCLE_REPORT.md             # 사이클 리포트
    ├── QA_RESULTS.md               # QA 결과
    ├── MAESTRO_EXECUTION_REPORT.md  # Maestro 실행 보고서
    ├── VERIFICATION_STATUS.md      # 검증 상태표
    ├── CHANGE_SUMMARY.md           # 변경 요약
    └── REVIEW_REQUEST.md           # 리뷰 요청
```

---

## 7. 사용자 승인 경계 (User Approval Boundary)

| 항목 | 승인 필요 | 설명 |
|------|:---------:|------|
| Maestro Flow 파일 생성/수정 | ❌ | 사전 정의된 템플릿 범위 내에서 자율 작성 |
| SwiftUI 소스 코드 수정 | ❌ | 접근성 식별자 추가/수정은 자율 수행 |
| 테스트 실행 | ❌ | Maestro CLI 실행은 자율 수행 |
| 결과 분석 및 보고서 작성 | ❌ | 템플릿 기반 자동 작성 |
| **CI/CD 파이프라인 연동** | ✅ | GitHub Actions 등 외부 시스템 연동 시 승인 필요 |
| **실제 기기 테스트** | ✅ | 시뮬레이터가 아닌 실제 iOS 기기 테스트 시 승인 필요 |
| **프로덕션 데이터 사용** | ✅ | 실제 사용자 데이터 또는 운영 데이터베이스 사용 시 승인 필요 |
| **API 키/토큰 저장** | ✅ | 저장소에 인증 정보 포함 시 승인 필요 |
| **앱 스토어 배포 구성 변경** | ✅ | Bundle ID, 인증서, 프로비저닝 프로파일 변경 시 승인 필요 |

---

## 8. 사용자 친화적 다음 액션 (User-Friendly Next Action)

테스트 실행 완료 후 사용자에게 다음 액션을 제안합니다:

### 테스트 성공 시
```
✅ iOS Real Execution이 성공적으로 완료되었습니다.
모든 19개 Step이 COMPLETED 상태입니다.

📋 다음 액션:
1. [ ] 테스트 보고서 검토: outputs/cycle-N/MAESTRO_EXECUTION_REPORT.md
2. [ ] 스크린샷 확인: screenshots/ 디렉토리
3. [ ] 반복 실행으로 안정성 확인: maestro test maestro-flows/login-reservation-flow.yaml
4. [ ] CI/CD 파이프라인 연동 검토
```

### 테스트 실패 시
```
❌ iOS Real Execution이 실패했습니다.
[FAILED STEP]: Step N - [명령어]

📋 문제 해결:
1. 시뮬레이터 상태 확인: xcrun simctl list | grep Booted
2. 앱 실행 상태 확인: 앱이 시뮬레이터에서 정상 실행 중인지 확인
3. 접근성 식별자 확인: 대상 요소에 accessibilityIdentifier가 설정되어 있는지 확인
4. Flow 파일 문법 검증: maestro validate maestro-flows/<flow>.yaml
5. 네비게이션 타이밍: waitForAnimationToEnd 타임아웃 증가 (기본: 8000ms)
```

### 정기 유지보수
```
📅 정기 점검 항목:
- [ ] 매 주: Maestro CLI 최신 버전 확인 (maestro --version)
- [ ] 매 주: iOS 시뮬레이터 런타임 업데이트 확인
- [ ] 매 사이클: 3회 연속 반복 실행으로 안정성 검증
- [ ] 매 릴리즈: 접근성 식별자 변경 사항 Flow 파일에 반영
```

---

## 9. 완료 기준 (Completion Criteria)

| 기준 | 상세 |
|------|------|
| **모든 Step COMPLETED** | Flow 파일에 정의된 모든 Step이 COMPLETED 상태로 완료 |
| **종료 코드 0** | Maestro CLI가 exit code 0으로 정상 종료 |
| **반복 실행 안정성** | 3회 연속 실행 시 동일한 결과 (100% 통과) |
| **스크린샷 캡처 완료** | 각 화면 단계별 스크린샷이 정상적으로 캡처됨 |
| **보고서 작성 완료** | 실행 보고서, QA 결과, 검증 상태표가 템플릿 기반으로 작성됨 |
| **민감정보 부재 확인** | Flow 파일 및 출력물에 하드코딩된 민감정보 없음 |
| **문서화 완료** | README.md, SKILL.md, PORTFOLIO_SUMMARY.md 최신 상태 유지 |

---

## 10. 실패/중단 조건 (Failure/Stop Conditions)

| 상황 | 조치 |
|------|------|
| **Maestro CLI 미설치** | `brew install maestro` 또는 공식 문서 참조하여 설치 안내 |
| **Java 런타임 미설치** | `brew install openjdk@17` 실행 안내 |
| **시뮬레이터 미부팅** | `xcrun simctl boot "iPhone 17 Pro"` 실행 안내 |
| **앱 미설치** | XcodeGen으로 프로젝트 생성 후 Xcode에서 빌드 안내 |
| **접근성 식별자 없음** | SwiftUI 소스 코드에 `.accessibilityIdentifier()` 추가 안내 |
| **assertVisible 타임아웃** | `waitForAnimationToEnd` 타임아웃 증가 또는 `scrollUntilVisible` fallback 추가 |
| **SecureField inputText 실패** | `quick_login_button` 접근성 식별자를 통한 우회 경로 사용 (form 입력 불가) |
| **네트워크 오류** | 시뮬레이터 네트워크 상태 확인 후 재시도 |
| **Flow 파일 문법 오류** | `maestro validate <flow.yaml>`로 문법 검증 후 수정 |

---

## 11. 예시 (Examples)

### 예시 1: 전체 E2E Flow (login-reservation-flow.yaml)

```yaml
appId: com.portfolio.ReservationApp
---
# Step 1: 앱 실행
- launchApp

# Step 2: 네비게이션 애니메이션 대기
- waitForAnimationToEnd:
    timeout: 8000

# Step 3: scrollUntilVisible Fallback — iOS 26.4 접근성 우회
- scrollUntilVisible:
    element:
      id: "app_title"
    direction: DOWN
    timeout: 5000

# Step 4: 로그인 화면 확인
- assertVisible:
    id: "app_title"

# Step 5: 빠른 로그인 (SecureField 호환성 우회)
- tapOn:
    id: "quick_login_button"

# Step 6: HomeScreen 애니메이션 대기
- waitForAnimationToEnd

# Step 7: 환영 메시지 확인
- assertVisible:
    id: "welcome_text"

# Step 8: 예약하기 버튼 탭
- tapOn:
    id: "reserve_button"

# ... (이하 생략 — 전체 Flow는 maestro-flows/login-reservation-flow.yaml 참조)
```

### 예시 2: scrollUntilVisible 패턴 (iOS 26.4 접근성 우회)

```yaml
# iOS 26.4에서 SwiftUI NavigationStack 트랜지션 후
# 요소가 즉시 visible 상태가 되지 않을 때 사용
- waitForAnimationToEnd:
    timeout: 8000
- scrollUntilVisible:            # 🔑 핵심 우회 패턴
    element:
      id: "complete_title"
    direction: DOWN
    timeout: 5000
- assertVisible:
    id: "complete_title"
```

### 예시 3: 빠른 로그인 패턴 (SecureField 우회)

```yaml
# SwiftUI SecureField + Maestro inputText 비호환 문제 우회
- launchApp
- waitForAnimationToEnd:
    timeout: 8000
- scrollUntilVisible:
    element:
      id: "quick_login_button"
    direction: DOWN
    timeout: 5000
- tapOn:
    id: "quick_login_button"     # 🔑 SecureField 우회
- waitForAnimationToEnd
- assertVisible:
    id: "welcome_text"
```

### 예시 4: 반복 실행 검증 스크립트

```bash
#!/bin/bash
# 3회 반복 실행으로 안정성 검증
set -e

for i in 1 2 3; do
  echo "=== 실행 #$i ==="
  maestro test maestro-flows/login-reservation-flow.yaml
  echo "=== 실행 #$i 완료 (종료 코드: $?) ==="
done

echo "✅ 3회 반복 실행 완료 — 모든 실행 통과"
```

---

## 12. 테스트 점수 시스템 (Test Score System)

Maestro v2.0.0은 E2E 테스트의 품질을 정량적으로 평가하기 위한 **Test Score System**을 도입합니다. 각 테스트 실행은 0–10점 척도로 평가되며, **P-Level (Priority Level)** 과 **4가지 KPI**를 기반으로 종합 점수를 산출합니다.

### 12.1 P-Level (Priority Level)

테스트 Flow의 중요도를 나타내는 우선순위 등급입니다.

| P-Level | 설명 | 예시 |
|:-------:|------|------|
| **P0** | **Critical** — 서비스 중단에 해당하는 핵심 사용자 플로우. 전체 예약 프로세스(로그인→서비스선택→예약→완료)가 실패하면 서비스 중단으로 간주 | 로그인→예약→완료 Flow |
| **P1** | **High** — 주요 기능이지만 우회 경로 존재. 실패 시 사용자 경험에 큰 영향을 미치나 서비스는 지속 가능 | 결제 정보 입력, 사용자 정보 수정 |
| **P2** | **Medium** — 일반 기능. 실패 시 불편하지만 핵심 사용자 플로우에는 영향 없음 | 알림 설정, 테마 변경 |
| **P3** | **Low** — 부가/마이너 기능. 실패 시 영향이 제한적 | 히스토리 조회, 정렬 옵션 |

### 12.2 4가지 KPI (Key Performance Indicators)

각 테스트 실행은 다음 4가지 KPI로 평가되며, 모든 KPI는 0–10점 범위를 가집니다.

| KPI | 지표명 | 설명 | 측정 방식 |
|:---:|--------|------|-----------|
| **K1** | **테스트 안정성 (Stability)** | 반복 실행 시 일관된 결과를 보장하는 능력 | 3회 연속 실행 시 통과율: 100% = 10점, 1회 실패 시 -3점씩 차감 |
| **K2** | **테스트 커버리지 (Coverage)** | 정의된 사용자 시나리오 대비 테스트된 시나리오의 비율 | 전체 Flow 중 실제 통과한 Flow 비율 × 10 |
| **K3** | **Step 신뢰도 (Step Reliability)** | Flow 내 각 Step의 개별 통과율 | (통과 Step 수 ÷ 전체 Step 수) × 10 |
| **K4** | **실행 효율성 (Efficiency)** | 테스트 실행 시간이 기준 시간 대비 얼마나 효율적인지 | 기준 시간(예: 60초) 대비 실제 실행 시간 비율로 점수화 (기준 이내 = 10점, 초과 시 1초당 -0.5점) |

### 12.3 종합 점수 산출

종합 점수는 **0–10점** 범위로 산출되며, P-Level에 따라 KPI별 가중치가 다르게 적용됩니다.

```
종합 점수 = (K1 × w1) + (K2 × w2) + (K3 × w3) + (K4 × w4)
```

**P-Level별 가중치 테이블:**

| KPI | P0 가중치 | P1 가중치 | P2 가중치 | P3 가중치 |
|:---:|:---------:|:---------:|:---------:|:---------:|
| K1 (Stability) | 0.40 | 0.35 | 0.25 | 0.20 |
| K2 (Coverage) | 0.25 | 0.25 | 0.30 | 0.30 |
| K3 (Step Reliability) | 0.25 | 0.25 | 0.25 | 0.25 |
| K4 (Efficiency) | 0.10 | 0.15 | 0.20 | 0.25 |

### 12.4 점수 해석 (Score Interpretation)

| 점수 범위 | 등급 | 의미 |
|:---------:|:----:|------|
| **9.0–10.0** | 🏆 **Excellent** | 모든 기준을 충족. 지속적 통합(CI)에 즉시 포함 가능 |
| **7.0–8.9** | ✅ **Good** | 대부분 기준 충족. 사소한 개선 기회 있음 |
| **5.0–6.9** | ⚠️ **Fair** | 일부 개선 필요. 안정성 또는 커버리지 향상 권장 |
| **3.0–4.9** | 🔶 **Poor** | 주요 결함 존재. P-Level이 높은 Flow는 우선 개선 대상 |
| **0.0–2.9** | ❌ **Unacceptable** | 심각한 문제. 실행 환경 또는 Flow 정의 자체 재검토 필요 |

### 12.5 결과 보고서 예시

```
┌─────────────────────────────────────────────────────────────┐
│               Maestro Test Score Report v2.0.0              │
├─────────────────────────────────────────────────────────────┤
│ Flow: login-reservation-flow.yaml                           │
│ P-Level: P0 (Critical)                                      │
│ Date: 2026-05-07                                            │
├─────────────────────────────────────────────────────────────┤
│ KPI Score:                                                  │
│   K1 (Stability)      10.0 / 10  (3/3 pass)     × 0.40     │
│   K2 (Coverage)       10.0 / 10  (1/1 flows)     × 0.25     │
│   K3 (Step Reliability) 9.5 / 10 (19/20 steps)   × 0.25     │
│   K4 (Efficiency)      8.0 / 10  (75s / 60s)     × 0.10     │
├─────────────────────────────────────────────────────────────┤
│ 종합 점수: 9.63 / 10.0 — 🏆 Excellent                       │
└─────────────────────────────────────────────────────────────┘
```

### 12.6 CI/CD 연동 가이드

Test Score는 CI/CD 파이프라인에서 게이트 조건으로 사용할 수 있습니다.

```yaml
# GitHub Actions 예시 (maestro-score-gate)
jobs:
  maestro-test:
    steps:
      - run: maestro test maestro-flows/
      - run: |
          # 점수 기반 게이트
          SCORE=$(maestro-score --report outputs/latest/score.json)
          if (( $(echo "$SCORE < 7.0" | bc -l) )); then
            echo "❌ Score $SCORE — 게이트 통과 실패"
            exit 1
          fi
          echo "✅ Score $SCORE — 게이트 통과"
```

---

## 부록: iOS 26.4 접근성 Workarounds

### Workaround 1: scrollUntilVisible

**문제:** iOS 26.4 시뮬레이터에서 SwiftUI `NavigationStack`의 트랜지션 애니메이션이 완전히 종료되기 전에 `assertVisible`을 호출하면 요소가 visible 상태가 아니라고 판단하여 타임아웃이 발생합니다.

**해결:** `assertVisible` 직전에 `scrollUntilVisible`을 배치하여 fallback 역할을 수행합니다. `scrollUntilVisible`은 요소가 보일 때까지 지정된 방향으로 스크롤하며, 요소가 이미 visible 상태이면 아무 동작 없이 COMPLETED를 반환합니다.

```yaml
# 권장 패턴 (네비게이션 후 첫 번째 요소)
- waitForAnimationToEnd:
    timeout: 8000
- scrollUntilVisible:
    element:
      id: "target_element"
    direction: DOWN
    timeout: 5000
- assertVisible:
    id: "target_element"
```

### Workaround 2: quick_login_button

**문제:** SwiftUI의 `SecureField`는 내부적으로 `UITextField`의 보안 입력 모드를 사용하며, `XCUIElement` 타입이 `secureTextField`로 식별됩니다. Maestro의 `inputText` 명령어는 일반 `textField`에는 정상 동작하나 `secureTextField`에는 입력 이벤트가 전달되지 않습니다 (`inputText`가 COMPLETED를 반환해도 `@State` 바인딩이 업데이트되지 않음).

**해결:** 앱 소스 코드에 `quick_login_button` 접근성 식별자를 가진 버튼을 구현합니다. 이 버튼은 `@State private var showHome = true`를 직접 설정하여 form 검증을 우회하고 HomeScreen으로 즉시 네비게이션합니다.

```swift
// SwiftUI 소스 코드 (LoginScreen.swift)
Button("테스트 계정으로 빠른 로그인") {
    showHome = true
}
.accessibilityIdentifier("quick_login_button")
```

---

> **문서 버전:** v2.0.0  
> **작성 도구:** Hermes Agent (Nous Research)  
> **관련 저장소:** [mobile-reservation-maestro-portfolio](https://github.com/Caixa-git/mobile-reservation-maestro-portfolio)
