import SwiftUI
import StoreKit
import Combine

// MARK: - ProductInfo

struct ProductInfo: Identifiable, Equatable {
    let id: String
    let title: String
    let priceString: String
    let periodSuffix: String
    let trialText: String?
    let storeKitProduct: Product

    init(from sk: Product) {
        id = sk.id
        storeKitProduct = sk
        priceString = sk.displayPrice

        var tmpTitle = sk.displayName
        var tmpSuffix = ""

        if let sub = sk.subscription {
            let period = sub.subscriptionPeriod

            switch period.unit {
            case .week:
                tmpTitle = "1 week"
                tmpSuffix = "/week"

            case .month:
                tmpTitle = "1 month"
                tmpSuffix = "/month"

            case .year:
                tmpTitle = "1 year"
                tmpSuffix = "/year"

            default:
                tmpTitle = sk.displayName
                tmpSuffix = ""
            }

            // TRIAL DETECTION
            if let intro = sub.introductoryOffer,
               intro.paymentMode == .freeTrial {

                let p = intro.period
                let unit: String

                switch p.unit {
                case .day: unit = p.value == 1 ? "day" : "days"
                case .week: unit = p.value == 1 ? "week" : "weeks"
                case .month: unit = p.value == 1 ? "month" : "months"
                case .year: unit = p.value == 1 ? "year" : "years"
                @unknown default: unit = "days"
                }

                trialText = "\(p.value) \(unit) free trial"
            } else {
                trialText = nil
            }
        } else {
            trialText = nil
        }

        title = tmpTitle
        periodSuffix = tmpSuffix
    }
}

// MARK: - ViewModel

@MainActor
class PaywallViewModel: ObservableObject {
    @Published var selectedProductId: String?
    @Published var products: [ProductInfo] = []
    @AppStorage("isPremiumUser") var isPremiumUser = false
    @Published var isLoading = false
    @Published var purchaseErrorMessage = ""
    @Published var showPurchaseError = false

    private let ids = [
        "com.app.scanapp.opf.week",
        "com.app.scanapp.opf.month",
        "com.app.scanapp.opf.year"
    ]

    var selectedProduct: ProductInfo? {
        products.first(where: { $0.id == selectedProductId })
    }

    var canPurchase: Bool {
        selectedProductId != nil
    }

    init() {
        Task { await fetchProducts() }
    }

    func fetchProducts() async {
        isLoading = true

        do {
            let fetched = try await Product.products(for: ids)
                .map { ProductInfo(from: $0) }

            // Sorting: week → month → year
            products = fetched.sorted { a, b in
                func rank(_ p: ProductInfo) -> Int {
                    if p.id.contains(".week") { return 0 }
                    if p.id.contains(".month") { return 1 }
                    if p.id.contains(".year") { return 2 }
                    return 3
                }
                return rank(a) < rank(b)
            }

            selectedProductId = nil

        } catch {
            products = []
        }

        isLoading = false
    }

    func purchaseSelected() async {
        guard let product = selectedProduct else { return }
        isLoading = true

        do {
            let result = try await product.storeKitProduct.purchase()

            switch result {
            case .success(let verification):
                if case .verified(let t) = verification {
                    await t.finish()
                    isPremiumUser = true
                }
            default:
                break
            }

        } catch {
            purchaseErrorMessage = error.localizedDescription
            showPurchaseError = true
        }

        isLoading = false
    }

    func restore() async {
        isLoading = true
        try? await AppStore.sync()

        for await t in Transaction.currentEntitlements {
            if case .verified = t { isPremiumUser = true }
        }

        isLoading = false
    }
}

// MARK: - PaywallView

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var vm = PaywallViewModel()
    @State private var showCloseButton = false

    var body: some View {
        ZStack(alignment: .topTrailing) {

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    Image("img5")
                        .resizable()
                        .scaledToFit()
                        .padding(.bottom, 8)

                    VStack(spacing: 8) {
                        Text("Use all features of")
                            .font(.system(size: 28, weight: .bold))
                        Text("Heart Rate")
                            .font(.system(size: 28, weight: .bold))
                    }

                    VStack(alignment: .leading, spacing: 14) {

                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(Color(red: 1.0, green: 0.11, blue: 0.39))
                                .font(.system(size: 17, weight: .semibold))

                            Text("Save every result and see your progress.")
                                .font(.system(size: 15))
                                .foregroundColor(.black.opacity(0.82))
                        }
                        .padding(.horizontal, 22)

                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "clock")
                                .foregroundColor(Color(red: 1.0, green: 0.11, blue: 0.39))
                                .font(.system(size: 17, weight: .semibold))

                            Text("Access your full history anytime.")
                                .font(.system(size: 15))
                                .foregroundColor(.black.opacity(0.82))
                        }
                        .padding(.horizontal, 22)

                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(Color(red: 1.0, green: 0.11, blue: 0.39))
                                .font(.system(size: 17, weight: .semibold))

                            Text("Get quick AI insights for your BPM.")
                                .font(.system(size: 15))
                                .foregroundColor(.black.opacity(0.82))
                        }
                        .padding(.horizontal, 22)
                    }
                    
                    if vm.isLoading {
                        ProgressView().padding(40)
                    } else {
                        productLayout
                    }

                    // Continue Button
                    Button {
                        Task {
                            await vm.purchaseSelected()
                            if vm.isPremiumUser { dismiss() }
                        }
                    } label: {
                        Text("Continue")
                            .font(.system(size: 21, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                vm.canPurchase
                                    ? AnyShapeStyle(LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.64, blue: 0.69),
                                            Color(red: 1.0, green: 0.11, blue: 0.39)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    : AnyShapeStyle(Color.gray.opacity(0.25))
                            )
                            .clipShape(Capsule())
                            .shadow(color: vm.canPurchase
                                    ? Color(red: 1.0, green: 0.11, blue: 0.39).opacity(0.3)
                                    : .clear,
                                    radius: 20, y: 8)
                    }
                    .disabled(!vm.canPurchase)
                    .padding(.horizontal, 20)

                    HStack(spacing: 30) {
                        Link("Terms of use", destination: URL(string: "https://google.com")!)
                        Button("Restore") { Task { await vm.restore() } }
                        Link("Privacy policy", destination: URL(string: "https://google.com")!)
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.bottom, 40)
                }
            }

            if showCloseButton {
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 34))
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.top, 14)
                        .padding(.trailing, 18)
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    showCloseButton = true
                }
            }
        }
        .alert("Error", isPresented: $vm.showPurchaseError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.purchaseErrorMessage)
        }
    }

    // MARK: - Products Layout

    var productLayout: some View {
        VStack(spacing: 20) {

            if let top = vm.products.first {
                TrialCard(
                    product: top,
                    isSelected: vm.selectedProductId == top.id
                )
                .onTapGesture {
                    withAnimation { vm.selectedProductId = top.id }
                }
            }

            if vm.products.count > 1 {
                HStack(spacing: 16) {
                    ForEach(vm.products.dropFirst()) { product in
                        SmallCard(
                            product: product,
                            isSelected: vm.selectedProductId == product.id
                        )
                        .onTapGesture {
                            withAnimation { vm.selectedProductId = product.id }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Trial Card

struct TrialCard: View {
    let product: ProductInfo
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            Text(product.title)
                .font(.system(size: 17, weight: .semibold))

            if let trial = product.trialText {
                Text(trial)
                    .font(.system(size: 15))
                    .foregroundColor(.black.opacity(0.8))
            }

            Text(product.priceString + product.periodSuffix)
                .font(.system(size: 15))
                .foregroundColor(.black.opacity(0.75))
        }
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 18, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    Color(red: 1.0, green: 0.11, blue: 0.39),
                    lineWidth: isSelected ? 2 : 0
                )
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Small Card

struct SmallCard: View {
    let product: ProductInfo
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text(product.title)
                .font(.system(size: 16, weight: .semibold))

            Text(product.priceString + product.periodSuffix)
                .font(.system(size: 15))
                .foregroundColor(.black.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 12, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    Color(red: 1.0, green: 0.11, blue: 0.39),
                    lineWidth: isSelected ? 2 : 0
                )
        )
    }
}

#Preview {
    PaywallView()
}
