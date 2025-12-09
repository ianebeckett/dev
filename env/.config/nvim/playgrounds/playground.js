// Linter Test File - Contains various common issues
// Test this file with ESLint, Biome, quick-lint-js, etc.

// 1. Unused variables
const unusedVariable = 'I am never used';
let anotherUnused = 42;

// 2. Variable shadowing
function shadowTest() {
  const x = 1;
  if (true) {
    const x = 2; // shadows outer x
    console.log(x);
  }
}

// 3. Unreachable code
function unreachableCode() {
  return true;
  console.log('This will never execute'); // unreachable
}

// 4. Constant condition
if (true) {
  console.log('Always executes');
}

// 5. == instead of ===
function looseEquality(a, b) {
  if (a == b) { // should use ===
    return true;
  }
  return false;
}

// 6. Missing semicolons
const noSemicolon = 'missing semicolon'
const another = 'also missing'

// 7. Var instead of let/const
var oldStyle = 'should use let or const';

// 8. Console.log in production code
console.log('Debug statement');

// 9. Debugger statement
debugger;

// 10. Empty block
function emptyFunction() {
}

if (Math.random() > 0.5) {
}

// 11. Reassigning const (error)
// const immutable = 10;
// immutable = 20; // Uncomment to see error

// 12. Using undefined variable
function undefinedVar() {
  return notDeclared; // not defined
}

// 13. Duplicate keys in object
const obj = {
  name: 'first',
  age: 25,
  name: 'duplicate' // duplicate key
};

// 14. Irregular whitespace
const	tabbed = 'has	tabs';

// 15. Multiple spaces
const  multiSpace  =  'too many spaces';

// 16. No-fallthrough in switch
function switchFallthrough(value) {
  switch (value) {
    case 1:
      console.log('one');
      // missing break
    case 2:
      console.log('two');
      break;
    default:
      console.log('default');
  }
}

// 17. Eqeqeq violations
const isEqual = 1 == '1'; // should use ===
const notEqual = 1 != '1'; // should use !==

// 18. No-eval
const result = eval('2 + 2');

// 19. No-implied-eval
setTimeout('alert("Hello")', 1000); // string as first argument

// 20. Unnecessary escape characters
const str = 'unnecessary \' escape';

// 21. Useless constructor
class UselessConstructor {
  constructor() {
    // empty constructor
  }
}

// 22. No-empty-pattern
function destructure({}) {
  // empty pattern
}

// 23. Missing radix in parseInt
const parsed = parseInt('10');

// 24. Yoda conditions
if ('red' === color) { // backwards comparison
  console.log('is red');
}

// 25. Nested ternary (readability)
const nested = a ? b ? c : d : e;

// 26. Too many parameters
function tooManyParams(a, b, c, d, e, f, g, h, i, j) {
  return a + b + c + d + e + f + g + h + i + j;
}

// 27. Complexity issues
function tooComplex(a, b, c) {
  if (a) {
    if (b) {
      if (c) {
        if (a > b) {
          if (b > c) {
            if (c > 0) {
              return true;
            }
          }
        }
      }
    }
  }
  return false;
}

// 28. Magic numbers
function calculate(value) {
  return value * 3.14159265359; // magic number
}

// 29. No-unused-expressions
function unusedExpression() {
  'use strict';
  1 + 1; // unused expression
}

// 30. Prefer const over let (when not reassigned)
let neverReassigned = 'should be const';
console.log(neverReassigned);

// 31. Missing await in async function
async function noAwait() {
  Promise.resolve(42); // missing await
}

// 32. Array callback return
const numbers = [1, 2, 3];
numbers.map(n => {
  n * 2; // missing return
});

// 33. No-prototype-builtins
const hasOwn = obj.hasOwnProperty('key'); // should use Object.prototype.hasOwnProperty.call

// 34. Prefer template literals
const greeting = 'Hello, ' + name + '!'; // should use template literal

// 35. Arrow function parentheses
const arrow = x => x * 2; // missing parens (depending on config)

// 36. Trailing comma issues
const arr = [
  1,
  2,
  3 // missing or extra trailing comma depending on config
];

// 37. Mixed operators without parentheses
const mixed = a && b || c; // unclear precedence

// 38. Function declarations in blocks (should use arrow)
if (true) {
  function declaredInBlock() {
    return 'should be arrow function';
  }
}

// 39. No-return-assign
function returnAssign(value) {
  return result = value * 2; // assignment in return
}

// 40. Dangling underscore in identifier
const _privateVar = 'leading underscore';

// Export to avoid unused module warning
export { shadowTest, looseEquality, obj };
