import UIKit

class DetailsViewController: UIViewController {
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var titleTF: UILabel!
    @IBOutlet weak var rateTF: UILabel!
    @IBOutlet weak var releaseTF: UILabel!
    @IBOutlet weak var genreTF: UILabel!
    
    var image: UIImage!
    var movieTitle: String!
    var rate: String!
    var releaseDate: String!
    var genre: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myImageView.image = image
        titleTF.text = movieTitle
        rateTF.text = "Rating: " + rate
        genreTF.text = genre
        releaseTF.text = "Release Date: " + releaseDate
    }

}
