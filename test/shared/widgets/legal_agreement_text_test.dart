import 'package:artisans_app/shared/presentation/screens/legal_document_screen.dart';
import 'package:artisans_app/shared/widgets/legal_agreement_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens terms document from agreement link', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LegalAgreementText(
            prefix: 'I agree to the ',
            textStyle: TextStyle(fontSize: 14),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Terms of Service', findRichText: true));
    await tester.pumpAndSettle();

    expect(find.byType(LegalDocumentScreen), findsOneWidget);
    expect(find.text('Terms of Service', findRichText: true), findsWidgets);
  });
}
