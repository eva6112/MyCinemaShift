import UIKit

// MARK: - Ячейка каталога фильмов
class FilmCell: UICollectionViewCell {
    
    //для регистрации и переиспользования
    static let identifier = "FilmCell"
    
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let genreLabel = UILabel()
    let detailsButton = UIButton(type: .system)
    
    var onDetailsTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemGray5
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(
            equalTo: imageView.widthAnchor, multiplier: 1.40).isActive = true
        
        nameLabel.font = .systemFont(ofSize: 20, weight: .bold)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 1
                
        genreLabel.font = .systemFont(ofSize: 14, weight: .regular)
        genreLabel.textColor = .systemGray
        genreLabel.numberOfLines = 1
        
        detailsButton.setTitle("Подробнее", for: .normal)
        detailsButton.backgroundColor = .label
        detailsButton.setTitleColor(.systemBackground, for: .normal)
        detailsButton.layer.cornerRadius = 8
        detailsButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        detailsButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        detailsButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        let textStack = UIStackView(arrangedSubviews: [nameLabel, genreLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .fill
        
        let mainStack = UIStackView(arrangedSubviews: [imageView, textStack, detailsButton])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    @objc private func buttonTapped() {
        onDetailsTapped?()
    }
    
    func configure(with film: Film) {
        nameLabel.text = film.name
        genreLabel.text = film.genres?.joined(separator: ", ") ?? ""
        
        if let imgUrl = film.img {
            imageView.loadImage(from: imgUrl)
        }
    }
}

// MARK: - Ячейка Даты
class DateCell: UICollectionViewCell {
    static let identifier = "DateCell"
    private let dateLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        layer.cornerRadius = 20
        backgroundColor = .clear
        
        dateLabel.font = .systemFont(ofSize: 16, weight: .bold)
        dateLabel.textAlignment = .center
        dateLabel.textColor = .label
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18)
        ])
    }
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                if self.isSelected {
                    self.backgroundColor = .label
                    self.dateLabel.textColor = .systemBackground
                    self.layer.shadowColor = UIColor.black.cgColor
                    self.layer.shadowOpacity = 0.08
                    self.layer.shadowOffset = CGSize(width: 0, height: 2)
                    self.layer.shadowRadius = 6
                } else {
                    self.backgroundColor = .clear
                    self.dateLabel.textColor = .label
                    self.layer.shadowOpacity = 0
                }
            }
        }
    }
    
    func configure(dateString: String) {
        dateLabel.text = dateString
    }
}

// MARK: - Ячейка Актера
class ActorCell: UICollectionViewCell {
    static let identifier = "ActorCell"
    
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        //настройка фото
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        //настройка имени
        nameLabel.font = .systemFont(ofSize: 12, weight: .medium)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.2),
                    
                nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 6),
                nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                    
                //выделяем блоку с текстом место ровно под 2 строки
                nameLabel.heightAnchor.constraint(equalToConstant: 34)
            ])
    }
    
    func configure(with actor: Actor) {
        nameLabel.text = actor.fullName
        
        if let imgUrl = actor.photo {
            imageView.loadImage(from: imgUrl)
            
        } else {
            imageView.image = nil
        }
    }
}
