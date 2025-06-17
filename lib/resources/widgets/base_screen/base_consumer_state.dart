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

  // void showLoading(bool show) {
  //   loadingView ??= LoadingView();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (show) {
  //       loadingView!.show(context);
  //     } else {
  //       loadingView!.hide();
  //     }
  //   });
  // }

  // Future<bool> getData() async {
  //   await Future<dynamic>.delayed(const Duration(milliseconds: 0));
  //   return true;
  // }

  // Widget loadingCenter() {
  //   return Container(
  //     width: MediaQuery.of(context).size.width,
  //     height: MediaQuery.of(context).size.height,
  //     color: Colors.white.withOpacity(0.5),
  //     child: const Center(
  //       child: CircularProgressIndicator(
  //         color: AppTheme.primaryColor,
  //       ),
  //     ),
  //   );
  // }

  // void dismissLoading(String? isback) {
  //   if (loadingView != null) {
  //     loadingView!.hide();
  //   }
  //   if (isback != null) {
  //     backToScreen();
  //   }
  // }
  //
  // backToScreen() {
  //   Navigator.of(context).pop();
  // }
  //
  // Future<void> modalBottomSheetMenu(
  //     {required Widget child, bool isDrag = true}) {
  //   return showModalBottomSheet(
  //       context: context,
  //       enableDrag: isDrag,
  //       isScrollControlled: true,
  //       shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.only(
  //               topLeft: Radius.circular(10.0),
  //               topRight: Radius.circular(10.0))),
  //       builder: (builder) {
  //         return child;
  //       });
  // }
}
