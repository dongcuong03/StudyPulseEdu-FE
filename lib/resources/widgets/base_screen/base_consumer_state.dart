import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/helpers/helper_mixin.dart';


abstract class BaseConsumerState<T extends ConsumerStatefulWidget>
    extends ConsumerState<T> with HelperMixin {
  AppLifecycleState? appLifecycleState;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    disposeAll();
    super.dispose();
  }

  void disposeAll() {
    dismissLoading(context, null);
  }

}
