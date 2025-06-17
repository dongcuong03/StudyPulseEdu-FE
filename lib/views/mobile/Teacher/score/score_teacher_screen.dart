import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../resources/utils/helpers/helper_mixin.dart';


class ScoreTeacherScreen extends ConsumerStatefulWidget {
  const ScoreTeacherScreen({super.key});

  @override
  ConsumerState createState() => _ScoreTeacherScreenState();
}

class _ScoreTeacherScreenState extends ConsumerState<ScoreTeacherScreen>
    with HelperMixin {

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Điểm'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Center(
        child: Text("Điểm số gv"),
      ),
    );
  }
}
