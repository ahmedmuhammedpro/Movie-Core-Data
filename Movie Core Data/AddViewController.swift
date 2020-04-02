import UIKit
import CoreData

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var genreTF: UITextField!
    @IBOutlet weak var releaseDateTF: UITextField!
    @IBOutlet weak var ratingTF: UITextField!
    public var addProtorocl: AddProtocol!
    var imageURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIBarButtonItem(title: "done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.addMethod(_ :)))
        navigationItem.setRightBarButton(doneButton, animated: true)
        
        titleTF.layer.borderWidth = 1.0
        titleTF.layer.borderColor = UIColor.black.cgColor
        
        ratingTF.layer.borderWidth = 1.0
        ratingTF.layer.borderColor = UIColor.black.cgColor
        
        releaseDateTF.layer.borderWidth = 1.0
        releaseDateTF.layer.borderColor = UIColor.black.cgColor
        
        genreTF.layer.borderWidth = 1.0
        genreTF.layer.borderColor = UIColor.black.cgColor
        
    }

    @IBAction func pickImage(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @objc func addMethod(_ sender: UIBarButtonItem) {
        let movieTitle = titleTF.text
        let movieRate = Double(ratingTF.text!)
        let movieReleaseDate = Int64(releaseDateTF.text!)
        let genre = genreTF.text
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "LocalMovie", in: managedContext)
        let movie = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        movie.setValue(imageURL, forKey: "imageURL")
        movie.setValue(movieTitle, forKey: "title")
        movie.setValue(movieRate, forKey: "rating")
        movie.setValue(movieReleaseDate, forKey: "releaseDate")
        movie.setValue(genre, forKey: "genre")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print(error)
        }
        
        addProtorocl.addMovie(movie: movie)
        navigationController?.popViewController(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let url = info[.imageURL] as? URL {
            imageURL = url
        }
        
        movieImageView.sd_setImage(with: imageURL, completed: nil)
        
        picker.dismiss(animated: true, completion: nil)
    }

}
