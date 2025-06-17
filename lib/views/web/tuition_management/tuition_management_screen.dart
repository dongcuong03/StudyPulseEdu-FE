import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../resources/utils/helpers/helper_mixin.dart';
class TuitionManagementScreen extends ConsumerStatefulWidget {
  const TuitionManagementScreen({super.key});

  @override
  ConsumerState createState() => _TuitionManagementScreenState();
}

class _TuitionManagementScreenState extends ConsumerState<TuitionManagementScreen>
    with HelperMixin {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          child: Text('tuition'),
        ),
      ),
    );
  }


}
