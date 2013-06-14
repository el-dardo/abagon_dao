library abagon_dao;

import "dart:async";

import "package:unittest/unittest.dart";
import "package:unittest/mock.dart";

part "../lib/src/api.dart";

///////////////////////////////////////////////////////////////////////////////
/// Mocks
class MockDaoImplementation extends Mock implements DaoImplementation {}
class NonAbstractDaoImplementation extends DaoImplementation {}
class MockDao extends Mock implements Dao {}
class MockEntity extends Mock implements ModelEntity {}

///////////////////////////////////////////////////////////////////////////////
/// Tests
void main() {

  group( "API:", () {
    
    setUp( () {
      _implementation = null;
    });
    
    test( "initializeAbagonDao() throws assert if called twice", () {
      initializeAbagonDao(new MockDaoImplementation());
      try {
        initializeAbagonDao(new MockDaoImplementation());
        fail("No exception thrown" );
      } on AssertionError catch( err ) {
        // ok
      }
    });

    test( "initializeAbagonDao() calls init() method of given DaoImplementation", () {
      var impl = new MockDaoImplementation();
      
      initializeAbagonDao(impl);
      
      impl.getLogs(callsTo("init")).verify(happenedOnce);
    });

    test( "closeAbagonDao calls close() method of given DaoImplementation", () {
      
      _implementation = new MockDaoImplementation();
      closeAbagonDao();
      
      (_implementation as MockDaoImplementation).getLogs(callsTo("close")).verify(happenedOnce);
    });

  });
  
  group( "DaoImplementation:", () {
    
    test( "get:entities returns all registered model entities", () {
      var impl = new NonAbstractDaoImplementation();
      var argsList = _generateRegisterClassArgs([MockEntity,String,int,bool]);
      _registerClasses(impl,argsList);
      
      expect( impl.entities, unorderedEquals([MockEntity,String,int,bool]) );
    });

    test( "createDao() returns a Dao from registered generator", () {
      var impl = new NonAbstractDaoImplementation();
      var argsList = _generateRegisterClassArgs([MockEntity]);
      _registerClasses(impl,argsList);
      
      expect( impl.createDao(MockEntity), new isInstanceOf<MockDao>("MockDao") );
    });

    test( "createDao() passes its DaoImplementation to the constructed Dao", () {
      var impl = new NonAbstractDaoImplementation();
      var argsList = _generateRegisterClassArgs([MockEntity]);
      _registerClasses(impl,argsList);
      
      MockDao dao = impl.createDao(MockEntity);
      expect( dao.daoImpl, same(impl) );
    });

    test( "createEntity() returns a ModelEntity from registered entity generator", () {
      var impl = new NonAbstractDaoImplementation();
      var argsList = _generateRegisterClassArgs([MockEntity]);
      _registerClasses(impl,argsList);
      
      expect( impl.createEntity(MockEntity), new isInstanceOf<MockEntity>("MockEntity") );
    });

    test( "createList() returns a correctly typed List from registered list generator", () {
      var impl = new NonAbstractDaoImplementation();
      var argsList = _generateRegisterClassArgs([MockEntity]);
      _registerClasses(impl,argsList);
      
      expect( impl.createList(MockEntity), new isInstanceOf<List<MockEntity>>("List<MockEntity>") );
    });

  }); 
}

void _registerClasses( DaoImplementation impl, List argsList ) {
  for( var args in argsList ) {
    impl.registerClass( args[0], args[1], args[2], args[3] );
  }
}

List _generateRegisterClassArgs( List<Type> types ) {
  var ret = new List();
  for( int i=0 ; i<types.length ; i++ ) {
    ret.add( new List() );
    ret[i].add( types[i] );
    ret[i].add( (daoImpl) {
      var dao = new MockDao();
      dao.when(callsTo("get daoImpl")).alwaysReturn(daoImpl);
      return dao;
    } );
    ret[i].add( ()=>new MockEntity() );
    ret[i].add( ()=>new List<MockEntity>() );
  }  
  return ret;
}