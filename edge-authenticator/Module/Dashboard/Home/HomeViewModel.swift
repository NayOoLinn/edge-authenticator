import RxCocoa
import UIKit
import Foundation
import RxSwift

class HomeViewModel: BaseViewModel, ViewModel {

    struct Input {
        let onViewAppear: Observable<Void>
        let generateNewCodes: Observable<Void>
        let pauseTimer: Observable<Void>
        let deleteCode: Observable<Int>
        let search: Observable<String>
    }

    struct Output {
        let fullLoading: Driver<Bool>
        let error: Driver<Error>
        let updateUI: Driver<Void>
        let codeExpired: Driver<Void>
        let codeDeleted: Driver<Void>
        let forceUpdateUI: Driver<Void>
    }
    
    //Coordinator Output
    let routeToDrawer = PublishSubject<Void>()
    let routeToQrScan = PublishSubject<Void>()
    let routeToBindingKey = PublishSubject<AuthCodeData?>()
    
    var data: [AuthCodeTableCell.DisplayModel] = []
    private let maxProgress = 60 // max Seconds 1 minute
    private let warningAt = 45 // Warning Color at seconds
    
    private var pauseTimer: Bool = false
    private var needNewCodes: Bool = true
    private var codes: [AuthCodeData] = []
    
    private let forceUpdateUI = PublishSubject<Void>()
    
    private var searchKeyword: String = ""

    func transform(input: Input) -> Output {

        let activityIndicatorFull = ActivityIndicator()
        let errorTracker = ErrorTracker()

        let timer = Observable<Int>.interval(
            .seconds(1),
            scheduler: MainScheduler.instance
        )
            .mapToVoid()
            .filter { self.hasSavedAuthCode }
            .compactMap(secondsNow)
            .share()
        
        let stopTimer = input.pauseTimer
            .onNext { self.pauseTimer = true }
        
        let startTimer =  input.generateNewCodes
            .filter { self.pauseTimer }
            .onNext {
                self.pauseTimer = false
                self.needNewCodes = true
            }
            .share()
    
        let deleteCode = input.deleteCode
            .onNext {
                self.pauseTimer = true
                self.deleteCode(at: $0)
            }
            .mapToVoid()
        
        let seconds = Observable.merge(input.onViewAppear, startTimer, stopTimer)
            .flatMapLatest {
                timer
                    .take(while: {_ in !self.pauseTimer})
            }
            .share()
        
        let updateSearchKeyword = input.search
            .debounce(.milliseconds(600), scheduler: MainScheduler.instance)
            .onNext {
                self.searchKeyword = $0.trimmingCharacters(in: .whitespacesAndNewlines)
                self.needNewCodes = true
            }
            .mapToVoid()
            .withLatestFrom(seconds)
        
        let updateUI = Observable.merge(seconds, updateSearchKeyword)
            .onNext { _ in
                self.codes = self.generateCodes()
            }
            .compactMap(self.calculateCurrentProgress)
            .map(self.mapToAuthCodeTableCellDisplayModel)
            .onNext { self.data = $0 }
            .mapToVoid()
            .share()
        
        let codeExpired = seconds
            .filter { $0 >= Int(self.maxProgress) }
            .mapToVoid()
            .onNext { self.pauseTimer = true }
            .share()
        
        return Output(
            fullLoading: activityIndicatorFull.asDriver(),
            error: errorTracker.asDriver(),
            updateUI: updateUI.asDriverOnErrorNever(),
            codeExpired: codeExpired.asDriverOnErrorNever(),
            codeDeleted: deleteCode.asDriverOnErrorNever(),
            forceUpdateUI: forceUpdateUI.asDriverOnErrorNever()
        )
    }
}
// MARK: - Business Logic
extension HomeViewModel {
    
    private var hasSavedAuthCode: Bool {
        RealmManager.shared.getAll(AuthCodeData.self).count > 0
    }
    
    private func getUTCTime() -> String {
        let now = Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(abbreviation: "UTC")

        return formatter.string(from: now)
    }
    
    private func secondsNow() -> Int? {
        guard let timerZone = TimeZone(abbreviation: "UTC") else {
            return nil
        }
        let now = Date()
        let calendar = Calendar.current
        var utcCalendar = calendar
        utcCalendar.timeZone = timerZone
        return utcCalendar.component(.second, from: now) + 1
    }
    
    private func calculateCurrentProgress(seconds: Int) -> (progress: CGFloat, color: UIColor)? {
        return (
            progress: CGFloat(seconds) / CGFloat(maxProgress),
            color: seconds >= warningAt ? Color.redBold : Color.txtColor
        )
    }
    
    func getCodeData(at index: Int) -> AuthCodeData? {
        guard index < codes.count else { return nil }
        return codes[index]
    }
    
    private func deleteCode(at index: Int) {
        guard index < codes.count else { return }
        if let record = RealmManager.shared.getByPrimaryKey(AuthCodeData.self, key: codes[index].id) {
            RealmManager.shared.delete(record)
            codes.remove(at: index)
            data.remove(at: index)
            forceUpdateUI.onNext(())
        }
        
    }
}
// MARK: - API calls
extension HomeViewModel {

}
// MARK: - Mapping & Data
private extension HomeViewModel {
    func mapToAuthCodeTableCellDisplayModel(progress: CGFloat, color: UIColor) -> [AuthCodeTableCell.DisplayModel] {
    
        return codes.map {
            AuthCodeTableCell.DisplayModel(
                title: $0.name,
                code: $0.code,
                progress: progress,
                color: color
            )
        }
    }
    
    func generateCodes() -> [AuthCodeData] {
        if !needNewCodes { return codes }
        needNewCodes = false
        
        return RealmManager.shared.getAll(AuthCodeData.self)
            .filter {
                if self.searchKeyword.isEmpty { return true }
                return $0.name.contains(self.searchKeyword)
            }
            .map {
                let authCode = $0
                let number = String(format: "%06d", Int.random(in: 0...999_999))
                authCode.code = number.inserting(separator: " ", every: 3)
                return authCode
            }
    }
}
