import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class AssignmentFilterWidget extends StatefulWidget {
  final List<String?> classNames;
  final String? initialSelectedClass;
  final DateTime? initialFromDate;
  final DateTime? initialToDate;

  final void Function({
    String? selectedClass,
    DateTime? fromDate,
    DateTime? toDate,
  }) onApply;

  final VoidCallback? onReset;

  const AssignmentFilterWidget(
      {super.key,
      required this.classNames,
      required this.initialSelectedClass,
      required this.initialFromDate,
      required this.initialToDate,
      required this.onApply,
      required this.onReset});

  @override
  State<AssignmentFilterWidget> createState() =>
      _AssignmentFilterWidgetState();
}

class _AssignmentFilterWidgetState
    extends State<AssignmentFilterWidget> {
  String? selectedClass;
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    selectedClass = widget.initialSelectedClass;
    fromDate = widget.initialFromDate;
    toDate = widget.initialToDate;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(

      padding: const EdgeInsets.all(20),
      height: size.height * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15.0, bottom: 15),
            child: Center(
              child: const Text(
                "Bộ lọc tìm kiếm",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text("Theo lớp", style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              hint: const Text("Chọn lớp", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400)),
              items: widget.classNames.map((className) {
                return DropdownMenuItem<String>(
                  value: className,
                  child: Text(
                    className ?? '',
                    style: const TextStyle(fontWeight: FontWeight.normal,),
                  ),
                );
              }).toList(),
              value: selectedClass,
              onChanged: (value) {
                setState(() {
                  selectedClass = value;
                });
              },
              buttonStyleData: ButtonStyleData(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                  color: Colors.white,
                ),
              ),
              iconStyleData: const IconStyleData(
                icon: Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                iconSize: 24,
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100
                ),
                offset: const Offset(0, 10),
                scrollbarTheme: ScrollbarThemeData(
                  thumbColor: MaterialStateProperty.all(Colors.grey),
                  radius: const Radius.circular(8),
                ),
              ),
              menuItemStyleData: const MenuItemStyleData(
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),

          const SizedBox(height: 25),
          Text("Theo ngày giao bài tập", style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _pickDate(isFrom: true),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:  BorderSide(color: Colors.grey.shade400),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:  BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:  BorderSide(color: Colors.grey.shade400),
                      ),
                      suffixIcon: const Icon(Icons.calendar_month_outlined, color: Colors.blueAccent, size: 20,),
                    ),
                    child: Center(
                      child: Text(
                        fromDate != null
                            ? "${fromDate!.day}/${fromDate!.month}/${fromDate!.year}"
                            : "Chọn ngày",
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.arrow_right, size: 30),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _pickDate(isFrom: false),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:  BorderSide(color: Colors.grey.shade400),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:  BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:  BorderSide(color: Colors.grey.shade400),
                      ),
                      suffixIcon: const Icon(Icons.calendar_month_outlined, color: Colors.blueAccent, size: 20,),
                    ),
                    child: Center(
                      child: Text(
                        toDate != null
                            ? "${toDate!.day}/${toDate!.month}/${toDate!.year}"
                            : "Chọn ngày",
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),


          const Spacer(),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white70,
                    foregroundColor: Colors.black87,

                  ),
                  onPressed: () {
                    setState(() {
                      selectedClass = null;
                      fromDate = null;
                      toDate = null;
                    });
                  },
                  child: const Text("Đặt lại"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,

                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onApply(
                      selectedClass: selectedClass,
                      fromDate: fromDate,
                      toDate: toDate,
                    );
                  },
                  child: const Text("Áp dụng"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white,
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }
}
