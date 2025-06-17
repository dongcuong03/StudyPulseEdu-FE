import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../resources/utils/helpers/helper_mixin.dart';
class StatisticalReportScreen extends ConsumerStatefulWidget {
  const StatisticalReportScreen({super.key});

  @override
  ConsumerState createState() => _StatisticalReportScreenState();
}

class _StatisticalReportScreenState extends ConsumerState<StatisticalReportScreen>
    with HelperMixin {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          child: Text('Statistical report'),
        ),
      ),
    );
  }


}
