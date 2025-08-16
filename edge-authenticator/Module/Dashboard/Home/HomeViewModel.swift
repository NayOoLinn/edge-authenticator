import RxCocoa
import UIKit
import Foundation
import RxSwift

class HomeViewModel: BaseViewModel, ViewModel {

    struct Input {
        let onViewAppear: Observable<Void>
        let generateNewCodes: Observable<Void>
        let pauseTimer: Observable<Void>
    }

    struct Output {
        let fullLoading: Driver<Bool>
        let error: Driver<Error>
        let updateUI: Driver<Void>
        let codeExpired: Driver<Void>
    }
    
    //Coordinator Output
    let routeToDrawer = PublishSubject<Void>()
    let routeToQrScan = PublishSubject<Void>()
    let routeToBindingKey = PublishSubject<Void>()
    
    var data: [AuthCodeTableCell.DisplayModel] = []
    private let maxProgress = 60 // max Seconds 1 minute
    private let warningAt = 45 // Warning Color at seconds
    
    private var pauseTimer: Bool = false
    private var needNewCodes: Bool = true
    private var codes: [String] = []

    func transform(input: Input) -> Output {

        let activityIndicatorFull = ActivityIndicator()
        let errorTracker = ErrorTracker()

        let timer = Observable<Int>.interval(
            .seconds(1),
            scheduler: MainScheduler.instance
        )
            .mapToVoid()
            .compactMap(secondsNow)
            .share()
        
        let startTimer = input.generateNewCodes
            .filter { self.pauseTimer }
            .onNext {
                self.pauseTimer = false
                self.needNewCodes = true
            }
            .share()
        
        let seconds = Observable.merge(input.onViewAppear, startTimer)
            .flatMapLatest {
                timer
                    .take(while: {_ in !self.pauseTimer})
            }
            .share()
        
        let updateUI = seconds
            .onNext { _ in self.codes = self.generateCodes() }
            .compactMap(self.calculateCurrentProgress)
            .map(self.mapToAuthCodeTableCellDisplayModel)
            .onNext { self.data = $0 }
            .mapToVoid()
            .share()
        
        let timeUp = seconds
            .filter { $0 >= Int(self.maxProgress) }
            .mapToVoid()
            .share()
        
        let codeExpired = Observable.merge(timeUp, input.pauseTimer)
            .onNext { self.pauseTimer = true }
        
        return Output(
            fullLoading: activityIndicatorFull.asDriver(),
            error: errorTracker.asDriver(),
            updateUI: updateUI.asDriverOnErrorNever(),
            codeExpired: codeExpired.asDriverOnErrorNever()
        )
    }
}
// MARK: - Business Logic
private extension HomeViewModel {
    
    func getUTCTime() -> String {
        let now = Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(abbreviation: "UTC")

        return formatter.string(from: now)
    }
    
    func secondsNow() -> Int? {
        guard let timerZone = TimeZone(abbreviation: "UTC") else {
            return nil
        }
        let now = Date()
        let calendar = Calendar.current
        var utcCalendar = calendar
        utcCalendar.timeZone = timerZone
        return utcCalendar.component(.second, from: now) + 1
    }
    
    func calculateCurrentProgress(seconds: Int) -> (progress: CGFloat, color: UIColor)? {
        return (
            progress: CGFloat(seconds) / CGFloat(maxProgress),
            color: seconds >= warningAt ? Color.redBold : Color.blueBold
        )
    }
}
// MARK: - API calls
extension HomeViewModel {

}
// MARK: - Mapping & Data
private extension HomeViewModel {
    func mapToAuthCodeTableCellDisplayModel(progress: CGFloat, color: UIColor) -> [AuthCodeTableCell.DisplayModel] {
    
        return codes.enumerated().map { index, value in
            AuthCodeTableCell.DisplayModel(
                title: "Auth Code: \(index + 1)",
                code: value,
                progress: progress,
                color: color
            )
        }
    }
    
    func generateCodes() -> [String] {
        if !needNewCodes { return codes }
        print("new code generated")
        needNewCodes = false
        return Array(1...7).map { _ in
            let number = String(format: "%06d", Int.random(in: 0...999_999))
            return number.inserting(separator: " ", every: 3)
        }
    }
}
