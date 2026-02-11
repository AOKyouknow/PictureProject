//
//  One.swift
//  HZ
//
//  Created by Алик on 01.10.2025.
//

/*
 На первой вкладке — коллекция случайных фотографий с Unsplash. Вверху строка поиска по фотографиям с Unsplash. При нажатии на ячейку пользователь попадает на экран подробной информации.
 */

import UIKit

class One: UIViewController {
    // MARK: - variables
    private var images: [UIImage] = []
    private var currentPage = 1// Текущая страница, начинаем с 1
    private var isLoading = false// Флаг загрузки, чтобы не грузить одновременно несколько страниц. Чтобы не начать новую загрузку, пока идет старая.
    private let photosPerPage = 30// Сколько фото грузить за раз
    private let unsplashService: UnsplashServiceProtocol = UnsplashService()
    
    private var loadTask: Task<Void, Never>?// async: переменная для хранения Task
    
    //переменные для поиска
    private let searchBar = UISearchBar()
    private let searchButton = UIButton(type: .system)
    private var searchQuery = ""
    
    
    //MARK: - Components
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)// почему здесь self после обращения?это обращение к типу (метатип), а не к экземпляру. Нужно для регистрации класса - Нужно, чтобы система знала, какой класс использовать для создания ячеек
        collectionView.contentInsetAdjustmentBehavior = .always // Включаем автоматическую корректировку safe area
        return collectionView
    }() //здесь исправил. добавил lazy. добавил равно после объявления переменной и скобки после тела ленивого вычисления.
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemRed //TODO: 1 - можно без self
        
        setupUI()
            //setupSearchBar()// добавляем поиск бар) (бара?))))
        setupSearchBar()
        //это прописываю после регистрации cell. сделал модель, зарегистрировал, теперь сюжа прописываю.
        self.collectionView.dataSource = self //TODO: - чтобы показывать ячейки
        self.collectionView.delegate = self//как только прописал эти вещи, потребовалось создать протокол под классом.TODO: для того, чтобы можно было работать с ячейками в целом, обрабатывать тачи и прочее
        self.collectionView.prefetchDataSource = self
        
        //loadRandomPhotos()
        loadPhotos()
        
    }
    // отменяем Task при уходе с экрана
       override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           loadTask?.cancel() // Отменяем текущую загрузку
       }
// MARK: - ЗАГРУЗКА ИЗОБРАЖЕНИЙ. метод с async/await
//        private func loadRandomPhotos() {
//            guard !isLoading else {
//                print("Уже грузится")
//                return
//            }
//            
//            print("Начинается загрузку страницы \(currentPage)")
//            isLoading = true
//            
//            // ОТМЕНЯЕМ предыдущую задачу если она есть
//            loadTask?.cancel()
//            
//            // СОЗДАЕМ новую Task
//            loadTask = Task {
//                do {
//                    // Загружаем фото асинхронно
//                    let downloadedImages = try await unsplashService.fetchRandomPhotosAsync(count: photosPerPage)
//                    
//                    // проверяем не отменили ли задачу
//                    guard !Task.isCancelled else {
//                        print("Задача отменена")
//                        return
//                    }
//                    
//                    // Обновляем UI в главном потоке
//                    await MainActor.run {
//                        self.isLoading = false
//                        
//                        if self.currentPage == 1 {
//                            self.images = downloadedImages
//                        } else {
//                            self.images.append(contentsOf: downloadedImages)
//                        }
//                        
//                        self.currentPage += 1
//                        self.collectionView.reloadData()
//                        
//                        print("Страница \(self.currentPage - 1) загружена: \(downloadedImages.count) фото")
//                    }
//                    
//                } catch {
//                    // Обработка ошибок
//                    guard !Task.isCancelled else {
//                        print("Задача отменена (ошибка)")
//                        return
//                    }
//                    
//                    await MainActor.run {
//                        self.isLoading = false
//                        print("Ошибка загрузки: \(error)")
//                    }
//                }
//            }
//        }
        
    private func loadPhotos() {
        guard !isLoading else { return }
        
        isLoading = true
        loadTask?.cancel()
        
        loadTask = Task {
            do {
                let downloadedImages: [UIImage]
                
                // Если есть поисковый запрос - ищем, если нет - случайные
                if searchQuery.isEmpty {
                    downloadedImages = try await unsplashService.fetchRandomPhotosAsync(count: photosPerPage)
                } else {
                    downloadedImages = try await unsplashService.searchPhotosAsync(
                        query: searchQuery,
                        page: currentPage,
                        perPage: photosPerPage
                    )
                }
                
                await MainActor.run {
                    self.isLoading = false
                    
                    if self.currentPage == 1 {
                        self.images = downloadedImages
                    } else {
                        self.images.append(contentsOf: downloadedImages)
                    }
                    
                    self.currentPage += 1
                    self.collectionView.reloadData()
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }

    // Старый метод используем как обертку для сброса
//    private func loadRandomPhotos() {
//        currentPage = 1
//        loadPhotos()
//    }
    

// MARK: - завершение функции Loading Random Photo!!!!!!!!!!!!
    
        private func loadNextPage() {
            //loadRandomPhotos()
            loadPhotos()
        }
        
  
    private func setupUI() {
        // установил constrains
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false//это необходимо т.к. до констрейнтов использовались так называемые маски, и как только появились констрейнты, айос создали переход с масок на констрейнты с помощью данной переменной, автоматический переход. Когда мы делаем false мы говорим - автоматически не переходим с масок на констрейнты, мы задаем их сами (ниже).
//        NSLayoutConstraint.activate([ //многоо self? команды UIKit для границ. обязательные? -да
//            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
//        ])
//// убираем констрейты из-за конфликта. из-за них не видно бар!!!
    }
    
 // MARK: - setup searchBAR
    private func setupSearchBar() {
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
            searchButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = .white
        view.addSubview(searchButton)// Добавление на view
        searchBar.delegate = self
        searchBar.placeholder = "Поиск..."
        searchBar.showsCancelButton = true
        view.addSubview(searchBar)
        
        
        
        
        // Просто добавьте searchBar над collectionView
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    //из расширения
    //поиск
    //    private let searchBar = UISearchBar()
    //    private let searchButton = UIButton(type: .system)
    //    ПЕРЕМЕННЫЕ ДЛЯ ПОИСКА ПРИШЛОСЬ ПЕРЕМЕСТИТЬ В ОБЪЯВЛЕНИЕ КЛАССА.
//    private func setupSearchBar() { /////////////////// ДОЛЖНА БЫТЬ В КЛАССЕ!!!!!!
//        view.backgroundColor = .white
//        searchBar.delegate = self
//        searchBar.translatesAutoresizingMaskIntoConstraints = false
//        searchBar.searchBarStyle = .default
//        view.addSubview(searchBar)// Добавление на view
//        view.addSubview(searchButton)// Добавление на view
//        NSLayoutConstraint.activate([
//            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
//        ])
//    }
    
}
  // MARK: - ПРОТОКОЛЫ
//Создаём ячейки.
extension One: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath) as? CustomCollectionViewCell
        else {
            fatalError("Failed to dequeue CustomCollectionViewCell in OneController")
        }
        let image = self.images[indexPath.row]
        cell.configure(with: image)
        return cell
    }
}

// НАСТРОЙКА ИЗОБРАЖЕНИЙ В collection view!!!!!!!!!!!!
extension One: UICollectionViewDelegateFlowLayout{
    //набираем sizeForItemAt
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //ИСПРАВЛЯЮ ОТСТУПЫ И РАЗМЕРЫ ЯЧЕЕК!!!!!!!!
        let safeAreaInsets = collectionView.safeAreaInsets//Учитываем safe area insets
        let totalHorizontalInsets = safeAreaInsets.left + safeAreaInsets.right + 2 //отступы с боковых краёв.безопасная зона + 2 пункта.
        
        //Пространство между ячейками: (количество ячеек - 1) * spacing
        let numberOfItemsPerRow: CGFloat = Constants.itemsPerRow // количество ячеек, которое я планирую разместить
        let spacing: CGFloat = Constants.spacing // minimumInteritemSpacing - это расстрояние, которое остаётся между ячейками
    
        let totalSpacing = spacing * (numberOfItemsPerRow - 1) //Рассчитываем общую ширину всех зазоров между ячейками. Пример: Объекта 3, щелей между ними 2. Следовательно формула такая: количество объектов минус 1 (numberOfItemsPerRow - 1). Это число, отражающее количество отступов, мы умножили на минимальное расстояние между ячейками - на spacing.
        
        //Доступная ширина для ячеек
        let availableWidth = collectionView.bounds.width - totalHorizontalInsets - totalSpacing //Рассчитываю доступную ширину для ячеек. Берём общую доступную ширину(collectionView.bounds.width), вычитаем из неё два варианта отступов: отступ с боковых краёв (totalHorizontalInsets), отступ между ячейками (totalSpacing). Получаем пространство за исключением отступов - это всё доступное место для размещения ячеек.
        //Ширина одной ячейки
        let cellWidth = availableWidth / numberOfItemsPerRow // всю доступную ширину делим на количество элементов
        
        // Округляем для пиксельной точности. Один (1) пункт - это 2 или 3 пикселя (в зависимости от экрана). Если ширина 92.333... пункта, могут появиться размытые края. Нецелое число пикселей - это размытые края. Что делает .rounded(.down)? Округляет вниз, чтобы гарантировать, что суммарная ширина ячеек и отступов ≤ ширине collectionView. Если округлить вверх (92.3 → 93), может не хватить места! Округление вниз предотвращает вылезание за границы и обеспечивает четкие края.
        return CGSize(width: cellWidth.rounded(.down), height: cellWidth.rounded(.down))
        }
        
        
    //возвращает минимальное расстояние по вертикали между соседними строками (lines) элементов в одной секции.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    //возвращает минимальное расстояние по горизонтали между соседними элементами (items), которые находятся в одной строке (line).
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    //отступы (Inset) для всей секции. Создает "рамку" или "поля" вокруг всей секции. Особенно важны left и right отступы (10pt), которые не дают ячейкам прижиматься к боковым краям экрана, что улучшает внешний вид, особенно на устройствах с закругленными углами. ПОКА ОСТАВЛЯЮ 0.
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
}
extension One: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView,
                       prefetchItemsAt indexPaths: [IndexPath]) {
        
        // Находим максимальный индекс среди предзагружаемых
        let maxPrefetchIndex = indexPaths.map { $0.row }.max() ?? 0
        
        // Вычисляем насколько далеко от конца
        let distanceFromEnd = images.count - maxPrefetchIndex
        
        print("Максимальный индекс: \(maxPrefetchIndex), от конца: \(distanceFromEnd)")
        
        // Если осталось меньше 5 ячеек до конца
        if distanceFromEnd <= 5 {
            if !isLoading {
                loadNextPage()
            } else {
                print("Уже грузится")
            }
        }
    }
}

extension One: UISearchBarDelegate{
    
        
        
        
        
        //три новых метода!!!!!!!!
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            print("🔍 Поиск: \(searchText)") // Добавьте для отладки
            searchQuery = searchText
            currentPage = 1
            loadPhotos()
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            print("❌ Отмена поиска")
            searchQuery = ""
            searchBar.text = ""
            currentPage = 1
            loadPhotos()
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            print("✅ Поиск выполнен: \(searchBar.text ?? "")")
            searchBar.resignFirstResponder()
        }
    }

