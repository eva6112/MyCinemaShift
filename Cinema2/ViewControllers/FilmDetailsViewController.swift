import UIKit

// MARK: - Структура для группировки данных расписания
struct HallGroup {
    let name: String
    let seances: [Seance]
}

// MARK: - Кнопка времени сеанса
class TimeSlotView: UIView {
    private let timeLabel = UILabel()
    //изображение крестика
    private let crossImageView = UIImageView(image: UIImage(systemName: "xmark"))
    private var widthConstraint: NSLayoutConstraint!
    
    var isSelected: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.5) {
                if self.isSelected {
                    self.backgroundColor = .systemPink
                    self.timeLabel.textColor = .white
                    //крестик
                    self.crossImageView.alpha = 1
                    self.widthConstraint.constant = 110
                } else {
                    self.backgroundColor = .systemGray6
                    self.timeLabel.textColor = .label
                    self.crossImageView.alpha = 0
                    self.widthConstraint.constant = 95
                }
                self.superview?.layoutIfNeeded()
            }
        }
    }
    
    var onTap: (() -> Void)?
    
    init(time: String) {
        super.init(frame: .zero)
        setupUI(time: time)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //настройка времени
    private func setupUI(time: String) {
        layer.cornerRadius = 22
        backgroundColor = .systemGray6
        clipsToBounds = true
        
        timeLabel.font = .systemFont(ofSize: 16, weight: .bold)
        timeLabel.textColor = .label
        timeLabel.text = time
        timeLabel.textAlignment = .center
        
        crossImageView.tintColor = .white
        //изначально скрыт
        crossImageView.alpha = 0
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        crossImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(timeLabel)
        addSubview(crossImageView)
        
        //настройка овального блока
        heightAnchor.constraint(equalToConstant: 44).isActive = true
        widthConstraint = widthAnchor.constraint(equalToConstant: 95)
        widthConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            //отступ слева
            timeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            crossImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            crossImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            crossImageView.widthAnchor.constraint(equalToConstant: 16),
            crossImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        //распознаватель нажатий
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        onTap?()
    }
}

// MARK: - Основной контроллер экрана деталей
class FilmDetailsViewController: UIViewController {
    var filmId: String!
    private var film: Film?
    private var schedules: [Schedule] = []
    private var currentHalls: [HallGroup] = []
    
    //скрол для всего контента
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let actorsTitleLabel = UILabel()
    private var actorsCollectionView: UICollectionView!
    
    private let comingSoonLabel = UILabel()
    
    private var datesCollectionView: UICollectionView!
    private let scheduleStackView = UIStackView()
    
    private let continueButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "О фильме"
        view.backgroundColor = .systemBackground
        setupUI()
        //загрузка данных
        fetchData()
    }
    
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        imageView.backgroundColor = .systemGray5
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 0
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .systemFont(ofSize: 16)
        
        actorsTitleLabel.text = "В ролях:"
        actorsTitleLabel.font = .boldSystemFont(ofSize: 18)
        actorsTitleLabel.isHidden = true
        
        //настройка коллекции актеров
        let actorsLayout = UICollectionViewFlowLayout()
        actorsLayout.scrollDirection = .horizontal
        actorsLayout.itemSize = CGSize(width: 80, height: 135)
        
        actorsLayout.estimatedItemSize = .zero
        
        actorsLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        actorsLayout.minimumInteritemSpacing = 12
        
        actorsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: actorsLayout)
        actorsCollectionView.backgroundColor = .clear
        actorsCollectionView.showsHorizontalScrollIndicator = false
        actorsCollectionView.register(ActorCell.self, forCellWithReuseIdentifier: ActorCell.identifier)
        actorsCollectionView.delegate = self
        actorsCollectionView.dataSource = self
        actorsCollectionView.isHidden = true
        
        //настройка надписи "скоро в прокате"
        comingSoonLabel.text = "скоро в прокате..."
        comingSoonLabel.font = .italicSystemFont(ofSize: 20)
        comingSoonLabel.textColor = .systemGray
        comingSoonLabel.textAlignment = .center
        comingSoonLabel.isHidden = true
        
        scheduleStackView.axis = .vertical
        scheduleStackView.spacing = 24
        scheduleStackView.alignment = .fill
        
        continueButton.setTitle("Продолжить", for: .normal)
        continueButton.backgroundColor = .label
        continueButton.setTitleColor(.systemBackground, for: .normal)
        continueButton.layer.cornerRadius = 12
        continueButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        
        //флоу-лэйаут для дат
        let datesLayout = UICollectionViewFlowLayout()
        datesLayout.scrollDirection = .horizontal
        datesLayout.estimatedItemSize = CGSize(width: 110, height: 44)
        datesLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        datesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: datesLayout)
        datesCollectionView.backgroundColor = .systemGray6
        datesCollectionView.showsHorizontalScrollIndicator = false
        datesCollectionView.register(DateCell.self, forCellWithReuseIdentifier: DateCell.identifier)
        datesCollectionView.delegate = self
        datesCollectionView.dataSource = self
        
        let views = [imageView, titleLabel, descriptionLabel, actorsTitleLabel, actorsCollectionView, comingSoonLabel, datesCollectionView, scheduleStackView, continueButton]
        
        views.forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0!)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: 220),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            //привязка блока актеров
            actorsTitleLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            actorsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            actorsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            actorsCollectionView.topAnchor.constraint(equalTo: actorsTitleLabel.bottomAnchor, constant: 12),
            actorsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            actorsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            actorsCollectionView.heightAnchor.constraint(equalToConstant: 130),
            
            //привязка надписи "скоро в прокате"
            comingSoonLabel.topAnchor.constraint(equalTo: actorsCollectionView.bottomAnchor, constant: 40),
            comingSoonLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            comingSoonLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            //привязка дат и расписания
            datesCollectionView.topAnchor.constraint(equalTo: actorsCollectionView.bottomAnchor, constant: 24),
            datesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            datesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            datesCollectionView.heightAnchor.constraint(equalToConstant: 60),
            
            scheduleStackView.topAnchor.constraint(equalTo: datesCollectionView.bottomAnchor, constant: 24),
            scheduleStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            scheduleStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            continueButton.topAnchor.constraint(equalTo: scheduleStackView.bottomAnchor, constant: 32),
            continueButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            continueButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    //загрузка данных
    private func fetchData() {
        //группа для синхронизации асинхронных запросов
        let group = DispatchGroup()
        
        group.enter()
        //запрос деталей фильма
        NetworkManager.shared.fetchFilmDetails(id: filmId) { [weak self] result in
            
            if case .success(let film) = result { self?.film = film }
            group.leave()
        }
        
        group.enter()
        //запрос расписания
        NetworkManager.shared.fetchSchedule(id: filmId) { [weak self] result in
            
            if case .success(let sched) = result { self?.schedules = sched }
            group.leave()
        }
        
        //после завершения обновляем юи
        group.notify(queue: .main) { [weak self] in
            self?.updateUI()
        }
    }
    
    //заполняет экран данными
    private func updateUI() {
        guard let film = film else { return }
        
        titleLabel.text = film.name
        descriptionLabel.text = film.description ?? "Описание отсутствует"
        
        if let imgUrl = film.img {
            imageView.loadImage(from: imgUrl)
        }
        
        //показываем блок актеров
        if let actors = film.actors, !actors.isEmpty {
            actorsTitleLabel.isHidden = false
            actorsCollectionView.isHidden = false
            actorsCollectionView.reloadData()
        }
        
        datesCollectionView.reloadData()
        
        //логика отображения расписания или заглушки
        if schedules.isEmpty {
            comingSoonLabel.isHidden = false
            datesCollectionView.isHidden = true
            scheduleStackView.isHidden = true
            continueButton.isHidden = true
        } else {
            comingSoonLabel.isHidden = true
            datesCollectionView.isHidden = false
            scheduleStackView.isHidden = false
            continueButton.isHidden = false
            //выбрать первую дату
            selectDate(at: 0)
        }
    }
    
    // MARK: - Построение расписания по дате
    private func selectDate(at index: Int) {
        let selectedSchedule = schedules[index]
        //словарь для группировки по залам
        var dict: [String: [Seance]] = [:]
        var order: [String] = []
        
        for seance in selectedSchedule.seances {
            let hallName = "\(seance.hall.name.capitalized) зал"
            
            //если зала еще нет
            if dict[hallName] == nil {
                dict[hallName] = []
                order.append(hallName)
            }
            dict[hallName]?.append(seance)
        }
        
        currentHalls = order.map { HallGroup(name: $0, seances: dict[$0]!) }
        
        scheduleStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        //массив для всех слотов времени
        var allSlotsOnScreen: [TimeSlotView] = []
        
        for hall in currentHalls {
            let hallLabel = UILabel()
            hallLabel.font = .systemFont(ofSize: 16, weight: .regular)
            hallLabel.textColor = .label
            hallLabel.text = hall.name
            scheduleStackView.addArrangedSubview(hallLabel)
            
            let gridStack = UIStackView()
            gridStack.axis = .vertical
            gridStack.spacing = 12
            gridStack.alignment = .leading
            
            for i in stride(from: 0, to: hall.seances.count, by: 2) {
                let rowStack = UIStackView()
                rowStack.axis = .horizontal
                rowStack.spacing = 12
                rowStack.alignment = .center
                
                let slot1 = TimeSlotView(time: hall.seances[i].time)
                rowStack.addArrangedSubview(slot1)
                allSlotsOnScreen.append(slot1)
                
                if i + 1 < hall.seances.count {
                    let slot2 = TimeSlotView(time: hall.seances[i+1].time)
                    rowStack.addArrangedSubview(slot2)
                    allSlotsOnScreen.append(slot2)
                }
                
                //добавление строки в сетку
                gridStack.addArrangedSubview(rowStack)
            }
            
            //добавление сетки в стек
            scheduleStackView.addArrangedSubview(gridStack)
        }
        
        //нажатие на слот
        for slot in allSlotsOnScreen {
            slot.onTap = { [weak slot] in
                guard let slot = slot else { return }
                
                let state = !slot.isSelected
                allSlotsOnScreen.forEach { $0.isSelected = false }
                slot.isSelected = state
            }
        }
        
        let indexPath = IndexPath(item: index, section: 0)
        datesCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
    }
    
    //форматирование даты
    private func formatDate(_ dateStr: String) -> String {
        let inFormatter = DateFormatter()
        inFormatter.dateFormat = "dd.MM.yyyy"
        guard let date = inFormatter.date(from: dateStr) else { return dateStr }
        
        let outFormatter = DateFormatter()
        //русская локализация
        outFormatter.locale = Locale(identifier: "ru_RU")
        outFormatter.dateFormat = "E, d MMM"
        
        return outFormatter.string(from: date).capitalized
    }
}

// MARK: - Настройка коллекций - актеры и даты
extension FilmDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == actorsCollectionView {
            return film?.actors?.count ?? 0
        }
        return schedules.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == actorsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActorCell.identifier, for: indexPath) as! ActorCell
            if let actor = film?.actors?[indexPath.item] {
                cell.configure(with: actor)
            }
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateCell.identifier, for: indexPath) as! DateCell
        cell.configure(dateString: formatDate(schedules[indexPath.item].date))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == datesCollectionView {
            selectDate(at: indexPath.item)
        }
    }
}
