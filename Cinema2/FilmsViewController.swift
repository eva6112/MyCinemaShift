import UIKit

class FilmsViewController: UIViewController {
    
    //св-во, хранящее массив массивов фильмов - секции
    private var filmSections: [[Film]] = []
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Фильмы"
        view.backgroundColor = .systemBackground
        
        //меод настройки колекшон вью
        setupCollectionView()
        //метод загрузки данных из сети
        fetchData()
    }
    
    private func setupCollectionView() {
        //инициализация с заданными размерами
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        //изменение размера при повороте
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        
        //текущий контроллер - делегат и источник данных
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(FilmCell.self, forCellWithReuseIdentifier: FilmCell.identifier)
        
        view.addSubview(collectionView)
    }
    
    //создание композиционного лэйаута
    private func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
                
            if sectionIndex % 2 == 0 {
                // MARK: - Одиночная секция
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(550))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                // Убрали item.contentInsets, чтобы не путать систему
                    
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(550))
                //горизонтальна группа с одним элементом
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                    
                let section = NSCollectionLayoutSection(group: group)
                //отступы на уровне секции
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
                    
                return section
                    
            } else {
                // MARK: - Скролловая секция
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .absolute(365))
                //горизонтальная группа с одним элементом
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                    
                let section = NSCollectionLayoutSection(group: group)
                //горизонтальная прокрутка секции
                section.orthogonalScrollingBehavior = .continuous
                    
                section.interGroupSpacing = 30
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
                    
                return section
            }
        }
            
        // MARK: - Глобальные настройки
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 40
        layout.configuration = config
            
        return layout
    }
    
    private func buildSections(from films: [Film]) {
        filmSections.removeAll()
        var currentIndex = 0
        var isFullWidthRow = true
        
        while currentIndex < films.count {
            let countToTake = isFullWidthRow ? 1 : 4
            let endIndex = min(currentIndex + countToTake, films.count)
            
            let sectionFilms = Array(films[currentIndex..<endIndex])
            filmSections.append(sectionFilms)
            
            currentIndex += countToTake
            //переключение типа секции
            isFullWidthRow.toggle()
        }
    }
    
    //метод для загрузки данных из сети
    private func fetchData() {
        NetworkManager.shared.fetchFilms { [weak self] result in
            
            switch result {
            case .success(let fetchedFilms):
                self?.buildSections(from: fetchedFilms)
                self?.collectionView.reloadData()
                
            case .failure(let error):
                print("Error fetching films: \(error)")
            }
        }
    }
}

//расширение для орисовки
extension FilmsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filmSections.count
    }
    
    //кол-во элементов в секции
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filmSections[section].count
    }
    
    //конфигурация ячейки по индексу
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //извлечение ячейки по идентификатору
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilmCell.identifier, for: indexPath) as! FilmCell
        
        let film = filmSections[indexPath.section][indexPath.item]
        cell.configure(with: film)
        
        //при нажатии на кнопку Подробнее
        cell.onDetailsTapped = { [weak self] in
            let detailsVC = FilmDetailsViewController()
            
            detailsVC.filmId = film.id
            //переход на экран деталей
            self?.navigationController?.pushViewController(detailsVC, animated: true)
        }
        
        return cell
    }
}
