import UIKit

// Registration
// Resolution
// Scope
// Ref: https://www.youtube.com/watch?v=ZZBoA0OM_sQ&t=22s
final class Container {
    static let shared = Container()
    private init(){}
    
    private var services: [String: Any] = [:]
    
    func bind<Service>(service: Service.Type,  resolver: @escaping (Container) -> Service) {
        let key = String(describing: Service.self)
        services[key] = resolver(self)
    }
    
    func resolve<Service>(type: Service.Type) -> Service {
        let key = String(describing: type)
        
        guard let service = services[key] as? Service else {
            fatalError("\(key) service not registered")
        }
        
        return service
    }
}

protocol AuthService {
    func authenticate(username: String, password: String) -> Bool
}

protocol AnalyticsService {
    func track(infos: String)
}

class DefaultAuthService: AuthService {
    func authenticate(username: String, password: String) -> Bool {
        true
    }
}

class DefaultAnalytics: AnalyticsService {
    func track(infos: String) { }
}

class LoginViewModel {
    let authService: AuthService
    let analyticsService: AnalyticsService
    
    init(authService: AuthService, analyticsService: AnalyticsService) {
        self.authService = authService
        self.analyticsService = analyticsService
    }
    
    func login(username: String, password: String) {
        let result = authService.authenticate(username: username, password: password)
        if result {
            print("Login Success")
        } else {
            print("Login Failed")
        }
    }
}

// Normal way of Dependancy Injection
let loginVM = LoginViewModel(authService: DefaultAuthService(), analyticsService: DefaultAnalytics())
loginVM.login(username: "Viswa", password: "Apple123")

// Using DI Container

Container.shared.bind(service: AuthService.self) { resolver in
    DefaultAuthService()
}

Container.shared.bind(service: AnalyticsService.self) { resolver in
    DefaultAnalytics()
}

Container.shared.bind(service: LoginViewModel.self) { resolver in
    let authService = resolver.resolve(type: AuthService.self)
    let analytics = resolver.resolve(type: AnalyticsService.self)
    
    return LoginViewModel(authService: authService, analyticsService: analytics)
}


let viewModel = Container.shared.resolve(type: LoginViewModel.self)
viewModel.login(username: "Viswa", password: "Apple123")

