import UIKit
import CoreData
import SystemConfiguration
import SDWebImage

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddProtocol {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var managedContext: NSManagedObjectContext?
    var movies = Array<NSManagedObject>()
    
    @IBOutlet weak var myTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTable.delegate = self
        myTable.dataSource = self
        
        managedContext = appDelegate.persistentContainer.viewContext
        fetchAddedMovies()
        fetchDataFromNetworkIfAvailable()
    }
    
    
    @IBAction func addMovie(_ sender: UIBarButtonItem) {
        let addView = storyboard?.instantiateViewController(identifier: "addView") as! AddViewController
        addView.addProtorocl = self
        navigationController?.pushViewController(addView, animated: true)
        
    }
    
    func addMovie(movie: NSManagedObject) {
        movies.append(movie)
        myTable.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTable.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        
        print(indexPath.row)
        let movieImageURL = movies[indexPath.row].value(forKey: "imageURL")! as! URL
        let movieTitle = movies[indexPath.row].value(forKey: "title")! as! String
        let movieRate = movies[indexPath.row].value(forKey: "rating")! as! Double

        cell.movieImageView?.sd_setImage(with: movieImageURL, completed: {
            (image, error, cache, url) in
            
        })
        cell.movieTitle.text = movieTitle
        cell.movieRate.text = "\(movieRate)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func fetchDataFromNetworkIfAvailable() {
        
        var isNetworkAvailabel = false
        let url = URL(string: "https://api.androidhive.info/json/movies.json")
        let request = URLRequest(url: url!)
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) {
            (data, response, error) in
            do {
                isNetworkAvailabel = true
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! Array<Dictionary<String, Any>>
                self.deleteMoviesFromCoreDate()
                let entity = NSEntityDescription.entity(forEntityName: "RemoteMovie", in: self.managedContext!)
                
                for element in json {
                    
                    let movie = NSManagedObject(entity: entity!, insertInto: self.managedContext!)
                    movie.setValue(URL(string: element["image"] as! String), forKey: "imageURL")
                    movie.setValue(element["title"] as! String, forKey: "title")
                    movie.setValue(element["rating"] as! Double, forKey: "rating")
                    movie.setValue(element["releaseYear"] as! Int64, forKey: "releaseDate")
                    
                    let genreList = element["genre"] as! [String]
                    var genreString = "Genre: "
                    for str in genreList {
                        genreString += str + ", "
                    }
                    
                    genreString.remove(at: genreString.index(before: genreString.endIndex))
                    genreString.remove(at: genreString.index(before: genreString.endIndex))
                    
                    movie.setValue(genreString, forKey: "genre")

                    self.movies.append(movie)
                }
                
                do {
                    try self.managedContext?.save()
                } catch let error as NSError {
                    print(error)
                }
                
                DispatchQueue.main.async {
                    self.myTable.reloadData()
                }
                
            } catch {
                print("error")
            }
        }
        
        task.resume()
        
//        if !isNetworkAvailabel {
//            fetchMoviesWhenNetworkNotAvailabel()
//        }
        
    }
    
    func deleteMoviesFromCoreDate() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "RemoteMovie")
        do {
            let storedRemoteMovies = try (managedContext?.fetch(fetchRequest) ?? Array<NSManagedObject>())
            for movie in storedRemoteMovies {
                managedContext?.delete(movie)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func fetchMoviesWhenNetworkNotAvailabel() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "RemoteMovie")
        do {
            movies = try (managedContext?.fetch(fetchRequest) ?? Array<NSManagedObject>())
            myTable.reloadData()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func fetchAddedMovies() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LocalMovie")
        var localMovies: Array<NSManagedObject>?
        
        do {
            localMovies = try managedContext?.fetch(fetchRequest)
            movies += localMovies!
            
        } catch let error as NSError {
            print(error)
        }
        
        myTable.reloadData()
    }
    
    //    let reachability = SCNetworkReachabilityCreateWithName(nil, "www.bing.com")
    //    func checkReachable() {
    //
    //        var flags = SCNetworkReachabilityFlags()
    //        SCNetworkReachabilityGetFlags(self.reachability!, &flags)
    //        if isNetworkReachable(with: flags) {
    //            print("connected1")
    //            if flags.contains(.isWWAN) {
    //                print("connected")
    //            }
    //        } else {
    //            print("not connected")
    //        }
    //
    //    }
    //
    //    func isNetworkReachable(with flags: SCNetworkReachabilityFlags) -> Bool {
    //        let isReachable = flags.contains(.reachable)
    //        let needsConnection = flags.contains(.connectionRequired)
    //        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
    //        let canConnectWithoutUserInteraction = canConnectAutomatically && flags.contains(.interventionRequired)
    //        return isReachable && (!needsConnection || canConnectWithoutUserInteraction)
    //
    //    }
}

