

import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:study_pulse_edu/models/app/TuitionFee.dart';

import '../../models/app/PagingResponse.dart';
import '../../resources/constains/constants.dart';
import '../../resources/utils/data_sources/dio_client.dart';
import 'dart:html' as html;
part 'tuition_fee_view_model.g.dart';
@riverpod
class TuitionFeeViewModel  extends _$TuitionFeeViewModel {
  static const int defaultPageSize = 10;

  int _currentPageIndex = 1;

  @override
  FutureOr<PagingResponse<TuitionFee>?> build() async {
    return await _fetchTuitionFees(
        pageIndex: _currentPageIndex, pageSize: defaultPageSize);
  }

  Future<void> fetchTuitionFees({
    int? pageIndex,
    int pageSize = defaultPageSize,
    String? studentCode,
    TuitionStatus? status,
  }) async {
    state = const AsyncLoading();

    if (pageIndex != null) {
      _currentPageIndex = pageIndex;
    }


    try {
      final pagingResponse = await _fetchTuitionFees(
          pageIndex: pageIndex,
          pageSize: pageSize,
          studentCode: studentCode,
          status: status,

      );
      state = AsyncData(pagingResponse);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // Call API paging
  Future<PagingResponse<TuitionFee>?> _fetchTuitionFees({
    int? pageIndex,
    int pageSize = defaultPageSize,
    String? studentCode,
    TuitionStatus? status
  }) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/tuitionFee/paging";

    final data = <String, dynamic>{
      'pageSize': pageSize,
    };

    if (pageIndex != null) {
      data['pageIndex'] = pageIndex;
    }

    if (studentCode != null && studentCode.isNotEmpty) {
      data['studentCode'] = studentCode;
    }
    if (status != null) {
      data['status'] = status;
    }

    final response = await DioClient().post(url, data: data);
    if (response.data == null) return null;
    return PagingResponse<TuitionFee>.fromJson(
      response.data,
          (json) => TuitionFee.fromJson(json),
    );
  }

  Future<List<TuitionFee>> fetchAllTuitionFees({
    String? studentCode,
    TuitionStatus? status,
  }) async {
    try {
      final url = "${ApiConstants.getBaseUrl}/api/v1/tuitionFee/getAll";

      final data = <String, dynamic>{};
      if (studentCode != null && studentCode.isNotEmpty) {
        data['studentCode'] = studentCode;
      }
      if (status != null) {
        data['status'] = status.name;
      }

      final response = await DioClient().post(url, data: data);

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => TuitionFee.fromJson(e))
            .toList();
      } else {
        throw Exception("Dữ liệu không hợp lệ");
      }
    } catch (e) {
      print('Lỗi fetchAllTuitionFees: $e');
      rethrow;
    }
  }

  Future<String?> notifyAllTuitionFees() async {
    try {
      // Lấy toàn bộ danh sách học phí
      final allTuitionFees = await fetchAllTuitionFees(status: TuitionStatus.UNPAID);
      final dueDate = DateTime.now().add(const Duration(days: 14));

      // Chuẩn bị danh sách DTO để gửi lên backend
      final requestData = allTuitionFees.map((fee) {
        return {
          "studentId": fee.student?.id,
          "totalTuitionFee": fee.totalTuitionFee,
          "dueDate": dueDate.toIso8601String(),
        };
      }).toList();

      // Gọi API gửi thông báo
      final response = await DioClient().postFile(
        "${ApiConstants.getBaseUrl}/api/v1/tuitionFee/notifyTuitionFees",
        data: requestData,
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        return "Gửi thông báo thất bại: ${response.statusMessage}";
      }
    } catch (e) {
      print("Lỗi khi gửi thông báo học phí: $e");
      return "Đã xảy ra lỗi: $e";
    }
  }

  Future<List<TuitionFee>> getTuitionFeeByStudentId(String studentId) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/tuitionFee/getByStudentId/$studentId";
    final response = await DioClient().get(url);
    if (response.statusCode == 200 && response.data is List) {
      return (response.data as List).map((e) => TuitionFee.fromJson(e)).toList();
    } else {
      throw Exception("Lỗi khi lấy học phí theo học sinh.");
    }
  }

  Future<void> exportTuitionFeeTemplate() async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/tuitionFee/exportTuitionFeeTemplate";

    try {
      final response = await DioClient().getBytes(
        url,
        queryParameters: {},
      );


      if (response.statusCode == 200) {
        String fileName = 'tuition_fee_template.xlsx';

        // Lấy tên file từ header nếu có
        final contentDisposition = response.headers['content-disposition']?.first;
        if (contentDisposition != null) {
          final regex = RegExp(r'filename="?([^"]+)"?');
          final match = regex.firstMatch(contentDisposition);
          if (match != null) {
            fileName = match.group(1)!;
          }
        }

        final blob = html.Blob([response.data]);
        final downloadUrl = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: downloadUrl)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(downloadUrl);

      } else {
        print("Lỗi khi tải file: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi exportTuitionFeeTemplate: $e");
    }
  }

  Future<String?> importTuitionFeeExcel(Uint8List fileBytes, String fileName) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/tuitionFee/importTuitionFeeExcel";

    try {
      final formData = FormData.fromMap({
        "uploadfile": MultipartFile.fromBytes(
          fileBytes.toList(),
          filename: fileName,
        ),
      });

      final response = await DioClient().postFile(
        url,
        data: formData,
        isMultipart: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Gửi file thành công");
        return null;
      } else {
        return "Lỗi server: ${response.statusCode} - ${response.statusMessage}";
      }
    } catch (e) {
      print("Lỗi gửi file: $e");
      return "Lỗi gửi file: $e";
    }
  }
}