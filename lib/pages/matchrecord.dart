import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MatchRecordPage extends StatelessWidget {
  const MatchRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example data for the match records
    final List<Map<String, String>> matchRecords = [
      {'name': 'Dog 1', 'breed': '푸들', 'careType': '산책', 'status': '매칭 완료'},
      {'name': 'Dog 2', 'breed': '말티즈', 'careType': '돌봄', 'status': '결제 완료'},
      {'name': 'Dog 3', 'breed': '시츄', 'careType': '외견 케어', 'status': '요구 완료'},
      {'name': 'Dog 4', 'breed': '리트리버', 'careType': '놀아주기', 'status': '매칭 취소'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('매칭 기록'),
      ),
      body: ListView.builder(
        itemCount: matchRecords.length,
        itemBuilder: (context, index) {
          final matchRecord = matchRecords[index];
          return ListTile(
            onTap: () {
              // Navigate to match record detail page
              context.go("/home/match/matchrecord/matchrecordDetail");
            },
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/images/empty_image.png'),
            ),
            title: Text(' ${matchRecord['name']}'),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('견종: ${matchRecord['breed']}'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${matchRecord['careType']}'),
                    Text('${matchRecord['status']}'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class matchrecordDetailPage extends StatelessWidget {
  const matchrecordDetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('매칭 기록 상세 정보'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
                'assets/images/map.png', height: 215),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/dog.png',
                  width: 170,
                  height: 200,
                ),
                SizedBox(width: 50),
                Column(
                  children:[
                    Text('케어 타입/ 시간'),
                    SizedBox(height: 30),
                    Text('세부사항'),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                      },
                      child: Text('채팅'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 50, width: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.go("/home/match/matchrecord/matchrecordDetail/review");
                  },
                  child: Text('리뷰'),
                  // 처음 결제, 취소 버튼 이 였다가 결제 완료후 완료, 취소 버튼이 되고
                  // 요구 완료 후 리뷰 작성을 위한 버튼으로 비뀌고 취소 버튼 사라집니다.
                  // 리뷰 페이지를 나타 내는게 나을것 같아서 리뷰 버튼 으로 해서 보내드립니다.
                  // 리뷰 버튼은 리뷰를 처음 작성 하는 거면 작성페이지로 가고
                  // 작성한 기록이 있으면 작성한 리뷰가 나오고 삭제 버튼이 활성화 됩니다.
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  double _rating = 3.0;
  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('리뷰 페이지'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '점수:',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 20.0),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 20.0),
            Text(
              '평점: $_rating',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  labelText: '리뷰를 작성하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
              },
              child: Text('제출'), // 리뷰 제출후 제출 버튼이 삭제 버튼으로 .
            ),
          ],
        ),
      ),
    );
  }
}