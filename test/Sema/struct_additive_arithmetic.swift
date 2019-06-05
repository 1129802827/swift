// SWIFT_ENABLE_TENSORFLOW
// RUN: %target-swift-frontend -typecheck -verify -primary-file %s %S/Inputs/struct_additive_arithmetic_other_module.swift

func testAdditiveArithmetic<T : AdditiveArithmetic>(
  _ x: inout T
) {
  // Test `AdditiveArithmetic` requirements: `zero`, `+`, `-`.
  let zero = T.zero
  x += x + zero
  x -= x - zero
}

struct Empty : AdditiveArithmetic {}
func testEmpty() {
  var empty = Empty()
  testAdditiveArithmetic(&empty)
}

struct Int2: AdditiveArithmetic {
  var a: Int
  var b: Int
}
func testInt2() {
  var int2 = Int2(a: 1, b: 1)
  testAdditiveArithmetic(&int2)
}

// Test generic type.
struct Vector2<T : AdditiveArithmetic>: AdditiveArithmetic {
  var x: T
  var y: T
}
func testVector2() {
  var vec2 = Vector2<Double>(x: 1, y: 1)
  testAdditiveArithmetic(&vec2)
}

// Test nested type.
struct Nested: AdditiveArithmetic {
  var int2: Int2
  var int: Int
}
func testNested(int2: Int2) {
  var nested = Nested(int2: int2, int: 1)
  testAdditiveArithmetic(&nested)
}

// Test mixed type.
// Note: `Numeric` refines `AdditiveArithmetic`.
struct Mixed: AdditiveArithmetic {
  var nested: Nested
  var float: Float
  var uint8: UInt8
}
func testMixed(nested: Nested) {
  var mixed = Mixed(nested: nested, float: 1, uint8: 1)
  testAdditiveArithmetic(&mixed)
}

// Test type in generic context.
struct A<T> {
  struct B<U, V> {
    struct GenericContextNested : AdditiveArithmetic {
      var nested: Nested
      var float: Float
      var uint8: UInt8
    }
  }
}
func testGenericContext<T, U, V>(nested: Nested) -> A<T>.B<U, V>.GenericContextNested {
  var genericNested =
    A<T>.B<U, V>.GenericContextNested(nested: nested, float: 1, uint8: 1)
  testAdditiveArithmetic(&genericNested)
  return genericNested
}

// Test extension.
struct Extended {
  var x: Int
}
extension Extended : Equatable, AdditiveArithmetic {}

// Test extension of generic type.
struct GenericExtended<T> {
  var x: T
}
extension GenericExtended : Equatable, AdditiveArithmetic where T : AdditiveArithmetic {}

// Test initializer that is not a memberwise initializer because of stored property name vs parameter label mismatch.
struct HasCustomNonMemberwiseInitializer<T : AdditiveArithmetic>: AdditiveArithmetic {
  var value: T
  init(randomLabel value: T) { self.value = value }
}

// Test derived conformances in disallowed contexts.

// expected-error @+1 3 {{implementation of 'AdditiveArithmetic' cannot be automatically synthesized in an extension in a different file to the type}}
extension OtherFileNonconforming : AdditiveArithmetic {}

// expected-error @+1 3 {{implementation of 'AdditiveArithmetic' cannot be automatically synthesized in an extension in a different file to the type}}
extension GenericOtherFileNonconforming : AdditiveArithmetic {}
