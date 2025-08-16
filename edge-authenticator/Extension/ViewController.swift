protocol ViewController {

    associatedtype ViewModelType: ViewModel

    var viewModel: ViewModelType! { get set }

    func bindActions()
    
    func bindViewModel(_ viewModel: ViewModelType)
}
