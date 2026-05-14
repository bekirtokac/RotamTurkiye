import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

enum InputType {
  TextField,
  Dropdown,
  DatePicker,
}

class CustomInput extends StatefulWidget {
  final String? leftIconName;
  final String? rightIconName;
  final String hintText;
  final bool isPassword;
  final bool? isNumber;
  final TextEditingController? controller;
  final InputType inputType;
  final ValueChanged<String>? onChanged;
  final String? defaultValue; // Yeni parametre

  CustomInput({
    required this.hintText,
    required this.isPassword,
    this.isNumber,
    this.leftIconName,
    this.rightIconName,
    this.controller,
    required this.inputType,
    this.onChanged,
    this.defaultValue, // Parametreyi ekleyin
  });

  @override
  _CustomInputState createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  late TextEditingController _textController;
  String? _selectedCity;
  final double _iconHeight = 25.0;

  @override
  void initState() {
    super.initState();
    _textController = widget.controller ?? TextEditingController();
    _selectedCity = widget.defaultValue; // Başlangıç değerini atayın
    // TextField için varsayılan değeri ata
    if (widget.inputType == InputType.TextField &&
        widget.defaultValue != null) {
      _textController.text = widget.defaultValue!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Color(0xFF383838),
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            if (widget.leftIconName != null)
              Image.asset(
                height: _iconHeight,
                widget.leftIconName!,
                color: Colors.white,
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildInputWidget(),
              ),
            ),
            if (widget.rightIconName != null)
              Image.asset(
                height: _iconHeight,
                widget.rightIconName!,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputWidget() {
    switch (widget.inputType) {
      case InputType.TextField:
        return TextField(
          obscureText: widget.isPassword,
          controller: _textController,
          style: TextStyle(color: Colors.white),
          keyboardType: widget.isNumber == true
              ? TextInputType.number
              : TextInputType.text,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Color(0xFFc1c1c1)),
            border: InputBorder.none,
          ),
        );
      case InputType.Dropdown:
        return CustomDropdown<String>.search(
          searchHintText: "Bul",
          closedHeaderPadding: EdgeInsets.all(0),
          items: _buildDropdownItems(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCity = newValue;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(_selectedCity!);
            }
          },
          hintText: widget.hintText,
          initialItem: selectedCity,
          decoration: CustomDropdownDecoration(
              listItemStyle: TextStyle(color: Colors.white),
              headerStyle: TextStyle(color: Colors.white),
              closedSuffixIcon: SizedBox(
                width: 0,
              ),
              closedFillColor: Colors.transparent,
              expandedFillColor: Colors.black),
        );
      case InputType.DatePicker:
        return GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child: TextField(
              controller: _textController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(color: Color(0xFFc1c1c1)),
                border: InputBorder.none,
              ),
            ),
          ),
        );
    }
  }

  List<String> _buildDropdownItems() {
    return [
      'Adana',
      'Adıyaman',
      'Afyonkarahisar',
      'Ağrı',
      'Amasya',
      'Ankara',
      'Antalya',
      'Artvin',
      'Aydın',
      'Balıkesir',
      'Bilecik',
      'Bingöl',
      'Bitlis',
      'Bolu',
      'Burdur',
      'Bursa',
      'Çanakkale',
      'Çankırı',
      'Çorum',
      'Denizli',
      'Diyarbakır',
      'Edirne',
      'Elazığ',
      'Erzincan',
      'Erzurum',
      'Eskişehir',
      'Gaziantep',
      'Giresun',
      'Gümüşhane',
      'Hakkari',
      'Hatay',
      'Isparta',
      'Mersin',
      'İstanbul',
      'İzmir',
      'Kars',
      'Kastamonu',
      'Kayseri',
      'Kırklareli',
      'Kırşehir',
      'Kocaeli',
      'Konya',
      'Kütahya',
      'Malatya',
      'Manisa',
      'Kahramanmaraş',
      'Mardin',
      'Muğla',
      'Muş',
      'Nevşehir',
      'Niğde',
      'Ordu',
      'Rize',
      'Sakarya',
      'Samsun',
      'Siirt',
      'Sinop',
      'Sivas',
      'Tekirdağ',
      'Tokat',
      'Trabzon',
      'Tunceli',
      'Şanlıurfa',
      'Uşak',
      'Van',
      'Yozgat',
      'Zonguldak',
      'Aksaray',
      'Bayburt',
      'Karaman',
      'Kırıkkale',
      'Batman',
      'Şırnak',
      'Bartın',
      'Ardahan',
      'Iğdır',
      'Yalova',
      'Karabük',
      'Kilis',
      'Osmaniye',
      'Düzce'
    ];
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _textController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  String? get selectedCity => _selectedCity;
}
