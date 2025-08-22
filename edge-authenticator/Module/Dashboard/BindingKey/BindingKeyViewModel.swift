import RxCocoa
import Foundation
import RxSwift

class BindingKeyViewModel: BaseViewModel, ViewModel {

    struct Input {
        let onViewAppear: Observable<Void>
        let onNameChanged: Observable<String>
        let onKeyChanged: Observable<String>
    }

    struct Output {
        let fullLoading: Driver<Bool>
        let error: Driver<Error>
        let updateUI: Driver<AuthCodeData?>
        let enableButton: Driver<Bool>
    }
    
    //Coordinator Output

    let data: AuthCodeData?
    init(data: AuthCodeData?) {
        self.data = data
    }

    func transform(input: Input) -> Output {

        let activityIndicatorFull = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        let updateUI = input.onViewAppear
            .map { self.data }
        
        let nameValid = input.onNameChanged
            .map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
            }
        
        let keyValid = input.onKeyChanged
            .map {
                let key = self.data?.key ?? $0.trimmingCharacters(in: .whitespacesAndNewlines)
                return key.count >= 4
            }
        
        let enableButton = Observable.combineLatest(nameValid, keyValid) { $0 && $1 }
        
        return Output(
            fullLoading: activityIndicatorFull.asDriver(),
            error: errorTracker.asDriver(),
            updateUI: updateUI.asDriverOnErrorNever(),
            enableButton: enableButton.asDriverOnErrorNever()
        )
    }
}
// MARK: - Business Logic
extension BindingKeyViewModel {
    
    func saveAuthCode(name: String, key: String) {
        if let data = AuthCodeData.findInRealm(key) {
            RealmManager.shared.update {
                data.name = name
            }
        } else {
            let authCode = AuthCodeData()
            authCode.name = name
            authCode.key = key
            RealmManager.shared.add(authCode)
        }
    }
}
// MARK: - API calls
extension BindingKeyViewModel {

}
// MARK: - Mapping & Data
private extension BindingKeyViewModel {
    
}
