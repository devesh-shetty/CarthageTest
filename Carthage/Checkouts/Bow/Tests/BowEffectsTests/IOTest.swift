import XCTest
import SwiftCheck
@testable import BowLaws
import Bow
@testable import BowEffects
import BowEffectsGenerators
import BowEffectsLaws

class IOTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<IOPartial<CategoryError>, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<IOPartial<CategoryError>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<IOPartial<CategoryError>>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<IOPartial<CategoryError>>.check()
    }
    
    func testMonadLaws() {
        MonadLaws<IOPartial<CategoryError>>.check()
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<IOPartial<CategoryError>>.check()
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<IOPartial<CategoryError>>.check()
    }
    
    func testMonadDeferLaws() {
        MonadDeferLaws<IOPartial<CategoryError>>.check()
    }
    
    func testAsyncLaws() {
        AsyncLaws<IOPartial<CategoryError>>.check()
    }
    
    func testBracketLaws() {
        BracketLaws<IOPartial<CategoryError>>.check()
    }
}

extension IOPartial: EquatableK where E: Equatable {
    public static func eq<A: Equatable>(_ lhs: Kind<IOPartial<E>, A>, _ rhs: Kind<IOPartial<E>, A>) -> Bool {
        var aValue, bValue : A?
        var aError, bError : E?
        
        do {
            aValue = try IO.fix(lhs).unsafeRunSync()
        } catch let error as E {
            aError = error
        } catch {
            fatalError("IO did not handle error \(error). Only errors of type \(E.self) are handled.")
        }
        
        do {
            bValue = try IO.fix(rhs).unsafeRunSync()
        } catch let error as E {
            bError = error
        } catch {
            fatalError("IO did not handle error \(error). Only errors of type \(E.self) are handled.")
        }
        
        if let aV = aValue, let bV = bValue {
            return aV == bV
        } else if let aE = aError, let bE = bError {
            return aE == bE
        } else {
            return false
        }
    }
}
