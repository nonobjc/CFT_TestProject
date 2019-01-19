//
//  PersistentService.swift
//  CFT_TestProject
//
//  Created by Alexander on 27/11/2018.
//  Copyright © 2018 Alexander. All rights reserved.
//

import UIKit
import CoreData

final class PersistentService {
    
    private var images = [FilterImage]()
    
    init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.coreDataStack.managedObjectContext
        let fetchRequest = NSFetchRequest<FilterImage>(entityName: "FilterImage")
        do {
            images = try managedContext?.fetch(fetchRequest) ?? []
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func getData() -> [FilteredImage] {
        var result = [FilteredImage]()
        for (index, object) in images.enumerated() {
            var image = UIImage()
            if let data = object.image {
                image = UIImage(data: data) ?? UIImage()
            }
            let filter = ImageFilter(rawValue: object.filter) ?? .rotate
            let filteredImage = FilteredImage(inputImage: image,
                                              filter: filter,
                                              arrayIndex: index)
            filteredImage.outputImage = image
            filteredImage.filterFinished = true
            filteredImage.managedObject = object
            result.append(filteredImage)
        }
        return result
    }
    
    func save(filteredImage: FilteredImage) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let managedContext = appDelegate.coreDataStack.managedObjectContext else {
            return
        }
        guard let entity = NSEntityDescription.entity(forEntityName: "FilterImage",
                                                      in: managedContext) else {
            return
        }
        guard let imageObject = NSManagedObject(entity: entity,
                                                insertInto: managedContext) as? FilterImage else {
            return
        }
        imageObject.filter = filteredImage.filter.getText()
        imageObject.image = filteredImage.outputImage?.png
        filteredImage.managedObject = imageObject
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func delete(filteredImage: FilteredImage) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let managedContext = appDelegate.coreDataStack.managedObjectContext,
            let object = filteredImage.managedObject else {
                return
        }
        managedContext.delete(object)
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
