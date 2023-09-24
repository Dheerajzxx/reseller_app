import 'package:flutter/material.dart';
import 'dart:convert';
import '../common/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Faqs extends StatefulWidget {
  const Faqs({super.key});

  @override
  State<Faqs> createState() => _FaqState();
}

class _FaqState extends State<Faqs> {
  String apiToken = '', errMessage = '';
  late FaqApiData faqApiData;
  bool isLoaded = false;
  int _currentIndex = 0;
  PageController? _pageController;

  void getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apiToken = prefs.getString("apiToken") ?? '';
    });
    faqApiData = await getFaqs();
    setState(() {
      isLoaded = true;
    });
  }

  Future<FaqApiData> getFaqs() async {
    final response =
        await http.post(Uri.https(globals.baseURL, "/api/question-history"),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $apiToken'
            },
            body: jsonEncode({}));
    var resCode = response.statusCode;
    if (resCode == 200) {
      setState(() {
        isLoaded = true;
      });
      FaqApiData faqApiData = faqApiDataFromJson(response.body);
      return faqApiData;
    } else {
      errorToast('Oops! Something went wrong.');
      setState(() {
        errMessage = 'Oops! Something went wrong.';
      });
      return FaqApiData(
        message: 'Oops! Something went wrong.',
        faqs: [],
        questions: [],
      );
    }
  }

  errorToast(String toast) {
    return Fluttertoast.showToast(
        msg: toast,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        webPosition: "center",
        webBgColor: "linear-gradient(to top, red, yellow)",
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  @override
  void initState() {
    super.initState();
    getPref();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const globals.AppBarItems('Question History', '/',1),
        body: SizedBox.expand(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            children: <Widget>[
              // Questions
              !isLoaded
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : errMessage.isNotEmpty
                      ? Center(
                          child: Text(errMessage),
                        )
                      : faqApiData.questions.isEmpty
                          ? const Center(child: Text('No Data'))
                          : ListView.builder(
                              itemCount: faqApiData.questions.length,
                              itemBuilder: (context, index) =>
                                  getQuesRow(index)),
              // Questions
              !isLoaded
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : errMessage.isNotEmpty
                      ? Center(
                          child: Text(errMessage),
                        )
                      : faqApiData.faqs.isEmpty
                          ? const Center(child: Text('No Data'))
                          : ListView.builder(
                              itemCount: faqApiData.faqs.length,
                              itemBuilder: (context, index) =>
                                  getFaqsRow(index)),
              Container(
                color: const Color.fromARGB(255, 16, 223, 23),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavyBar(
          selectedIndex: _currentIndex,
          showElevation: true,
          itemCornerRadius: 24,
          curve: Curves.easeIn,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          backgroundColor: const Color.fromRGBO(14, 29, 48, 1),
          onItemSelected: (index) {
            setState(() => _currentIndex = index);
            _pageController?.jumpToPage(index);
          },
          items: <BottomNavyBarItem>[
            BottomNavyBarItem(
              title: const Text('Questions'),
              icon: const Icon(Icons.question_answer_outlined),
              activeColor: Colors.white,
              textAlign: TextAlign.center,
            ),
            BottomNavyBarItem(
              title: const Text('FAQs'),
              icon: const Icon(Icons.help_outline_rounded),
              activeColor: Colors.white,
              textAlign: TextAlign.center,
            ),
          ],
        ));
  }

  Widget getQuesRow(int index) {
    return Container(
        margin: const EdgeInsets.only(top: 20),
        child: ExpansionTile(
          expandedAlignment: Alignment.centerLeft,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Row(
            children: [
              const Icon(Icons.help_outline_rounded),
              Expanded(
                child: Text(
                ' ${faqApiData.questions[index].question} ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),


              // faqApiData.questions[index].answer == 'Waiting For Answer'
              //     ? const Text('Pending',
              //         style: TextStyle(
              //             color: Colors.red, fontWeight: FontWeight.bold))
              //     : const Text('')
            ],
          ),
          children: <Widget>[
            Container(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 10, left: 45, right: 10),
                child: Text(faqApiData.questions[index].answer)),
          ],
        ));
  }

  Widget getFaqsRow(int index) {
    return Container(
        margin: const EdgeInsets.only(top: 20),
        child: ExpansionTile(
          title: Row(
            children: [
              const Icon(
                Icons.help_outline_rounded,
                color: Color.fromRGBO(13, 66, 255, 1),
              ),
              Text(' ${faqApiData.faqs[index].question}',
                  style: const TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
          children: <Widget>[
            Container(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 10, left: 45, right: 10),
                child: Text(faqApiData.faqs[index].answer)),
          ],
        ));
  }
}

FaqApiData faqApiDataFromJson(String str) =>
    FaqApiData.fromJson(json.decode(str));

String faqApiDataToJson(FaqApiData data) => json.encode(data.toJson());

class FaqApiData {
  String message;
  List<Faq> faqs;
  List<Question> questions;

  FaqApiData({
    required this.message,
    required this.faqs,
    required this.questions,
  });

  factory FaqApiData.fromJson(Map<String, dynamic> json) => FaqApiData(
        message: json["message"],
        faqs: List<Faq>.from(json["faqs"].map((x) => Faq.fromJson(x))),
        questions: List<Question>.from(
            json["questions"].map((x) => Question.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "faqs": List<dynamic>.from(faqs.map((x) => x.toJson())),
        "questions": List<dynamic>.from(questions.map((x) => x.toJson())),
      };
}

class Faq {
  int id;
  String question;
  String answer;

  Faq({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory Faq.fromJson(Map<String, dynamic> json) => Faq(
        id: json["id"],
        question: json["question"] ?? '',
        answer: json["answer"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "question": question,
        "answer": answer,
      };
}

class Question {
  int id;
  int customerId;
  String question;
  dynamic answer;
  dynamic answerBy;
  String? answeredAt;

  Question({
    required this.id,
    required this.customerId,
    required this.question,
    this.answer,
    this.answerBy,
    this.answeredAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json["id"],
        customerId: json["customer_id"],
        question: json["question"],
        answer: json["answer"] ?? 'Waiting For Answer',
        answerBy: json["answer_by"] ?? '',
        answeredAt: json["answered_at"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "customer_id": customerId,
        "question": question,
        "answer": answer,
        "answer_by": answerBy,
        "answered_at": answeredAt,
      };
}
