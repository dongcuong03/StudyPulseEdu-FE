import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../resources/utils/helpers/helper_mixin.dart';


class AcademicResultTeacherScreen extends ConsumerStatefulWidget {
  const AcademicResultTeacherScreen({super.key});

  @override
  ConsumerState createState() => _AcademicResultTeacherScreenState();
}

class _AcademicResultTeacherScreenState extends ConsumerState<AcademicResultTeacherScreen>
    with HelperMixin {

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả học tập'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Center(
        child: Text("kết quả học tập gv"),
        ),
    );
  }
}
