part of abagon_dao;

DaoImplementation _implementation;

DaoImplementation get abagon => _implementation;

/**
 * Initialize abagon_dao with a specific DB implementation. Specific 
 * [DaoImplementation]s can be found as separate modules. See 
 * abagon_dao_objectory for an example.
 */
Future initializeAbagonDao( DaoImplementation implementation ) {
  assert(_implementation==null);
  _implementation = implementation;
  return _implementation.init();
}

/**
 * Close abagon_dao connection to DB and clean resources associated to 
 * [DaoImplementation]. Failure to call this method at application's shutdown 
 * may prevent it from exiting.
 */
Future closeAbagonDao() {
  return _implementation.close();
}

/** A function that returns a typed list of model entities */
typedef List ModelEntityListGenerator();

/** A function that returns an instance of a model entity */
typedef ModelEntity ModelEntityGenerator();

/** A function that returns an instance of a Dao */
typedef Dao DaoGenerator( DaoImplementation daoImpl );

/**
 * A [DaoImplementation] encapsulates all DB specific logic for its use by the
 * [Dao]s. Different [DaoImplementation]s can be installed depending on the 
 * underlying database driver to be used.
 */
abstract class DaoImplementation {
  Map<Type,DaoGenerator> _daoGenerators = new Map();
  Map<Type,ModelEntityGenerator> _modelEntityGenerators = new Map();
  Map<Type,ModelEntityListGenerator> _modelEntityListGenerators = new Map();

  void registerClass( Type entityType, DaoGenerator daoGenerator, 
      ModelEntityGenerator entityGenerator, 
      ModelEntityListGenerator listGenerator ) {
    _daoGenerators[entityType] = daoGenerator;
    _modelEntityGenerators[entityType] = entityGenerator;
    _modelEntityListGenerators[entityType] = listGenerator;
  }
  
  Iterable<Type> get entities => _daoGenerators.keys;
  
  List createList( Type entityType ) => _modelEntityListGenerators[entityType]();
  dynamic createEntity( Type entityType ) => _modelEntityGenerators[entityType]();
  Dao createDao( Type entityType ) => _daoGenerators[entityType](this);
  
  Future init();
  Future close();
}

/**
 * All model entity objects MUST implement this class. The [uniqueId] field is 
 * always returned as [String] and it is the responsibility of the specific 
 * abagon_dao implementation to convert it to/from database's native type. It is 
 * also the responsibility of the abagon_dao implementation to auto-generate it 
 * when a new [ModelEntity] object is persisted to the database.
 */
abstract class ModelEntity {
  String get uniqueId;
}

/**
 * All DAO objects must implement this class
 */
abstract class Dao<T extends ModelEntity> {
  
  /**
   * Gets all [ModelEntity]s associated to this DAO.
   */
  Future<List<T>> findAll();
  
  /**
   * Gets a [ModelEntity] by id. Returns null if the instance does not exist.
   */
  Future<T> getById( String id );
  
  /**
   * Saves an existing [ModelEntity] or creates a new one in the database. The
   * behavior depends on the [entity]'s id being informed or not. The method
   * returns the id of the saved [entity] whether it was created or updated.
   */
  Future<String> save( T entity );
  
  Future delete( T entity );
}

