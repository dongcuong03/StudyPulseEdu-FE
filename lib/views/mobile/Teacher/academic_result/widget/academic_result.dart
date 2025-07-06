import 'package:flutter/material.dart';

class AcademicResultTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final void Function(int index, String newNote)? onNoteChanged;
  const AcademicResultTable({super.key, required this.data, required this.onNoteChanged});

  @override
  State<AcademicResultTable> createState() => _AcademicResultTableState();
}

class _AcademicResultTableState extends State<AcademicResultTable> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey[300]),
            dataRowMinHeight: 100,
            dataRowMaxHeight: 100,
            columns: const [
              DataColumn(label: Text("STT", style: TextStyle(fontSize: 16,color:Colors.black87, fontWeight: FontWeight.w500),)),
              DataColumn(label: Text("Mã HS", style: TextStyle(fontSize: 16,color:Colors.black87, fontWeight: FontWeight.w500),)),
              DataColumn(label: Text("Tên học sinh", style: TextStyle(fontSize: 16,color:Colors.black87, fontWeight: FontWeight.w500),)),
              DataColumn(label: Text("Điểm KT", style: TextStyle(fontSize: 16,color:Colors.black87, fontWeight: FontWeight.w500),)),
              DataColumn(label: Text("Điểm BT", style: TextStyle(fontSize: 16,color:Colors.black87, fontWeight: FontWeight.w500),)),
              DataColumn(label: Text("Chuyên cần", style: TextStyle(fontSize: 16,color:Colors.black87, fontWeight: FontWeight.w500),)),
              DataColumn(label: Text("Tổng kết", style: TextStyle(fontSize: 16,color:Colors.black87, fontWeight: FontWeight.w500),)),
              DataColumn(label: Text("Đánh giá", style: TextStyle(fontSize: 16,color:Colors.black87, fontWeight: FontWeight.w500),)),
              DataColumn(label: Text("Nhận xét", style: TextStyle(fontSize: 16,color:Colors.black87, fontWeight: FontWeight.w500),)),
            ],
            rows: List.generate(widget.data.length, (index) {
              final item = widget.data[index];
              return DataRow(
                color: MaterialStateProperty.all(Colors.white),
                cells: [
                  DataCell(Center(child: Text('${index + 1}'))),
                  DataCell(Center(child: Text(item['id']))),
                  DataCell(Text(item['name'])),
                  DataCell(Center(child: Text('${item['diemKT']}'))),
                  DataCell(Center(child: Text('${item['diemBT']}'))),
                  DataCell(Center(child: Text('${item['chuyenCan']}'))),
                  DataCell(Center(child: Text('${item['tongKet']}'))),
                  DataCell(Center(child: Text(item['danhGia']))),
                  DataCell(
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: SizedBox(
                        width: 270,
                        child: TextFormField(
                          initialValue: item['nhanXet'],
                          maxLines: 2,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Nhập nhận xét',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() => item['nhanXet'] = value);
                            widget.onNoteChanged?.call(item['index'], value);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
