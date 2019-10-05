import XCTest
import SwiftCheck
import Bow
import BowOptics
import BowOpticsLaws
import BowLaws

class PrismTest: XCTestCase {
    
    func testPrismLaws() {
        PrismLaws.check(prism: stringPrism)
    }
    
    func testSetterLaws() {
        SetterLaws.check(setter: stringPrism.asSetter)
    }
    
    func testOptionalLaws() {
        OptionalLaws.check(optional: stringPrism.asOptional)
    }
    
    func testTraversalLaws() {
        TraversalLaws.check(traversal: stringPrism.asTraversal)
    }
    
    func testPrismAsFold() {
        property("Prism as Fold: size") <~ forAll { (sum: SumType) in
            return sumPrism.asFold.size(sum) == Option.fix(sumPrism.getOption(sum).map(constant(1))).getOrElse(0)
        }
        
        property("Prism as Fold: nonEmpty") <~ forAll { (sum: SumType) in
            return sumPrism.asFold.nonEmpty(sum) == sumPrism.getOption(sum).isDefined
        }
        
        property("Prism as Fold: isEmpty") <~ forAll { (sum: SumType) in
            return sumPrism.asFold.isEmpty(sum) == sumPrism.getOption(sum).isEmpty
        }
        
        property("Prism as Fold: getAll") <~ forAll { (sum: SumType) in
            return sumPrism.asFold.getAll(sum) == sumPrism.getOption(sum).toArray().k()
        }
        
        property("Prism as Fold: combineAll") <~ forAll { (sum: SumType) in
            return sumPrism.asFold.combineAll(sum) == sumPrism.getOption(sum).fold(constant(String.empty()), id)
        }
        
        property("Prism as Fold: fold") <~ forAll { (sum: SumType) in
            return sumPrism.asFold.fold(sum) == sumPrism.getOption(sum).fold(constant(String.empty()), id)
        }
        
        property("Prism as Fold: headOption") <~ forAll { (sum: SumType) in
            return sumPrism.asFold.headOption(sum) == sumPrism.getOption(sum)
        }
        
        property("Prism as Fold: lastOption") <~ forAll { (sum: SumType) in
            return sumPrism.asFold.lastOption(sum) == sumPrism.getOption(sum)
        }
    }
    
    let sumAGen: Gen<SumType> = String.arbitrary.map(SumType.a)
    
    func testPrismProperties() {
        property("Joining two prisms with the same target should yield the same result") <~ forAll { (sum: SumType) in
            return (sumPrism + stringPrism).getOption(sum) == sumPrism.getOption(sum).flatMap(stringPrism.getOption)
        }

        property("Checking if a prism exists with a target") <~ forAll { (a: SumType, b: SumType) in
            return Prism<SumType, SumType>.only(a).isEmpty(b) == (a == b)
        }
        
        property("Checking if there is no target") <~ forAll { (sum: SumType) in
            return sumPrism.isEmpty(sum) == !sum.isA
        }
        
        property("Checking if a target exists") <~ forAll { (sum: SumType) in
            return sumPrism.nonEmpty(sum) == sum.isA
        }
        
        property("Setting a target on a prism should set the correct target") <~ forAll(self.sumAGen, String.arbitrary) { (sum: SumType, str: String) in
            return sumPrism.setOption(sum, str) == Option.some(SumType.a(str))
        }
        
        property("Finding a target using a predicate within a Prism should be wrapped in the correct option result") <~ forAll { (sum: SumType, predicate: Bool) in
            return sumPrism.find(sum, constant(predicate)).fold(constant(false), constant(true)) == (predicate && sum.isA)
        }
        
        property("Checking existence predicate over the target should result in same result as predicate") <~ forAll { (sum: SumType, predicate: Bool) in
            return sumPrism.exists(sum, constant(predicate)) == (predicate && sum.isA)
        }
        
        property("Checking satisfaction of predicate over the target should result in opposite result as predicate") <~ forAll { (sum: SumType, predicate: Bool) in
            return sumPrism.all(sum, constant(predicate)) == (predicate || !sum.isA)
        }
    }
    
    func testPrismComposition() {
        property("Prism + Prism::identity") <~ forAll { (sum: SumType, def: String) in
            return (sumPrism + Prism<String, String>.identity).getOption(sum).getOrElse(def) == sumPrism.getOption(sum).getOrElse(def)
        }
        
        property("Prism + Iso::identity") <~ forAll { (sum: SumType, def: String) in
            return (sumPrism + Iso<String, String>.identity).getOption(sum).getOrElse(def) == sumPrism.getOption(sum).getOrElse(def)
        }
        
        property("Prism + Lens::identity") <~ forAll { (sum: SumType, def: String) in
            return (sumPrism + Lens<String, String>.identity).getOption(sum).getOrElse(def) == sumPrism.getOption(sum).getOrElse(def)
        }
        
        property("Prism + Optional::identity") <~ forAll { (sum: SumType, def: String) in
            return (sumPrism + BowOptics.Optional<String, String>.identity).getOption(sum).getOrElse(def) == sumPrism.getOption(sum).getOrElse(def)
        }
        
        property("Prism + Fold::identity") <~ forAll { (sum: SumType) in
            return (sumPrism + Fold<String, String>.identity).getAll(sum).asArray == sumPrism.getOption(sum).fold(constant([]), { a in [a] })
        }
        
        property("Prism + Traversal::identity") <~ forAll { (sum: SumType) in
            return (sumPrism + Traversal<String, String>.identity).getAll(sum).asArray == sumPrism.getOption(sum).fold(constant([]), { a in [a] })
        }
        
        property("Prism + Setter::identity") <~ forAll { (sum: SumType, def: String) in
            return (sumPrism + Setter<String, String>.identity).set(sum, def) == sumPrism.set(sum, def)
        }
    }
}
