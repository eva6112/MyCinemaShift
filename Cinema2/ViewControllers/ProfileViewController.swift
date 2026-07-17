import UIKit

class ProfileViewController: UIViewController {
    
    private let themeLabel = UILabel()
    private let themeSwitch = UISwitch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Мой профиль"
        view.backgroundColor = .systemBackground
        
        setupUI()
        loadCurrentThemeState()
    }
    
    private func setupUI() {
        themeLabel.text = "Тёмная тема"
        themeLabel.font = .systemFont(ofSize: 17, weight: .medium)
        
        //настройка переключателя
        themeSwitch.addTarget(self, action: #selector(themeSwitchToggled(_:)), for: .valueChanged)
        
        //группируем их в горизонтальный StackView
        let stackView = UIStackView(arrangedSubviews: [themeLabel, themeSwitch])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        //создаем подложку
        let containerView = UIView()
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(stackView)
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            //привязка контейнера к верхней части экрана
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 60),
            
            //привязка StackView внутри контейнера
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    private func loadCurrentThemeState() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        themeSwitch.isOn = isDarkMode
    }
    
    @objc private func themeSwitchToggled(_ sender: UISwitch) {
        let isDarkMode = sender.isOn
        
        //выбор пользователя в память устройства
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
            }, completion: nil)
        }
    }
}
