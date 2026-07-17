import UIKit

class TicketsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Мои билеты"
        view.backgroundColor = .systemBackground
        setupPlaceholder()
    }
    
    private func setupPlaceholder() {
        let label = UILabel()
        label.text = "Купленные билеты появятся здесь"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
