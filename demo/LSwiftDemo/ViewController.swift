import UIKit

class ViewController: UIViewController {

	@IBOutlet var label_test: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
		label_test.text = LS.demo.test.STR
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
