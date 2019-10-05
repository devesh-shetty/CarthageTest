import Bow
import SwiftCheck

extension ForEval: ArbitraryK {
    public static func generate<A: Arbitrary>() -> Kind<ForEval, A> {
        let nowGen = A.arbitrary.map(Eval.now)
        let laterGen = A.arbitrary.map { x in Eval.later { x } }
        let alwaysGen = A.arbitrary.map { x in Eval.always { x } }
        let deferGen = A.arbitrary.map { x in Eval.defer { Eval.now(x) } }
        let generated = Gen.one(of: [nowGen, laterGen, alwaysGen, deferGen]).generate
        return generated
    }
}
