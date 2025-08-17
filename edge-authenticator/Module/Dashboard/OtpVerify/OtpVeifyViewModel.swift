import RxCocoa
import Foundation
import RxSwift

class OtpVerifyViewModel: BaseViewModel, ViewModel {

    struct Input {
        let onViewAppear: Observable<Void>
        let resentOtp: Observable<Void>
    }

    struct Output {
        let fullLoading: Driver<Bool>
        let error: Driver<Error>
        let updateResendCountDown: Driver<OTPResendType>
    }
    
    //Coordinator Output
    let resendOtpCount = 10

    func transform(input: Input) -> Output {

        let activityIndicatorFull = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        let triggerCountdown = Observable.merge(
            input.onViewAppear,
            input.resentOtp
        )
        
        let countdown = triggerCountdown
            .flatMapLatest { [resendOtpCount] _ -> Observable<OTPResendType> in
                Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
                    .map { resendOtpCount - $0 }
                    .take( resendOtpCount + 1) // include zero
                    .map { remaining -> OTPResendType in
                        remaining > 0 ? .notAvailable(remaining) : .available
                    }
            }
            .share(replay: 1, scope: .whileConnected)
        
        return Output(
            fullLoading: activityIndicatorFull.asDriver(),
            error: errorTracker.asDriver(),
            updateResendCountDown: countdown.asDriverOnErrorNever(),
        )
    }
}
// MARK: - Business Logic
extension OtpVerifyViewModel {
    
}
// MARK: - API calls
extension OtpVerifyViewModel {

}
// MARK: - Mapping & Data
private extension OtpVerifyViewModel {
    
}

extension OtpVerifyViewModel {
    
    enum OTPResendType {
        case notAvailable(Int)
        case available
    }
}
