//
//  MainListViewController.swift
//  AppStoreDemo
//
//  Created by Patrick Tang on 8/7/2021.
//

import UIKit

class MainListViewController: UIViewController {
    // We could build both section using only UICollectionView and custom layout, but that would be time comsuming, so here I just use UICollectionView as UITableView headerView
    
    @IBOutlet weak var listSearchBar: UISearchBar!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private var viewModel: MainListViewModel
    private var grossingAppCollectionView: UICollectionView?

    init(with viewModel: MainListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("No init(coder:) for MainListViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.fetchAllApplication()
        
        setupKeyboard()
        setupSearchBar()
        setupLoadingIndicator()
        setupTableView()
        bind()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func bind() {
        viewModel.grossingAppDidSet = { [weak self] in
            self?.grossingAppCollectionView?.reloadData()
        }
        
        viewModel.freeAppDidSearch = { [weak self] in
            self?.listTableView.reloadData()
        }
        
        viewModel.freeAppWillSet = { [weak self] in
            self?.listTableView.beginUpdates()
        }
        
        viewModel.freeAppDidSet = { [weak self] in
            self?.listTableView.endUpdates()
        }
        
        viewModel.freeAppDidChange = { [weak self] type, indexPath, newIndexPath in
            switch type {
            case .insert:
                if let newIndexPath = newIndexPath {
                    self?.listTableView.insertRows(at: [newIndexPath], with: .automatic)
                }
            case .update:
                if let indexPath = indexPath {
                    self?.listTableView.reloadRows(at: [indexPath], with: .fade)
                }
            case .delete:
                if let indexPath = indexPath {
                    self?.listTableView.deleteRows(at: [indexPath], with: .automatic)
                }
            case .move:
                if let indexPath = indexPath, let newIndexPath = newIndexPath {
                    self?.listTableView.moveRow(at: indexPath, to: newIndexPath)
                }
            default:
                break
            }
        }
        
        viewModel.freeAppSectionDidChange = { [weak self] type, sectionIndex in
            switch type {
            case .insert:
                self?.listTableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                self?.listTableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                break
            }
        }
        
        viewModel.isLoading.bind { [weak self] isLoading in
            self?.loadingIndicator.isHidden = !isLoading
        }
    }
    
    private func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            listTableView.setBottomInset(to: keyboardHeight)
            if let indexPathForSelectedRow = listTableView.indexPathForSelectedRow {
                listTableView.scrollToRow(at: indexPathForSelectedRow, at: .bottom, animated: true)
            }
        }
    }

    @objc private func keyboardWillHide(notification: Notification) {
        listTableView.setBottomInset(to: 0.0)
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.layer.cornerRadius = 15
    }
    
    private func setupSearchBar() {
        listSearchBar.delegate = self
        
        listSearchBar.showsCancelButton = true
    }
    
    private func setupTableView() {
        listTableView.delegate = self
        listTableView.dataSource = self

        listTableView.showsVerticalScrollIndicator = false
        listTableView.register(UINib(nibName: TopFreeTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: TopFreeTableViewCell.identifier)
        
        setupTableViewHeader()
    }
    
    private func setupTableViewHeader() {
        let grossingCollectionViewWidth: CGFloat = 100
        let grossingCollectionViewHeight: CGFloat = 180
        let sectionHeaderHeight: CGFloat = 50
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: sectionHeaderHeight + grossingCollectionViewHeight))
        
        let sectionHeaderLabel = UILabel()
        sectionHeaderLabel.textAlignment = .left
        sectionHeaderLabel.text = "推介"
        sectionHeaderLabel.font = UIFont.systemFont(ofSize: 18)
        
        headerView.addSubview(sectionHeaderLabel)
        
        sectionHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionHeaderLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 8).isActive = true
        sectionHeaderLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 8).isActive = true
        sectionHeaderLabel.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        sectionHeaderLabel.heightAnchor.constraint(equalToConstant: sectionHeaderHeight).isActive = true
        
        // Top Grossing CollectionView
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: grossingCollectionViewWidth, height: grossingCollectionViewHeight)
        layout.minimumLineSpacing = 4
     
        let grossingCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: grossingCollectionViewHeight), collectionViewLayout: layout)
        grossingCollectionView.isPagingEnabled = true
        grossingCollectionView.isUserInteractionEnabled = true
        grossingCollectionView.showsHorizontalScrollIndicator = false
        grossingCollectionView.backgroundColor = .clear
        
//        grossingCollectionView.delegate = self // don't need this for now
        grossingCollectionView.dataSource = self
        
        grossingCollectionView.register(UINib(nibName: RecommandCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: RecommandCollectionViewCell.identifier)
        
        headerView.addSubview(grossingCollectionView)
        self.grossingAppCollectionView = grossingCollectionView
        
        grossingCollectionView.translatesAutoresizingMaskIntoConstraints = false
        grossingCollectionView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 8).isActive = true
        grossingCollectionView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 8).isActive = true
        grossingCollectionView.topAnchor.constraint(equalTo: sectionHeaderLabel.bottomAnchor).isActive = true
        grossingCollectionView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        
        listTableView.tableHeaderView = headerView
    }

}

extension MainListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // search is performed immediately when the keyword is typed which I think is not a good practice, we may add debounce time to perform search only when user stop type for a while
        viewModel.searchFreeApp(name: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

extension MainListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension MainListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.freeAppsFetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let appCount = viewModel.freeAppsFetchedResultsController.sections?[section].numberOfObjects else {
            listTableView.setEmptyMessage("No record found.")
            return 0 }
        
        if appCount == 0 {
            listTableView.setEmptyMessage("No record found.")
        } else {
            listTableView.restoreEmptyMessage()
        }
        
        return appCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listTableView.dequeueReusableCell(withIdentifier: TopFreeTableViewCell.identifier, for: indexPath) as! TopFreeTableViewCell
        
        let freeApp = viewModel.freeAppsFetchedResultsController.object(at: indexPath)

        cell.setDetail(for: freeApp)
        // only fetch those rating & image of visible cell
        viewModel.loadRating(for: freeApp)
        viewModel.loadImage(for: freeApp) { data in
            guard let data = data,
                  let appIconImage = UIImage(data: data),
                  // ensure the cell is the same cell when we call loadImage
                  let cellToBeUpdate = tableView.cellForRow(at: indexPath) as? TopFreeTableViewCell else { return }
            cellToBeUpdate.appIconImageView.image = appIconImage
        }

        if indexPath.row % 2 == 0 {
            cell.setCorner(for: .rounded)
        } else {
            cell.setCorner(for: .circle)
        }
        
        return cell
    }
    
}

extension MainListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.grossingAppsFetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let appCount = viewModel.grossingAppsFetchedResultsController.sections?[section].numberOfObjects else {
            grossingAppCollectionView?.setEmptyMessage("No record found.")
            return 0
        }
        
        if appCount == 0 {
            grossingAppCollectionView?.setEmptyMessage("No record found")
        } else {
            grossingAppCollectionView?.restoreEmptyMessage()
        }
        
        return appCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommandCollectionViewCell.identifier, for: indexPath) as! RecommandCollectionViewCell

        let grossingApp = viewModel.grossingAppsFetchedResultsController.object(at: indexPath)
        cell.setDetail(for: grossingApp)
        
        viewModel.loadImage(for: grossingApp) { data in
            guard let data = data,
                  let appIconImage = UIImage(data: data) else { return }
            
            cell.appIconImageView.image = appIconImage
        }
        
        return cell
    }
    
}


extension UITableView {


    
}
