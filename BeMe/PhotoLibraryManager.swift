//
//  PhotoLibraryManager.swift
//  BeMe
//
//  Created by Assistant on 6/8/25.
//

import Photos
import UIKit

class PhotoLibraryManager: ObservableObject {
    static let shared = PhotoLibraryManager()
    
    private var beMeAlbum: PHAssetCollection?
    private let albumName = "BeMe"
    
    private init() {
        setupBeMeAlbum()
    }
    
    // MARK: - Álbum dedicado BeMe
    
    private func setupBeMeAlbum() {
        // Buscar si ya existe el álbum BeMe
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let existingAlbum = collection.firstObject {
            beMeAlbum = existingAlbum
            print("✅ Álbum BeMe encontrado")
        } else {
            createBeMeAlbum()
        }
    }
    
    private func createBeMeAlbum() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)
        }) { [weak self] success, error in
            if success {
                print("✅ Álbum BeMe creado exitosamente")
                self?.setupBeMeAlbum() // Buscar el álbum recién creado
            } else {
                print("❌ Error creando álbum BeMe: \(error?.localizedDescription ?? "Error desconocido")")
            }
        }
    }
    
    func saveImageToBeMeAlbum(_ image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        var localIdentifier: String?
        
        // Primero guardar la imagen en la galería principal
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            request.creationDate = Date()
            localIdentifier = request.placeholderForCreatedAsset?.localIdentifier
        }) { [weak self] success, error in
            if success, let identifier = localIdentifier {
                // Luego agregar la imagen al álbum BeMe
                self?.addImageToBeMeAlbum(with: identifier, completion: completion)
            } else {
                completion(false, error)
            }
        }
    }
    
    private func addImageToBeMeAlbum(with localIdentifier: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let album = beMeAlbum else {
            print("❌ Álbum BeMe no encontrado")
            completion(false, NSError(domain: "PhotoLibraryManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Álbum BeMe no encontrado"]))
            return
        }
        
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject else {
            print("❌ Asset no encontrado")
            completion(false, NSError(domain: "PhotoLibraryManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Asset no encontrado"]))
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            if let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) {
                albumChangeRequest.addAssets([asset] as NSArray)
            }
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    print("✅ Foto guardada en álbum BeMe exitosamente")
                } else {
                    print("❌ Error agregando foto al álbum BeMe: \(error?.localizedDescription ?? "Error desconocido")")
                }
                completion(success, error)
            }
        }
    }
    
    // MARK: - Utilidades del álbum
    
    func getBeMePhotosCount() -> Int {
        guard let album = beMeAlbum else { return 0 }
        let assets = PHAsset.fetchAssets(in: album, options: nil)
        return assets.count
    }
    
    func getLatestBeMePhoto(completion: @escaping (UIImage?) -> Void) {
        guard let album = beMeAlbum else {
            completion(nil)
            return
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        let assets = PHAsset.fetchAssets(in: album, options: fetchOptions)
        guard let latestAsset = assets.firstObject else {
            completion(nil)
            return
        }
        
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        
        imageManager.requestImage(for: latestAsset,
                                 targetSize: CGSize(width: 300, height: 300),
                                 contentMode: .aspectFill,
                                 options: requestOptions) { image, _ in
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
