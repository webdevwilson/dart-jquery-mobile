// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/**
 * Returns a matcher that matches empty strings, maps or collections.
 */
final Matcher isEmpty = const _Empty();

class _Empty extends BaseMatcher {
  const _Empty();
  bool matches(item) {
    if (item is Map || item is Collection) {
      return item.isEmpty();
    } else if (item is String) {
      return item.length == 0;
    } else {
      return false;
    }
  }
  Description describe(Description description) =>
      description.add('empty');
}

/** A matcher that matches any null value. */
final Matcher isNull = const _IsNull();

/** A matcher that matches any non-null value. */
final Matcher isNotNull = const _IsNotNull();

class _IsNull extends BaseMatcher {
  const _IsNull();
  bool matches(item) => item == null;
  Description describe(Description description) =>
      description.add('null');
}

class _IsNotNull extends BaseMatcher {
  const _IsNotNull();
  bool matches(item) => item != null;
  Description describe(Description description) =>
      description.add('not null');
}

/** A matcher that matches the Boolean value true. */
final Matcher isTrue = const _IsTrue();

/** A matcher that matches anything except the Boolean value true. */
final Matcher isFalse = const _IsFalse();

class _IsTrue extends BaseMatcher {
  const _IsTrue();
  bool matches(item) => item == true;
  Description describe(Description description) =>
      description.add('true');
}

class _IsFalse extends BaseMatcher {
  const _IsFalse();
  bool matches(item) => item != true;
  Description describe(Description description) =>
      description.add('false');
}

/**
 * Returns a matches that matches if the value is the same instance
 * as [object] (`===`).
 */
Matcher same(expected) => new _IsSameAs(expected);

class _IsSameAs extends BaseMatcher {
  final _expected;
  const _IsSameAs(this._expected);
  bool matches(item) => item === _expected;
  // If all types were hashable we could show a hash here.
  Description describe(Description description) =>
      description.add('same instance as ').addDescriptionOf(_expected);
}

/**
 * Returns a matcher that does a deep recursive match. This only works
 * with scalars, Maps and Iterables. To handle cyclic structures a
 * recursion depth [limit] can be provided. The default limit is 100.
 */
Matcher equals(expected, [limit=100]) =>
    new _DeepMatcher(expected, limit);

class _DeepMatcher extends BaseMatcher {
  final _expected;
  final int _limit;
  var count;

  _DeepMatcher(this._expected, [limit = 1000]) : this._limit = limit;

  String _compareIterables(expected, actual, matcher, depth) {
    if (actual is !Iterable) {
      return 'is not Iterable';
    }
    var expectedIterator = expected.iterator();
    var actualIterator = actual.iterator();
    var position = 0;
    String reason = null;
    while (reason == null) {
      if (expectedIterator.hasNext()) {
        if (actualIterator.hasNext()) {
          Description r = matcher(expectedIterator.next(),
                           actualIterator.next(),
                           'mismatch at position ${position}',
                           depth);
          if (r != null) reason = r.toString();
          ++position;
        } else {
          reason = 'shorter than expected';
        }
      } else if (actualIterator.hasNext()) {
        reason = 'longer than expected';
      } else {
        return null;
      }
    }
    return reason;
  }

  Description _recursiveMatch(expected, actual, String location, int depth) {
    Description reason = null;
    // If _limit is 1 we can only recurse one level into object.
    bool canRecurse = depth == 0 || _limit > 1;
    if (expected == actual) {
      // Do nothing.
    } else if (depth > _limit) {
      reason = new StringDescription('recursion depth limit exceeded');
    } else {
      if (expected is Iterable && canRecurse) {
        String r = _compareIterables(expected, actual,
          _recursiveMatch, depth+1);
        if (r != null) reason = new StringDescription(r);
      } else if (expected is Map && canRecurse) {
        if (actual is !Map) {
          reason = new StringDescription('expected a map');
        } else if (expected.length != actual.length) {
          reason = new StringDescription('different map lengths');
        } else {
          for (var key in expected.getKeys()) {
            if (!actual.containsKey(key)) {
              reason = new StringDescription('missing map key ');
              reason.addDescriptionOf(key);
              break;
            }
            reason = _recursiveMatch(expected[key], actual[key],
                'with key <${key}> ${location}', depth+1);
            if (reason != null) {
              break;
            }
          }
        }
      } else {
        // If we have recursed, show the expected value too; if not,
        // expect() will show it for us.
        reason = new StringDescription();
        if (depth > 1) {
          reason.add('expected ').addDescriptionOf(expected).add(' but was ').
              addDescriptionOf(actual);
        } else {
          reason.add('was ').addDescriptionOf(actual);
        }
      }
    }
    if (reason != null && location.length > 0) {
      reason.add(' ').add(location);
    }
    return reason;
  }

  String _match(expected, actual) {
    Description reason = _recursiveMatch(expected, actual, '', 0);
    return reason == null ? null : reason.toString();
  }

  bool matches(item) => _match(_expected, item) == null;

  Description describe(Description description) =>
    description.addDescriptionOf(_expected);

  Description describeMismatch(item, Description mismatchDescription) =>
    mismatchDescription.add(_match(_expected, item));
}

/** A matcher that matches any value. */
final Matcher anything = const _IsAnything();

class _IsAnything extends BaseMatcher {
  const _IsAnything();
  bool matches(item) => true;
  Description describe(Description description) =>
      description.add('anything');
}

/**
 * Returns a matcher that matches if an object is an instance
 * of [type] (or a subtype).
 *
 * As types are not first class objects in Dart we can only
 * approximate this test by using a generic wrapper class.
 *
 * For example, to test whether 'bar' is an instance of type
 * 'Foo', we would write:
 *
 *     expect(bar, new isInstanceOf<Foo>());
 *
 * To get better error message, supply a name when creating the
 * Type wrapper; e.g.:
 *
 *     expect(bar, new isInstanceOf<Foo>('Foo'));
 */
class isInstanceOf<T> extends BaseMatcher {
  final String _name;
  const isInstanceOf([name = 'specified type']) : this._name = name;
  bool matches(obj) => obj is T;
  // The description here is lame :-(
  Description describe(Description description) =>
      description.add('an instance of ${_name}');
}

/**
 * This can be used to match two kinds of objects:
 *
 *   * A [Function] that throws an exception when called. The function cannot
 *     take any arguments. If you want to test that a function expecting
 *     arguments throws, wrap it in another zero-argument function that calls
 *     the one you want to test. The function will be called once upon success,
 *     or twice upon failure (the second time to get the failure description).
 *
 *   * A [Future] that completes with an exception. Note that this creates an
 *     asynchronous expectation. The call to `expect()` that includes this will
 *     return immediately and execution will continue. Later, when the future
 *     completes, the actual expectation will run.
 */
final Matcher throws = const _Throws();

/**
 * This can be used to match two kinds of objects:
 *
 *   * A [Function] that throws an exception when called. The function cannot
 *     take any arguments. If you want to test that a function expecting
 *     arguments throws, wrap it in another zero-argument function that calls
 *     the one you want to test.
 *
 *   * A [Future] that completes with an exception. Note that this creates an
 *     asynchronous expectation. The call to `expect()` that includes this will
 *     return immediately and execution will continue. Later, when the future
 *     completes, the actual expectation will run.
 *
 * In both cases, when an exception is thrown, this will test that the exception
 * object matches [matcher]. If [matcher] is not an instance of [Matcher], it
 * will implicitly be treated as `equals(matcher)`.
 */
Matcher throwsA(matcher) => new _Throws(wrapMatcher(matcher));

/**
 * A matcher that matches a function call against no exception.
 * The function will be called once. Any exceptions will be silently swallowed.
 * The value passed to expect() should be a reference to the function.
 * Note that the function cannot take arguments; to handle this
 * a wrapper will have to be created.
 */
final Matcher returnsNormally = const _ReturnsNormally();

class _Throws extends BaseMatcher {
  final Matcher _matcher;

  const _Throws([Matcher matcher = null]) : this._matcher = matcher;

  bool matches(item) {
    if (item is Future) {
      // Queue up an asynchronous expectation that validates when the future
      // completes.
      item.onComplete(expectAsync1((future) {
        if (future.hasValue) {
          expect(false, reason:
              "Expected future to fail, but succeeded with '${future.value}'.");
        } else if (_matcher != null) {
          var reason;
          if (future.stackTrace != null) {
            var stackTrace = future.stackTrace.toString();
            stackTrace = "  ${stackTrace.replaceAll("\n", "\n  ")}";
            reason = "Actual exception trace:\n$stackTrace";
          }
          expect(future.exception, _matcher, reason: reason);
        }
      }));

      // It hasn't failed yet.
      return true;
    }

    try {
      item();
      return false;
    } catch (final e) {
      return _matcher == null || _matcher.matches(e);
    }
  }

  Description describe(Description description) {
    if (_matcher == null) {
      return description.add("throws an exception");
    } else {
      return description.add('throws an exception which matches ').
          addDescriptionOf(_matcher);
    }
  }

  Description describeMismatch(item, Description mismatchDescription) {
    if (_matcher == null) {
      return mismatchDescription.add(' no exception');
    } else {
      return mismatchDescription.
          add(' no exception or exception does not match ').
          addDescriptionOf(_matcher);
    }
  }
}

class _ReturnsNormally extends BaseMatcher {

  const _ReturnsNormally();

  bool matches(f) {
    try {
      f();
      return true;
    } catch (final e) {
      return false;
    }
  }

  Description describe(Description description) =>
      description.add("return normally");

  Description describeMismatch(item, Description mismatchDescription) {
      return mismatchDescription.add(' threw exception');
  }
}

/*
 * Matchers for different exception types. Ideally we should just be able to
 * use something like:
 *
 * final Matcher throwsException =
 *     const _Throws(const isInstanceOf<Exception>());
 *
 * Unfortunately instanceOf is not working with dart2js.
 *
 * Alternatively, if static functions could be used in const expressions,
 * we could use:
 *
 * bool _isException(x) => x is Exception;
 * final Matcher isException = const _Predicate(_isException, "Exception");
 * final Matcher throwsException = const _Throws(isException);
 *
 * But currently using static functions in const expressions is not supported.
 * For now the only solution for all platforms seems to be separate classes
 * for each exception type.
 */

/* abstract */ class _ExceptionMatcher extends BaseMatcher {
  final String _name;
  const _ExceptionMatcher(this._name);
  Description describe(Description description) =>
      description.add(_name);
}

/** A matcher for BadNumberFormatExceptions. */
final isBadNumberFormatException = const _BadNumberFormatException();

/** A matcher for functions that throw BadNumberFormatException */
final Matcher throwsBadNumberFormatException =
    const _Throws(isBadNumberFormatException);

class _BadNumberFormatException extends _ExceptionMatcher {
  const _BadNumberFormatException() : super("BadNumberFormatException");
  bool matches(item) => item is BadNumberFormatException;
}

/** A matcher for Exceptions. */
final isException = const _Exception();

/** A matcher for functions that throw Exception */
final Matcher throwsException = const _Throws(isException);

class _Exception extends _ExceptionMatcher {
  const _Exception() : super("Exception");
  bool matches(item) => item is Exception;
}

/** A matcher for IllegalArgumentExceptions. */
final isIllegalArgumentException = const _IllegalArgumentException();

/** A matcher for functions that throw IllegalArgumentException */
final Matcher throwsIllegalArgumentException =
    const _Throws(isIllegalArgumentException);

class _IllegalArgumentException extends _ExceptionMatcher {
  const _IllegalArgumentException() : super("IllegalArgumentException");
  bool matches(item) => item is IllegalArgumentException;
}

/** A matcher for IllegalJSRegExpExceptions. */
final isIllegalJSRegExpException = const _IllegalJSRegExpException();

/** A matcher for functions that throw IllegalJSRegExpException */
final Matcher throwsIllegalJSRegExpException =
    const _Throws(isIllegalJSRegExpException);

class _IllegalJSRegExpException extends _ExceptionMatcher {
  const _IllegalJSRegExpException() : super("IllegalJSRegExpException");
  bool matches(item) => item is IllegalJSRegExpException;
}

/** A matcher for IndexOutOfRangeExceptions. */
final isIndexOutOfRangeException = const _IndexOutOfRangeException();

/** A matcher for functions that throw IndexOutOfRangeException */
final Matcher throwsIndexOutOfRangeException =
    const _Throws(isIndexOutOfRangeException);

class _IndexOutOfRangeException extends _ExceptionMatcher {
  const _IndexOutOfRangeException() : super("IndexOutOfRangeException");
  bool matches(item) => item is IndexOutOfRangeException;
}

/** A matcher for NoSuchMethodExceptions. */
final isNoSuchMethodException = const _NoSuchMethodException();

/** A matcher for functions that throw NoSuchMethodException */
final Matcher throwsNoSuchMethodException =
    const _Throws(isNoSuchMethodException);

class _NoSuchMethodException extends _ExceptionMatcher {
  const _NoSuchMethodException() : super("NoSuchMethodException");
  bool matches(item) => item is NoSuchMethodException;
}

/** A matcher for NotImplementedExceptions. */
final isNotImplementedException = const _NotImplementedException();

/** A matcher for functions that throw Exception */
final Matcher throwsNotImplementedException =
    const _Throws(isNotImplementedException);

class _NotImplementedException extends _ExceptionMatcher {
  const _NotImplementedException() : super("NotImplementedException");
  bool matches(item) => item is NotImplementedException;
}

/** A matcher for NullPointerExceptions. */
final isNullPointerException = const _NullPointerException();

/** A matcher for functions that throw NotNullPointerException */
final Matcher throwsNullPointerException =
    const _Throws(isNullPointerException);

class _NullPointerException extends _ExceptionMatcher {
  const _NullPointerException() : super("NullPointerException");
  bool matches(item) => item is NullPointerException;
}

/** A matcher for UnsupportedOperationExceptions. */
final isUnsupportedOperationException = const _UnsupportedOperationException();

/** A matcher for functions that throw UnsupportedOperationException */
final Matcher throwsUnsupportedOperationException =
    const _Throws(isUnsupportedOperationException);

class _UnsupportedOperationException extends _ExceptionMatcher {
  const _UnsupportedOperationException() :
      super("UnsupportedOperationException");
  bool matches(item) => item is UnsupportedOperationException;
}

/**
 * Returns a matcher that matches if an object has a length property
 * that matches [matcher].
 */
Matcher hasLength(matcher) =>
    new _HasLength(wrapMatcher(matcher));

class _HasLength extends BaseMatcher {
  final Matcher _matcher;
  const _HasLength([Matcher matcher = null]) : this._matcher = matcher;

  bool matches(item) {
    return _matcher.matches(item.length);
  }

  Description describe(Description description) =>
    description.add('an object with length of ').
        addDescriptionOf(_matcher);

  Description describeMismatch(item, Description mismatchDescription) {
    super.describeMismatch(item, mismatchDescription);
    try {
      // We want to generate a different description if there is no length
      // property. This is harmless code that will throw if no length property
      // but subtle enough that an optimizer shouldn't strip it out.
      if (item.length * item.length >= 0) {
        return mismatchDescription.add(' with length of ').
            addDescriptionOf(item.length);
      }
    } catch (var e) {
      return mismatchDescription.add(' has no length property');
    }
  }
}

/**
 * Returns a matcher that matches if the match argument contains
 * the expected value. For [String]s this means substring matching;
 * for [Map]s is means the map has the key, and for [Collection]s it
 * means the collection has a matching element. In the case of collections,
 * [expected] can itself be a matcher.
 */
Matcher contains(expected) => new _Contains(expected);

class _Contains extends BaseMatcher {

  final _expected;

  const _Contains(this._expected);

  bool matches(item) {
    if (item is String) {
      return item.indexOf(_expected) >= 0;
    } else if (item is Collection) {
      if (_expected is Matcher) {
        return item.some((e) => _expected.matches(e));
      } else {
        return item.some((e) => e == _expected);
      }
    } else if (item is Map) {
      return item.containsKey(_expected);
    }
    return false;
  }

  Description describe(Description description) =>
      description.add('contains ').addDescriptionOf(_expected);
}

/**
 * Returns a matcher that matches if the match argument is in
 * the expected value. This is the converse of [contains].
 */
Matcher isIn(expected) => new _In(expected);

class _In extends BaseMatcher {

  final _expected;

  const _In(this._expected);

  bool matches(item) {
    if (_expected is String) {
      return _expected.indexOf(item) >= 0;
    } else if (_expected is Collection) {
      return _expected.some((e) => e == item);
    } else if (_expected is Map) {
      return _expected.containsKey(item);
    }
    return false;
  }

  Description describe(Description description) =>
      description.add('is in ').addDescriptionOf(_expected);
}

/**
 * Returns a matcher that uses an arbitrary function that returns
 * true or false for the actual value.
 */
Matcher predicate(f, [description = 'satisfies function']) =>
    new _Predicate(f, description);

class _Predicate extends BaseMatcher {

  final _matcher;
  final String _description;

  const _Predicate(this._matcher, this._description);

  bool matches(item) => _matcher(item);

  Description describe(Description description) =>
      description.add(_description);
}
