import 'package:amds_core/amds_core.dart';
import 'package:test/test.dart';

void main() {
  group('Validators', () {
    test('required', () {
      expect(Validators.required()(''), isNotNull);
      expect(Validators.required()('  '), isNotNull);
      expect(Validators.required()('x'), isNull);
    });

    test('email', () {
      final v = Validators.email();
      expect(v('not-an-email'), isNotNull);
      expect(v('a@b.co'), isNull);
      expect(v(''), isNull, reason: 'emptiness is required()\'s job');
    });

    test('all runs in order', () {
      final v = Validators.all([Validators.required(), Validators.minLength(3)]);
      expect(v(''), equals('This field is required.'));
      expect(v('ab'), contains('at least 3'));
      expect(v('abc'), isNull);
    });
  });

  group('PasswordPolicy', () {
    const p = PasswordPolicy();
    test('checklist', () {
      final r = p.check('short');
      expect(r['At least 12 characters'], isFalse);
      final ok = p.check('Sup3rSecret!!');
      expect(ok.values.every((v) => v), isTrue);
    });
    test('rejects reuse of current', () {
      expect(p.validate('Sup3rSecret!!', current: 'Sup3rSecret!!'), contains('different'));
    });
  });

  group('Result', () {
    test('fold', () {
      const Result<int> s = Result.success(42);
      expect(s.fold(onSuccess: (v) => v * 2, onFailure: (_) => -1), 84);
      const Result<int> e = Result.failure(NotFoundFailure());
      expect(e.fold(onSuccess: (_) => 0, onFailure: (f) => f.message), 'This item no longer exists.');
    });

    test('guard catches', () async {
      final r = await Result.guard<int>(() async => throw StateError('boom'));
      expect(r.isFailure, isTrue);
    });
  });

  group('AmdsFormatters', () {
    final f = AmdsFormatters(clock: () => DateTime(2026, 9, 7, 12));
    test('relative', () {
      expect(f.relative(DateTime(2026, 9, 7, 11, 58)), '2m ago');
      expect(f.relative(DateTime(2026, 9, 6, 12)), 'Yesterday');
    });
    test('compact number', () {
      expect(f.compactNumber(1234), '1,234');
      expect(f.compactNumber(12400), '12K');
    });
    test('currency from minor units', () {
      expect(f.currency(1299, currencyCode: 'USD'), contains('12.99'));
    });
  });
}
