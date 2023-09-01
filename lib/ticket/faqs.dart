import 'package:flutter/material.dart';
import 'dart:convert';
import '../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
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
      await http.post(Uri.https(globals.baseURL, "/api/question-history"), headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $apiToken'
        }, body: jsonEncode({})
      );
    var resCode = response.statusCode;
    if (resCode == 200) {
       setState(() {
        isLoaded = true;
      });
      FaqApiData faqApiData =
          faqApiDataFromJson(response.body);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const globals.AppBarItems('Ask Question'),
      body: !isLoaded
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
                      itemBuilder: (context, index) => getFaqsRow(index)),
                  // : ListView.builder(
                  //     itemCount: faqApiData.questions.length,
                  //     itemBuilder: (context, index) => getQuesRow(index)),
                      
    );
  }

  Widget getQuesRow(int index) {
    return Container(
        margin: const EdgeInsets.only(top: 20),
        child: ExpansionTile(
          title: Row(
            children: [
              const Icon(Icons.help_outline_rounded),
              Text(faqApiData.questions[index].question)
            ],
          ),
          children: <Widget>[
            Text(faqApiData.questions[index].answer)
          ],
        )
      );
  }

  Widget getFaqsRow(int index) {
    return Container(
        margin: const EdgeInsets.only(top: 20),
        child: ExpansionTile(
          title: Row(
            children: [
              const Icon(Icons.help_outline_rounded),
              Text(faqApiData.faqs[index].question)
            ],
          ),
          children: <Widget>[
            Text(faqApiData.faqs[index].answer)
          ],
        )
      );
  }
}



FaqApiData faqApiDataFromJson(String str) => FaqApiData.fromJson(json.decode(str));

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
        questions: List<Question>.from(json["questions"].map((x) => Question.fromJson(x))),
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
        question: json["question"]??'',
        answer: json["answer"]??'',
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
        answer: json["answer"]??'Waiting For Answer',
        answerBy: json["answer_by"]??'',
        answeredAt: json["answered_at"]??'',
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
