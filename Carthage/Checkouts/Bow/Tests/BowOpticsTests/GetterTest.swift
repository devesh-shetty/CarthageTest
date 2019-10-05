import XCTest
import SwiftCheck
import Bow
import BowOptics
import BowLaws

class GetterTest : XCTestCase {
    func testGetterAsFold() {
        property("Getter as Fold: size") <~ forAll { (token: Token) in
            return tokenGetter.asFold.size(token) == 1
        }
        
        property("Getter as Fold: nonEmpty") <~ forAll { (token: Token) in
            return tokenGetter.asFold.nonEmpty(token)
        }
        
        property("Getter as Fold: isEmpty") <~ forAll { (token: Token) in
            return !tokenGetter.asFold.isEmpty(token)
        }
        
        property("Getter as Fold: getAll") <~ forAll { (token: Token) in
            return tokenGetter.asFold.getAll(token) == ArrayK.pure(token.value)
        }
        
        property("Getter as Fold: combineAll") <~ forAll { (token: Token) in
            return tokenGetter.asFold.combineAll(token) == token.value
        }
        
        property("Getter as Fold: fold") <~ forAll { (token: Token) in
            return tokenGetter.asFold.fold(token) == token.value
        }
        
        property("Getter as Fold: headOption") <~ forAll { (token: Token) in
            return tokenGetter.asFold.headOption(token) == Option.some(token.value)
        }
        
        property("Getter as Fold: lastOption") <~ forAll { (token: Token) in
            return tokenGetter.asFold.lastOption(token) == Option.some(token.value)
        }
    }
    
    func testGetterProperties() {
        property("Getting the target should yield the exact value") <~ forAll { (value: String) in
            return tokenGetter.get(Token(value: value)) == value
        }
        
        property("Finding a target using a predicate within a Getter should be wrapped in the correct Option result") <~ forAll { (token: Token, predicate : Bool) in
            return tokenGetter.find(token, constant(predicate)).fold(constant(false), constant(true)) == predicate
        }
        
        property("Checking the existence of a target should result in the same result as the predicate") <~ forAll { (token : Token, predicate : Bool) in
            return tokenGetter.exists(token, constant(predicate)) == predicate
        }
        
        property("Zipping two Getters should yield a tuple of the targets") <~ forAll { (value: String) in
            let zippedGetter = lengthGetter.zip(upperGetter)
            return zippedGetter.get(value) == (value.count, value.uppercased())
        }
        
        property("Joining two Getters together with the same target should yield the same result") <~ forAll { (value: String) in
            let userTokenStringGetter = userGetter + tokenGetter
            let joinedGetter = tokenGetter.choice(userTokenStringGetter)
            let token = Token(value: value)
            let user = User(token: token)
            return joinedGetter.get(Either.left(token)) == joinedGetter.get(Either.right(user))
        }
        
        property("Pairing two disjoint Getters should yield a pair of their results") <~ forAll { (token: Token, user: User) in
            let splitGetter = tokenGetter.split(userGetter)
            return splitGetter.get((token, user)) == (token.value, user.token)
        }
        
        property("Creating a first pair with a type should result in the target to value") <~ forAll { (token: Token, value: Int) in
            let first: Getter<(Token, Int), (String, Int)> = tokenGetter.first()
            return first.get((token, value)) == (token.value, value)
        }
        
        property("Creating a second pair with a type should result in the value to target") <~ forAll { (token: Token, value: Int) in
            let second: Getter<(Int, Token), (Int, String)> = tokenGetter.second()
            return second.get((value, token)) == (value, token.value)
        }
        
        property("Creating a left with a type should result in the sum of value and target") <~ forAll { (token: Token, value: Int) in
            let left: Getter<Either<Token, Int>, Either<String, Int>> = tokenGetter.left()
            return left.get(Either.left(token)) == Either.left(tokenIso.get(token)) &&
                left.get(Either.right(value)) == Either.right(value)
        }
        
        property("Creating a right with a type should result in the sum of target and value") <~ forAll { (token: Token, value: Int) in
            let right: Getter<Either<Int, Token>, Either<Int, String>> = tokenGetter.right()
            return right.get(Either.right(token)) == Either.right(tokenIso.get(token)) &&
                right.get(Either.left(value)) == Either.left(value)
        }
    }
    
    func testGetterComposition() {
        property("Getter + Iso::identity") <~ forAll { (token: Token) in
            return (tokenGetter + Iso<String, String>.identity).get(token) == tokenGetter.get(token)
        }
        
        property("Getter + Lens::identity") <~ forAll { (token: Token) in
            return (tokenGetter + Lens<String, String>.identity).get(token) == tokenGetter.get(token)
        }
        
        property("Getter + Getter::identity") <~ forAll { (token: Token) in
            return (tokenGetter + Getter<String, String>.identity).get(token) == tokenGetter.get(token)
        }
        
        property("Getter + Fold::identity") <~ forAll { (token: Token) in
            return (tokenGetter + Fold<String, String>.identity).getAll(token).asArray == [tokenGetter.get(token)]
        }
    }
}
