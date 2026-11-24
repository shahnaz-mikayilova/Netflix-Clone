//
//  HomeViewController.swift
//  Netflix-Clone
//
//  Created by Shahnaz on 09.01.26.
//

import UIKit

enum Sections: Int {
    case TrendingMovies = 0
    case TrendingTV = 1
    case Popular = 2
    case Upcoming = 3
    case TopRated = 4
}

class HomeViewController: UIViewController {
    
    private var randomTrendingMovie: Title?
    private var headerView: HeroHeaderUIView?
    
    let sectionTitles: [String] = [
        "Trending Movies",
        "Trending Tv",
        "Popular",
        "Upcoming Movies",
        "Top rated"
    ]
    
    private let homeFeedTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(CollectionViewTableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.identifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        navigationController?.hidesBarsOnSwipe = true
        
        view.addSubview(homeFeedTable)
        homeFeedTable.delegate = self
        homeFeedTable.dataSource = self
        
        configureNavbar()
        
        headerView = HeroHeaderUIView(
            frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 500)
        )
        
        homeFeedTable.tableHeaderView = headerView
        
        configureHeroHeaderView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeFeedTable.frame = view.bounds
    }
    
    private func configureHeroHeaderView() {
        APICaller.shared.getTrendingMovies { [weak self] result in
            switch result {
            case .success(let titles):
                let selectedTitle = titles.randomElement()
                self?.randomTrendingMovie = selectedTitle
                self?.headerView?.configure(
                    with: TitleViewModel(
                        titleName: selectedTitle?.original_title ?? "",
                        posterURL: selectedTitle?.poster_path ?? ""
                    )
                )
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func configureNavbar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .white
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.isTranslucent = false
        
        let logoImageView = UIImageView(
            image: UIImage(named: "netflixLogo")?.withRenderingMode(.alwaysOriginal)
        )
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let logoContainer = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        logoContainer.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: logoContainer.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 30),
            logoImageView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoContainer)
        
        let playItem = UIBarButtonItem(
            image: UIImage(systemName: "play.rectangle"),
            style: .plain,
            target: nil,
            action: nil
        )
        
        let profileItem = UIBarButtonItem(
            image: UIImage(systemName: "person"),
            style: .plain,
            target: nil,
            action: nil
        )
        
        navigationItem.rightBarButtonItems = [profileItem, playItem]
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CollectionViewTableViewCell.identifier,
            for: indexPath
        ) as? CollectionViewTableViewCell else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        
        switch indexPath.section {
        case Sections.TrendingMovies.rawValue:
            APICaller.shared.getTrendingMovies { result in
                if case .success(let titles) = result {
                    cell.configure(with: titles)
                }
            }
        case Sections.TrendingTV.rawValue:
            APICaller.shared.getTrendingTvs { result in
                if case .success(let titles) = result {
                    DispatchQueue.main.async {
                        cell.configure(with: titles)
                    }
                }
            }
        case Sections.Popular.rawValue:
            APICaller.shared.getPopular { result in
                if case .success(let titles) = result {
                    cell.configure(with: titles)
                }
            }
        case Sections.Upcoming.rawValue:
            APICaller.shared.getUpcomingMovies { result in
                if case .success(let titles) = result {
                    cell.configure(with: titles)
                }
            }
        case Sections.TopRated.rawValue:
            APICaller.shared.getTopRated { result in
                if case .success(let titles) = result {
                    cell.configure(with: titles)
                }
            }
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.textColor = .white
        header.textLabel?.text = header.textLabel?.text?.capitalizeFirstLetter()
    }
    
}

extension HomeViewController: CollectionViewTableViewCellDelegate {
    
    func CollectionViewTableViewCellDidTapCell(
        _cell: CollectionViewTableViewCell,
        viewModel: TitlePreviewViewModel
    ) {
        DispatchQueue.main.async { [weak self] in
            let vc = TitlePreviewViewController()
            vc.configure(with: viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
