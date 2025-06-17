class PagingResponse<T> {
  final List<T>? content;
  final int? pageNumber;
  final int? pageSize;
  final int? totalElements;
  final int? totalPages;
  final bool? last;
  final bool? first;
  final int? numberOfElements;

  PagingResponse({
     this.content,
     this.pageNumber,
     this.pageSize,
     this.totalElements,
     this.totalPages,
     this.last,
     this.first,
     this.numberOfElements,
  });

  factory PagingResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic) fromJsonT,
      ) {
    final contentJson = json['content'] as List<dynamic>?;

    return PagingResponse<T>(
      content: contentJson?.map((e) => fromJsonT(e)).toList(),
      pageNumber: json['number'] as int?,
      pageSize: json['size'] as int?,
      totalElements: json['totalElements'] as int?,
      totalPages: json['totalPages'] as int?,
      last: json['last'] as bool?,
      first: json['first'] as bool?,
      numberOfElements: json['numberOfElements'] as int?,
    );
  }
}
