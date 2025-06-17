import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../resources/utils/helpers/helper_mixin.dart';



class MessageUserScreen extends ConsumerStatefulWidget {
  const MessageUserScreen({super.key});

  @override
  ConsumerState createState() => _MessageUserScreenState();
}

class _MessageUserScreenState extends ConsumerState<MessageUserScreen>
    with HelperMixin {

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Liên lạc'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white, // màu của nút quay lại
        ),
      ),
      body: Center(
        child: Text("Liên lạc ph"),
      ),
    );
  }
}
