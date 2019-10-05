import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension OptionT: Arbitrary where F: ArbitraryK, A: Arbitrary {
    public static var arbitrary: Gen<OptionT<F, A>> {
        return Gen.from(OptionTPartial.generate >>> OptionT.fix)
    }
}

// MARK: Instance of `ArbitraryK` for `OptionT`

extension OptionTPartial: ArbitraryK where F: ArbitraryK {
    public static func generate<A: Arbitrary>() -> Kind<OptionTPartial<F>, A> {
        return OptionT(F.generate())
    }
}
