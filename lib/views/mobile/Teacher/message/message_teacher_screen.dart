import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../resources/utils/helpers/helper_mixin.dart';


class MessageTeacherScreen extends ConsumerStatefulWidget {
  const MessageTeacherScreen({super.key});

  @override
  ConsumerState createState() => _MessageTeacherScreenState();
}

class _MessageTeacherScreenState extends ConsumerState<MessageTeacherScreen>
    with HelperMixin {

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Liên lạc'),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white, // màu của nút quay lại
        ),
      ),
      body: Center(
        child: Text("Liên lạc gv"),
      ),
    );
  }
}
