import UIKit

extension UICollectionView {

    func deque<cell: UICollectionViewCell>(_ cell: cell.Type, index: IndexPath) -> cell {
        return dequeueReusableCell(withReuseIdentifier: cell.className, for: index) as! cell
    }

    func dequeHeader<view: UICollectionReusableView>(_ view: view.Type, index: IndexPath) -> view {
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: view.className, for: index) as! view
    }

    func dequeFooter<view: UICollectionReusableView>(_ view: view.Type, index: IndexPath) -> view {
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: view.className, for: index) as! view
    }

    func register(nib nibName: String, bundle: Bundle? = nil) {
        let nib = UINib(nibName: nibName, bundle: bundle)
        register(nib, forCellWithReuseIdentifier: nibName)
    }

    func register(nibs nibName: [String], bundle: Bundle? = nil) {
        nibName.forEach { register(nib: $0, bundle: bundle) }
    }

    func registerSectionHeader(nib nibName: String, bundle: Bundle? = nil) {
        let nib = UINib(nibName: nibName, bundle: bundle)
        register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: nibName)
    }
}
