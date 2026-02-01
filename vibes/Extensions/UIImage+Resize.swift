import UIKit

extension UIImage {
    func resized(toMaxDimension maxDimension: CGFloat) -> UIImage {
        let aspectRatio = size.width / size.height
        var newSize: CGSize

        if size.width > size.height {
            newSize = CGSize(
                width: min(size.width, maxDimension),
                height: min(size.width, maxDimension) / aspectRatio
            )
        } else {
            newSize = CGSize(
                width: min(size.height, maxDimension) * aspectRatio,
                height: min(size.height, maxDimension)
            )
        }

        // Skip resizing if already small enough
        if newSize.width >= size.width && newSize.height >= size.height {
            return self
        }

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    func jpegData(compressionQuality: CGFloat, maxDimension: CGFloat) -> Data? {
        let resized = resized(toMaxDimension: maxDimension)
        return resized.jpegData(compressionQuality: compressionQuality)
    }
}
