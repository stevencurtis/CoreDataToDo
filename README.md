# Core Data to do

A repo for the medium post: 

<https://medium.com/@stevenpcurtis.sc/core-data-basics-swift-persistent-storage-ba3185fe7061>

#Core Data basics: Swift persistent storage

![The Core Data stack](https://github.com/stevencurtis/CoreDataToDo/blob/master/Images/CoreDataBasics.png)


Core data is a great option for persistent data in Swift, but some people find the barriers to using it for their Apps to be too high. So here we will look at the main components of the Core Data stack, break them down and try to make their use comprehensible for the first time user.

**Terminology**

- Core Data: A framework that allows you to manage the model layer objects in your application. Core Data does this by being an object graph management and persistence framework.
- Filtering: A system of reading data and removing data that is not needed.
- Object graph: A view of an object system at any particular point in time.
- Object graph management: Core Data works with defined objects, and core data keeps track of these objects and their relationships with each other.
- Persistence: Data can be retrieved, in this case either from the device or from a network location.
- SQLite: One of the potential data stores that Core Data can use.

**In-depth Core Data Terminology***

- Attribute: Analogous to the columns of a table in a database. These store the values of a Core Data record. These attributes include String, Date, Integer, Float and Boolean. Lower camel case.
- NSEntityDescription (Entity): Analogous to a table in a database, but gives us access to all of the information available about an entity. An instance of NSEntityDescription providing access to properties such as name, the data model the entity is defined in and the name of the class the entity is defined in. Upper camel case.
- NSFetchRequest: Represents a description of search criteria to retrieve data from the persistent store. To use NSFetchRequest you create the request which requires an entity name so it is known which entity to search (or an entity description / or instance of NSEntityDescription).
- NSPersistentContainer: From iOS10 onwards, this made it easier to set up Core Data, hiding the implementation details of how persistent stores are configured. Works as a bridge between the managed object model and the persistent store. By hiding the implementation details NSManagedObjectContext does not need to know which persistent store type is being used, and can manage multiple persistent stores through a single unified interface. Just initialize an NSPersistentContainer, load persistent stores, and you are ready to go!
- NSPersistantStore: Reads and writes data to the backing store. Core Data allows the backing store to be SQLite, Binary, XML and In-memory. (although XML is not available on iOS).
- NSPersistentStoreCoordinator: A coordinator is used to save object graphs to persistent storage and to retrieve model information. The only way for a context to access a model is through a coordinator, giving access to the underlying object stores. This allows you to save and fetch instances of your App's types from stores.
- NSManagedObject: A subclass of NSObject that implements the behaviour required for a Core Data model object. It is not always required to subclass NSManagedObject, they can be used directly.
- NSManagedObjectContext (Managed object context): an environment where we can Create, Read, Update and Delete (CRUD) Core Data objects entirely in memory, before they can be written back to the database. Effectively it tracks the changes to instances of your App's types, and works as an in-memory version of the managed objects until save is called on the context. The object context also manages the lifecycle of it's objects, and each object must exist within a context which it will remain associated with for the duration of its lifecycle although applications can use multiple contexts and actually the same Code Data object can be loaded into two different contexts simultaneously. By setting up multiple managed object contexts it is possible to run concurrent operations and keep long-running operations off the main thread.Contexts are not thread-safe, and neither is a managed object meaning you can only interact with contexts and managed objects on the same thread in which they were created.
- NSManagedObjectModel: Models are usually created using the data modelling tool. Describes the Apps types, including properties and relationships. This means that if a Core Data stack uses SQLite under the hood, this model will represent the schema for the database.
- Relationship: These are properties that store a reference to a Core Data record. Each relationship has a destination, and many are inverse relationships (a teacher has many students, and each student has that teacher). Lower camel case.
- xcdatamodel file: Edited by the visual editor within Xcode. Compiles the model into a set of files in the momd folder. Core Data uses the compiled contents of the momd folder to initialize a NSManagedObjectModel at runtime.

**Notes***

- You save on the context rather than on the objects themselves. This makes sense, as this is the environment that holds the ManagedObjects

**Why use Core Data**
- Rather than writing SQL complex queries can be formed by associating an NSPredicate object with a fetch request
- Change tracking
- Lazy loading of objects
- Pre-built features do not need testing within your App

**xcdatamodeld**
When using coredata a xcdatamodeld file is created, and this is the source file for the Code Data model.
Within this you are able to add attributes, relationships and fetched properties.

![A simple attribute](https://github.com/stevencurtis/CoreDataToDo/blob/master/Images/Attribute.png)

**Storing model objects**
1. **NSManagedObjectContext**
Before using the Core Data store, the context needs to be identified. Each managed object instance exists in a particular context, making it unique to a particular context. You can use multiple managed object contexts to simplify adding new items, and to avoid blocking the UI.

2. **NSManagedObject**
NSManagedObject is a class that implements the behaviour of a Code Data model object. You may just use NSManagedObjects within an Object graph, or may create subclasses of NSManagedObjects. We can think of NSManagedObjects as a dictionary.
you can use **value(forKeyPath keyPath: String) -> Any?** to return the value for a given keypath.
NSManagedObject cannot access attributes directly, so this method of key-value coding allows us to access attributes.

**Faulting**
Sometimes managed objects have not yet been loaded from the data store. In this case a fault fires and the data is retrived.

# Creating a simple To-Do App
1. **Creating the entity**
It seems obvious that you need to create a single view application. However, it is important that you tick the box to set up as Core Data to create the necessary files (however we will NOT use the added code in App delegate in this example).

![A simple attribute](https://github.com/stevencurtis/CoreDataToDo/blob/master/Images/Usecd.png)
Which allows us to set up a simple task entity within the xcdatamodelId file:

![A simple attribute](https://github.com/stevencurtis/CoreDataToDo/blob/master/Images/TaskEntity.png)

Where completed is a boolean if the task is completed, and task is the name of the task.

2. **Setting up the objectContext and entity**
```swift
var objectContext: NSManagedObjectContext! = appDelegate.persistentContainer.viewContext
var entity: NSEntityDescription! = NSEntityDescription.entity(forEntityName: Constants.entityName, in: objectContext)!
```
where
```swift
appDelegate = UIApplication.shared.delegate as? AppDelegate
```
and	
```swift
Constants.entityName = "TaskEntity"
```

3. **Setting up the tableView**
Rather than using an Array of Strings or Structs and Classes Core Data allows us to use an array of NSManagedObject:
```swift
var tasks: [NSManagedObject] = []
```

Which can then be used as the datasource for the UITableView such that

```swift
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
return tasks.count
}
```

although the NSManagedObject actually works much like a dictionary, meaning that we have to return .value(forKeyPath:) to the cell's text label

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
cell.textLabel?.text = tasks[indexPath.row].value(forKeyPath: Constants.entityNameAttribute) as? String
return cell
}
```

4. **Saving**

This is not too tricky, simply taking the object and calling set.Value before .save() of course remembering to add the item to the tableview:
	
```swift
    func save(task: String) {
        let taskObject = NSManagedObject(entity: entity, insertInto: objectContext)
        taskObject.setValue(task, forKeyPath: Constants.entityNameAttribute)
        do {
            try objectContext.save()
            tasks.append(taskObject)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
```

5. **Loading**

This involves making a NSFetchRequest which is called in viewWillAppear, to allow the request to be made when the view is presented.

```swift
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.entityName)
        do {
            tasks = try objectContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    ```
    
NSFetchRequests access existing data, which describing the data that wants to be returned.
This is done by creating a fetch request, and then adding an optional sort and optional predicate:

```swift
let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "entityName")
let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
fetchRequest.sortDescriptors = [sortDescriptor]
let predicate = NSPredicate(format: "name CONTAINS[c] %@","o")
fetchRequest.predicate = predicate
```
which is then fetched using the managed object context

```swift
try managedContext.fetch(fetchRequest)
```

6. **Deleting**

This is a reasonably simple, to remove a specific task it is possible to perform:
```swift
objectContext.delete(task)
```

**Rounding up**

Core Data certainly has much to offer, and has it's own implementation challenges. However it is not necessarily the big beast that it is claimed to be - and can certainly be tamed with some work!
Of course the big issue here, is that the implementation of Core Data is tied up with the view controller, making this near impossible to test.
Guess what a future Medium post is about…

**Want to get in contact? Get in touch on Twitter:**

<https://twitter.com/stevenpcurtis>