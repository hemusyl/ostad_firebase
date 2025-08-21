import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const LiveScoreApp());
}

class LiveScoreApp extends StatelessWidget {
  const LiveScoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<LiveScore> _listOfScore = [];
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> _getLiveScoreData() async {
    _listOfScore.clear();
    final QuerySnapshot<Map<String, dynamic>> snapshots = await db
        .collection('football')
        .get();
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshots.docs) {
      LiveScore liveScore = LiveScore(
        id: doc.id,
        team1Name: doc.get('team1_name'),
        team2Name: doc.get('team2_name'),
        team1Score: doc.get('team1_score'),
        team2Score: doc.get('team2_score'),
        isRunning: doc.get('is_running'),
        winnerTeam: doc.get('winner_team'),
      );
      _listOfScore.add(liveScore);
    }
    setState(() {});
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _getLiveScoreData();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: StreamBuilder(
          stream: db.collection('football').snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshots) {

            if (snapshots.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshots.hasError) {
              return Center(child: Text(snapshots.error.toString()));
            }

            if (snapshots.hasData) {
              _listOfScore.clear();
              for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshots.data!.docs) {
                LiveScore liveScore = LiveScore(
                  id: doc.id,
                  team1Name: doc.get('team1_name'),
                  team2Name: doc.get('team2_name'),
                  team1Score: doc.get('team1_score'),
                  team2Score: doc.get('team2_score'),
                  isRunning: doc.get('is_running'),
                  winnerTeam: doc.get('winner_team'),
                );
                _listOfScore.add(liveScore);
              }
            }

            return ListView.builder(
              itemCount: _listOfScore.length,
              itemBuilder: (context, index) {
                LiveScore liveScore = _listOfScore[index];

                return ListTile(

                  onLongPress: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Confirm Delete"),
                          content: Text("Are you sure you want to delete this item?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false), // No
                              child: Text("No"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true), // Yes
                              child: Text("Yes"),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm == true) {
                      db.collection('football').doc(liveScore.id).delete();
                    }
                  },

                  leading: CircleAvatar(
                    radius: 8,
                    backgroundColor: liveScore.isRunning ? Colors.green : Colors.grey,
                  ),
                  title: Text(liveScore.id),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(liveScore.team1Name),
                          Text('  vs  '),
                          Text(liveScore.team2Name),
                        ],
                      ),
                      Text('Is Running: ${liveScore.isRunning}'),
                      Text('Winner Team: ${liveScore.winnerTeam}'),
                    ],
                  ),
                  trailing: Text(
                    '${liveScore.team1Score} : ${liveScore.team2Score}',
                    style: TextStyle(fontSize: 24),
                  ),
                );
              },
            );
          }
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async {

        LiveScore liveScore = LiveScore(
          id: 'spnvssau',
          team1Name: 'Spain',
          team2Name: 'Saudi',
          team1Score: 3,
          team2Score:2,
          isRunning: true,
          winnerTeam: '',
        );

        await db.collection('football')
        .doc(liveScore.id)
            .set(liveScore.toMap());
      }, child: Icon(Icons.add),),
    );
    
  }
}

class LiveScore {
  final String id;
  final String team1Name;
  final String team2Name;
  final int team1Score;
  final int team2Score;
  final bool isRunning;
  final String winnerTeam;

  LiveScore({
    required this.id,
    required this.team1Name,
    required this.team2Name,
    required this.team1Score,
    required this.team2Score,
    required this.isRunning,
    required this.winnerTeam,
  });

  Map<String, dynamic> toMap(){
    return {
      'team1_name': team1Name,
      'team2_name': team2Name,
      'team1_score': team1Score,
      'team2_score': team2Score,
      'is_running': isRunning,
      'winner_team': winnerTeam,
    };
  }
}