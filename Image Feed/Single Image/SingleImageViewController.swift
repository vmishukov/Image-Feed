import UIKit

final class SingleImageViewController : UIViewController {
    // MARK: - IB Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    @IBAction private func didTapShareButton() {
        let share = UIActivityViewController(
            activityItems: [imageView.image as Any],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    // MARK: - Private Properties
    private var alertPresener: AlertPresenterProtocol?
    // MARK: - Public Properties

    var fullImageURL: URL! {
        didSet {
            guard isViewLoaded else { return }
            receiveImage()
        }
    }
    
    func receiveImage() {
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: fullImageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                //self.showError()
                print("")
            }
        }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        receiveImage()
       
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

//MARK: - NetfowkErroAlert
extension SingleImageViewController {
    private func showErrorAlert() {
        let viewModel = AlertModel(
            title: "Что-то пошло не так(",
            message: "Перезапустить загрузку?",
            buttonText: "Ок",
            completion:  {[weak self] in
                guard let self = self else { return }
                self.receiveImage()
            },
            nextButtonText: "Нет",
            nextCompletion: { [weak self] in
                guard let self = self else { return }
                self.dismiss(animated: true)
            })
        alertPresener?.show(model: viewModel)
    }
}
