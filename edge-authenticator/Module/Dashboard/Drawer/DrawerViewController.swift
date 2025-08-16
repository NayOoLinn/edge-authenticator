import RxSwift
import UIKit

class DrawerViewController: BaseViewController, ViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var howItWorksButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    
    var viewDidSet = false
    var contentViewOriginalCenterX: CGFloat = 0
    
    let appearAnimationDuration: TimeInterval = 0.3
    let disappearAnimationDuration: TimeInterval = 0.3
    
    typealias ViewModelType = DrawerViewModel
    var viewModel: ViewModelType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel(viewModel)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewDidSet { return }
        viewDidSet = true
        appearAnimation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addTapGesture()
        addPanGesture()
    }

    override func setUpViews() {
        self.view.backgroundColor = .clear
        contentRightConstraint.constant = UIScreen.main.bounds.width * 0.25
        
        contentView.roundCorners(radius: 12, corners: [.topRight, .bottomRight])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.quit))
        backgroundView.addGestureRecognizer(tap)
        
        addBlurEffect()
        setUpAnimation()
    }

    override func bindActions() {
        howItWorksButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.quit()
        }).disposed(by: disposeBag)
        
        settingButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.quit()
        }).disposed(by: disposeBag)
        
        helpButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.quit()
        }).disposed(by: disposeBag)
    }

    func bindViewModel(_ viewModel: DrawerViewModel) {
        self.viewModel = viewModel

        let input = DrawerViewModel.Input(
            onViewAppear: rx.viewWillAppear.take(1).mapToVoid(),
        )

        let output = viewModel.transform(input: input)

        output.fullLoading.drive(onNext: { [weak self] in
            self?.showHideFullLoading($0)
        }).disposed(by: disposeBag)

        output.error.drive(onNext: { [weak self] in
            self?.showAlert(
                message: $0.localizedDescription
            )
        }).disposed(by: disposeBag)
    }
}
// MARK: - Update UI
extension DrawerViewController {

    func updateUI() {
        
    }
}
// MARK: - Animation
extension DrawerViewController {
    
    @objc open func quit() {
        disappearAnimation()
        DispatchQueue.main.asyncAfter(
            deadline: .now() + disappearAnimationDuration/2,
            execute: { [weak self] in
                self?.dismiss(animated: true)
            }
        )
    }
    
    func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.quit))
        backgroundView?.addGestureRecognizer(tap)
    }
    
    func addPanGesture() {
        contentViewOriginalCenterX = contentView.center.x
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(hanldePanGesture(_:)))
        contentView?.addGestureRecognizer(panGesture)
    }
    
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundView?.bounds ?? .zero
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView?.alpha = 0.3
        backgroundView?.addSubview(blurEffectView)
    }
    
    func setUpAnimation() {
        self.contentView?.alpha = 0
    }
    
    func appearAnimation() {
        guard let content = contentView else { return }
        CustomAnimation.moveFrom(
            direction: .LEFT, view: content,
            fromX: UIScreen.main.bounds.width, fromY: 0,
            duration: appearAnimationDuration, delay: 0,
            completed: nil
        )
    }
    
    func disappearAnimation() {
        guard let content = contentView else { return }
        CustomAnimation.moveTo(
            direction: .LEFT, view: content,
            toX: UIScreen.main.bounds.width, toY: 0,
            duration: disappearAnimationDuration, delay: 0,
            completed: nil
        )
    }
    
    @objc func hanldePanGesture(_ panGesture:UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: self.view)
        guard let content = contentView else { return }
        
        switch panGesture.state {
            
        case .cancelled, .ended:
            if content.center.x + contentViewOriginalCenterX < content.frame.width/2 {
                quit()
            } else {
                bounceBackToOrignalPosition()
            }
            
        default:
            if translation.x < 0 {
                content.center = CGPoint(
                    x: contentViewOriginalCenterX + translation.x,
                    y: content.center.y
                )
            }
        }
    }
    
    func bounceBackToOrignalPosition() {
        //usingSpringWithDamping - higher values make the bouncing finish faster.
        //initialSpringVelocity - higher values give the spring more initial momentum.
        UIView.animate(
            withDuration: 0.3, delay: 0,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 0.5,
            options: [.curveEaseInOut],
            animations: {
                self.contentView.center = CGPoint(
                    x: self.contentViewOriginalCenterX,
                    y: self.contentView.center.y
                )
            },
            completion: nil
        )
    }
}
