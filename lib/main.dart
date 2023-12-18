import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyAppHome(),
    );
  }
}

class MyAppHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppHomeState();
  }
}

class _MyAppHomeState extends State<MyAppHome> {
  String userName = "";
  int typedCharsLenght = 0;
  String lorem =
      "                                           Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
          .toLowerCase()
          .replaceAll(',', '')
          .replaceAll('.', '');

  int step = 0;
  int score = 0;
  int lastTypeAt = 0;
  String currentWord = '';

  void updateLastTypeAt() {
    lastTypeAt = DateTime.now().millisecondsSinceEpoch;
  }

  void onType(String value) {
    updateLastTypeAt();
    String trimmedValue = lorem.trimLeft(); //boşlukları siliyoruz
    print(trimmedValue.indexOf(value));
    setState(() {
      if (trimmedValue.indexOf(value) != 0) {
        step = 2;
      } else {
        typedCharsLenght = value.length;
      }
    });
  }

  void onUserNameType(String value) {
    setState(() {
      if (value.length >= 3) {
        this.userName = value.substring(0, 3);
      } else {
        // Dizinin uzunluğu 3'ten küçükse başağağıdaki gibi bir işlem yapabilirsiniz
        // Örneğin, bir varsayılan değeri ayarlayabilir veya bir hata mesajı gösterebilirsiniz.
        this.userName = value; // Tercih ettiğiniz bir işlemle değiştirin.
      }
    });
  }

  void resetGame() {
    setState(() {
      typedCharsLenght = 0;
      step = 1;
    });
  }

  void onStartClick() {
    setState(() {
      updateLastTypeAt();
      step++;
    });

    Timer.periodic(Duration(seconds: 1), (timer) {
      int now = DateTime.now().millisecondsSinceEpoch;

      //Game Over
      setState(() async {
        if (step == 1 && now - lastTypeAt > 5000) {
          step++;
        }
        if (step != 1) {
          var uri = Uri.parse("http://localhost:3000/users/score");
          var response = await http.post(uri, body: {
            'userName': userName,
            'score': typedCharsLenght.toString()
          });
          print('Response status: ${response.body.toString()}');

          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fast Fingere")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (step == 0) ...[
              Text(
                "Oyuna Hoş Geldiniz",
                style: TextStyle(fontSize: 24),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: TextField(
                  autocorrect: false,
                  autofocus: true,
                  onChanged: onUserNameType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "İsminizi Giriniz",
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: userName.length == 0 ? null : onStartClick,
                  child: Icon(Icons.play_circle))
            ] else if (step == 1) ...[
              Text('$typedCharsLenght'),
              showWidget(),
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 32),
                child: TextField(
                  autocorrect: false,
                  autofocus: false,
                  onChanged: onType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Yaz Bakalım",
                  ),
                ),
              )
            ] else ...[
              Text(
                "Coronodan kaçamadın Scorun $typedCharsLenght ",
                style: TextStyle(fontSize: 18),
              ),
              ElevatedButton(
                  onPressed: resetGame,
                  child: Container(
                    child: Text(
                      "Yeniden Dene",
                    ),
                  )),
            ]
          ],
        ),
      ),
    );
  }

  Container showWidget() {
    return Container(
      height: 40,
      child: Marquee(
        text: lorem,
        style: TextStyle(fontSize: 24, letterSpacing: 2),
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        blankSpace: 20.0,
        velocity: 125,
        startPadding: 0,
        accelerationDuration: Duration(seconds: 2),
        accelerationCurve: Curves.ease,
        decelerationDuration: Duration(milliseconds: 500),
        decelerationCurve: Curves.easeOut,
      ),
    );
  }
}
