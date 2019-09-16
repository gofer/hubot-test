class A {
  constructor() { this.a = 0; this.f(); }

  f() { return console.log('A::f'); }

  g(b = 1) {
    this.b = b;
    console.log('this has a?', Reflect.has(this, 'a'), Reflect.get(this, 'a'));
    console.log('this has b?', Reflect.has(this, 'b'), Reflect.get(this, 'b'));
    console.log('this has c?', Reflect.has(this, 'c'), Reflect.get(this, 'c'));
  }
}

class B extends A {
  constructor() { super(); }

  f() { super.f(); return console.log('B::f'); }
}

console.log('var a = new A();');
var a = new A();
console.log('a', a);
a.g();

console.log('var b = new B();');
var b = new B();
console.log('b', b);
