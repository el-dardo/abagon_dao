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
  Map<String,DaoGenerator> _daoGenerators = new Map();
  Map<String,ModelEntityGenerator> _modelEntityGenerators = new Map();
  Map<String,ModelEntityListGenerator> _modelEntityListGenerators = new Map();

  void registerClass( String entityName, DaoGenerator daoGenerator, 
      ModelEntityGenerator entityGenerator, 
      ModelEntityListGenerator listGenerator ) {
    _daoGenerators[entityName] = daoGenerator;
    _modelEntityGenerators[entityName] = entityGenerator;
    _modelEntityListGenerators[entityName] = listGenerator;
  }
  
  Iterable<String> get entities => _daoGenerators.keys;
  
  List createList( String entity ) => _modelEntityListGenerators[entity]();
  dynamic createEntity( String entity ) => _modelEntityGenerators[entity]();
  Dao createDao( String entity ) => _daoGenerators[entity](this);
  
  Future init();
  Future close();
}

/**
 * All model entity objects MUST implement this class. The [id] field is always
 * as [String] and it is the responsibility of the specific abagon_dao 
 * implementation to convert it to/from database's native type. It is also the
 * responsibility of the abagon_dao implementation to auto-generate it when a
 * new [ModelEntity] object is persisted to the database.
 */
abstract class ModelEntity {
  String get id;
}

/**
 * All DAO objects must implement this class
 */
abstract class Dao<T extends ModelEntity> {
  Future<List<T>> findAll();
  Future<T> getById( String id );
  /**
   * Saves an existing [ModelEntity] or creates a new one in the database. The
   * behavior depends on the [entity]'s id being informed or not. The method
   * returns the id of the saved [entity] whether it was created or updated.
   */
  Future<String> save( T entity );
  Future delete( T entity );
}

