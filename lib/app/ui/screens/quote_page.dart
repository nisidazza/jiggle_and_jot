import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tap_and_jot/app/data/backup_data.dart';
import 'package:tap_and_jot/app/models/api_model.dart';
import 'package:tap_and_jot/app/ui/widgets/single_quote.dart';

class QuotePage extends StatefulWidget {
  const QuotePage({super.key});

  @override
  State<QuotePage> createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  bool shouldDisplay = false;
  bool isOpaque = false;
  bool isBGImgOpaque = false;
  String bookImg = 'assets/quote_BG.jpg';
  late Future<List<Quote>> futureQuotes;
  late Quote currentQuote;

  @override
  void initState() {
    super.initState();
    futureQuotes = fetchQuotes(http.Client());
  }

  void showQuoteOnTap() {
    setState(() {
      shouldDisplay = !shouldDisplay;
      isOpaque = !isOpaque;
      isBGImgOpaque = !isBGImgOpaque;
    });
  }

  getRandomQuote(List<Quote> data) {
    return data[Random().nextInt(data.length)];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showQuoteOnTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                opacity: isBGImgOpaque ? 0.4 : 1.0,
                colorFilter: isBGImgOpaque & kIsWeb
                    ? ColorFilter.mode(
                        Colors.black.withOpacity(0.7), BlendMode.darken)
                    : null,
                image: AssetImage(bookImg),
                fit: BoxFit.cover)),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Quote>>(
                  future: futureQuotes,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      currentQuote = getRandomQuote(backupQuotes);
                      return SingleQuote(
                        quote: currentQuote,
                        shouldDisplay: shouldDisplay,
                        isOpaque: isOpaque,
                      );
                    } else if (snapshot.hasData) {
                      return SingleQuote(
                        quote: getRandomQuote(snapshot.data!),
                        shouldDisplay: shouldDisplay,
                        isOpaque: isOpaque,
                      );
                    } else {
                      return const Center(
                        child: Text('No data available'),
                      );
                    }
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(300, 80),
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.all(0.5)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Back",
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              fontSize: 20))),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}