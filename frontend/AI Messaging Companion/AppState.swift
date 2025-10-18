//
//  AppState.swift
//  Bro
//

import SwiftUI
import Combine

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var selectedProfile: ToneProfile = .nice_guy
    @Published var availableProfiles: [String] = []
    @Published var showSettings = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadProfiles()
    }
    
    // MARK: - Data Loading
    
    func loadProfiles() {
        APIService.shared.getProfiles { [weak self] result in
            switch result {
            case .success(let profiles):
                DispatchQueue.main.async {
                    self?.availableProfiles = profiles
                    print("✅ Loaded profiles: \(profiles)")
                }
            case .failure(let error):
                print("⚠️ Error loading profiles: \(error)")
                // Set default profiles if backend is not available
                DispatchQueue.main.async {
                    self?.availableProfiles = ["nice_guy", "meme_god", "no_filter"]
                }
            }
        }
    }
    
    func checkBackendHealth(completion: @escaping (Bool) -> Void) {
        APIService.shared.healthCheck { result in
            switch result {
            case .success(let ok):
                completion(ok)
            case .failure:
                completion(false)
            }
        }
    }
}
