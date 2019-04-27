// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=testMembersPostfix1 | %FileCheck %s -check-prefix=testMembersPostfix1
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=testMembersDot1 | %FileCheck %s -check-prefix=testMembersDot1
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=testMembersDot2 | %FileCheck %s -check-prefix=testMembersDot2
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=testMultipleSubscript1 | %FileCheck %s -check-prefix=testMultipleSubscript1
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=testInherit1 | %FileCheck %s -check-prefix=testInherit1
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=testInherit2 | %FileCheck %s -check-prefix=testInherit2
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=testShadow1 | %FileCheck %s -check-prefix=testShadow1
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=testGeneric1 | %FileCheck %s -check-prefix=testGeneric1
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=testGenericUnderconstrained1 | %FileCheck %s -check-prefix=testGenericUnderconstrained1
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=testExistential1 | %FileCheck %s -check-prefix=testGenericUnderconstrained1
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=testExistential2 | %FileCheck %s -check-prefix=testExistential2
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=testProtocolConform1 | %FileCheck %s -check-prefix=testProtocolConform1
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=OnSelf1 | %FileCheck %s -check-prefix=OnSelf1
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=testSelfExtension1 | %FileCheck %s -check-prefix=testSelfExtension1
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=testInvalid1 | %FileCheck %s -check-prefix=testInvalid1
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=testInvalid2 | %FileCheck %s -check-prefix=testInvalid2
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=testInvalid3 | %FileCheck %s -check-prefix=testInvalid3
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=testInvalid4 | %FileCheck %s -check-prefix=testInvalid4

struct Point {
  var x: Int
  var y: Int
}

struct Rectangle {
  var topLeft: Point
  var bottomRight: Point
}

@dynamicMemberLookup
struct Lens<T> {
  var obj: T
  init(_ obj: T) { self.obj = obj }

  subscript<U>(dynamicMember member: WritableKeyPath<T, U>) -> Lens<U> {
    get { return Lens<U>(obj[keyPath: member]) }
    set { obj[keyPath: member] = newValue.obj }
  }
}

func testMembersPostfix1(r: Lens<Rectangle>) {
  r#^testMembersPostfix1^#
}

// testMembersPostfix1: Begin completions
// testMembersPostfix1-DAG: Decl[Subscript]/CurrNominal:        [{#dynamicMember: WritableKeyPath<Rectangle, U>#}][#Lens<U>#];

// FIXME: the type should be Lens<Point>
// testMembersPostfix1-DAG: Decl[InstanceVar]/CurrNominal:      .topLeft[#Point#];
// testMembersPostfix1-DAG: Decl[InstanceVar]/CurrNominal:      .bottomRight[#Point#];
// testMembersPostfix1: End completions

func testMembersDot1(r: Lens<Rectangle>) {
  r.#^testMembersDot1^#
}
// testMembersDot1: Begin completions
// FIXME: the type should be Lens<Point>
// testMembersDot1-DAG: Decl[InstanceVar]/CurrNominal:      topLeft[#Point#];
// testMembersDot1-DAG: Decl[InstanceVar]/CurrNominal:      bottomRight[#Point#];
// testMembersDot1: End completions

func testMembersDot2(r: Lens<Rectangle>) {
  r.topLeft.#^testMembersDot2^#
}

// testMembersDot2: Begin completions
// FIXME: the type should be Lens<Int>
// testMembersDot2-DAG: Decl[InstanceVar]/CurrNominal:      x[#Int#];
// testMembersDot2-DAG: Decl[InstanceVar]/CurrNominal:      y[#Int#];
// testMembersDot2: End completions

@dynamicMemberLookup
struct MultipleSubscript {
  subscript<U>(dynamicMember member: KeyPath<Point, U>) -> U {
    return Point(x: 1, y: 2)[keyPath: member]
  }

  subscript<U>(dynamicMember member: KeyPath<Rectangle, U>) -> U {
    return Rectangle(topLeft: Point(x: 0, y: 0), bottomRight: Point(x: 1, y: 1))[keyPath: member]
  }
}

func testMultipleSubscript1(r: MultipleSubscript) {
  r.#^testMultipleSubscript1^#
}

// testMultipleSubscript1: Begin completions
// testMultipleSubscript1-DAG: Decl[InstanceVar]/CurrNominal:      x[#Int#];
// testMultipleSubscript1-DAG: Decl[InstanceVar]/CurrNominal:      y[#Int#];
// testMultipleSubscript1-DAG: Decl[InstanceVar]/CurrNominal:      topLeft[#Point#];
// testMultipleSubscript1-DAG: Decl[InstanceVar]/CurrNominal:      bottomRight[#Point#];
// testMultipleSubscript1: End completions

@dynamicMemberLookup
class Base<T> {
  var t: T
  init(_ t: T) { self.t = t }
  subscript<U>(dynamicMember member: KeyPath<T, U>) -> U {
    return t[keyPath: member]
  }
}

class Inherit1<T>: Base<T> {}

func testInherit1(r: Inherit1<Point>) {
  r.#^testInherit1^#
}
// testInherit1: Begin completions
// testInherit1-DAG: Decl[InstanceVar]/CurrNominal:      x[#Int#];
// testInherit1-DAG: Decl[InstanceVar]/CurrNominal:      y[#Int#];
// testInherit1: End completions

class Inherit2<T, U>: Base<T> {
  var u: U
  init(_ t: T, _ u: U) { super.init(t); self.u = u }
  subscript<V>(dynamicMember member: KeyPath<U, V>) -> V {
    return u[keyPath: member]
  }
}

func testInherit2(r: Inherit2<Point, Rectangle>) {
  r.#^testInherit2^#
}
// testInherit2: Begin completions
// testInherit2-DAG: Decl[InstanceVar]/CurrNominal:      x[#Int#];
// testInherit2-DAG: Decl[InstanceVar]/CurrNominal:      y[#Int#];
// testInherit2-DAG: Decl[InstanceVar]/CurrNominal:      topLeft[#Point#];
// testInherit2-DAG: Decl[InstanceVar]/CurrNominal:      bottomRight[#Point#];
// testInherit2: End completions

class Shadow1<T>: Base<T> {
  var x: String = ""
}

func testShadow1(r: Shadow1<Point>) {
  r.#^testShadow1^#
}
// testShadow1-NOT: x[#Int#];
// testShadow1: Decl[InstanceVar]/CurrNominal:      x[#String#];
// testShadow1-NOT: x[#Int#];
// testShadow1: Decl[InstanceVar]/CurrNominal:      y[#Int#];

@dynamicMemberLookup
protocol P {
  associatedtype T
  subscript<U>(dynamicMember member: KeyPath<T, U>) -> U
}

func testGeneric1<G: P>(r: G) where G.T == Point {
  r.#^testGeneric1^#
}
// testGeneric1: Begin completions
// testGeneric1-DAG: Decl[InstanceVar]/CurrNominal:      x[#Int#];
// testGeneric1-DAG: Decl[InstanceVar]/CurrNominal:      y[#Int#];
// testGeneric1: End completions


func testGenericUnderconstrained1<G: P>(r: G) {
  r.#^testGenericUnderconstrained1^#
}
// testGenericUnderconstrained1-NOT: CurrNominal
// testGenericUnderconstrained1: Keyword[self]/CurrNominal:          self[#{{[GP]}}#];
// testGenericUnderconstrained1-NOT: CurrNominal

func testExistential1(r: P) {
  r.#^testExistential1^#
}

@dynamicMemberLookup
protocol E {
  subscript<U>(dynamicMember member: KeyPath<Point, U>) -> U
}

func testExistential2(r: E) {
  r.#^testExistential2^#
}
// testExistential2: Begin completions
// testExistential2-DAG: Decl[InstanceVar]/CurrNominal:      x[#Int#];
// testExistential2-DAG: Decl[InstanceVar]/CurrNominal:      y[#Int#];
// testExistential2: End completions

struct WithP<T>: P {
  var t: T
  init(t: T) { self.t = t }
  subscript<U>(dynamicMember member: KeyPath<T, U>) -> U {
    return t[keyPath: member]
  }
}

func testProtocolConform1(r: WithP<Point>) {
  r.#^testProtocolConform1^#
}
// testProtocolConform1: Begin completions
// testProtocolConform1-DAG: Decl[InstanceVar]/CurrNominal:      x[#Int#];
// testProtocolConform1-DAG: Decl[InstanceVar]/CurrNominal:      y[#Int#];
// testProtocolConform1: End completions

@dynamicMemberLookup
struct OnSelf {
  subscript<U>(dynamicMember member: KeyPath<Point, U>) -> U {
    return Point(x: 0, y: 1)[keyPath: member]
  }

  func test() {
    self.#^OnSelf1^#
  }
}
// OnSelf1: Begin completions
// OnSelf1-DAG: Decl[InstanceMethod]/CurrNominal:   test()[#Void#];
// OnSelf1-DAG: Decl[InstanceVar]/CurrNominal:      x[#Int#];
// OnSelf1-DAG: Decl[InstanceVar]/CurrNominal:      y[#Int#];
// OnSelf1: End completions

protocol HalfRect {
  var topLeft: Point
}

extension Lens where T: HalfRect {
  func testSelfExtension1() {
    self.#^testSelfExtension1^#
  }
}
// testSelfExtension1-NOT: bottomRight
// testSelfExtension1: Decl[InstanceVar]/CurrNominal:      topLeft[#Point#];
// testSelfExtension1-NOT: bottomRight

struct Invalid1 {
  subscript<U>(dynamicMember member: KeyPath<Rectangle, U>) -> U {
    return Point(x: 0, y: 1)[keyPath: member]
  }
}
func testInvalid1(r: Invalid1) {
  r.#^testInvalid1^#
}
// testInvalid1-NOT: topLeft

@dynamicMemberLookup
struct Invalid2 {
  subscript<U>(dynamicMember: KeyPath<Rectangle, U>) -> U {
    return Point(x: 0, y: 1)[keyPath: dynamicMember]
  }
}
func testInvalid2(r: Invalid2) {
  r.#^testInvalid2^#
}
// testInvalid2-NOT: topLeft

@dynamicMemberLookup
struct Invalid3 {
  subscript<U>(dynamicMember member: Rectangle) -> U {
    return Point(x: 0, y: 1)[keyPath: member]
  }
}
func testInvalid3(r: Invalid3) {
  r.#^testInvalid3^#
}
// testInvalid3-NOT: topLeft

struct NotKeyPath<T, U> {}

@dynamicMemberLookup
struct Invalid4 {
  subscript<U>(dynamicMember member: NotKeyPath<Rectangle, U>) -> U {
    return Point(x: 0, y: 1)[keyPath: member]
  }
}
func testInvalid4(r: Invalid4) {
  r.#^testInvalid4^#
}
// testInvalid4-NOT: topLeft