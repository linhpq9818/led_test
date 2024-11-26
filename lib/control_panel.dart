import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:ledbanner_test/banner_provider.dart';
import 'package:provider/provider.dart';

class ControlsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bannerProvider = Provider.of<BannerProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Thay đổi font chữ
          DropdownButton<String>(
            value: bannerProvider.fontFamily,
            onChanged: (value) {
              if (value != null) bannerProvider.updateFontFamily(value);
            },
            items: ['Roboto', 'Lobster', 'Arial'].map((font) {
              return DropdownMenuItem(
                value: font,
                child: Text(font),
              );
            }).toList(),
          ),
          // Thay đổi kích thước chữ
          Slider(
            value: bannerProvider.fontSize,
            min: 16,
            max: 100,
            onChanged: (value) => bannerProvider.updateFontSize(value),
          ),
          // Chọn màu
          ElevatedButton(
            onPressed: () async {
              Color? selectedColor = await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: SingleChildScrollView(
                      child: BlockPicker(
                        pickerColor: bannerProvider.textColor,
                        onColorChanged: (color) =>
                            bannerProvider.updateColor(color),
                      ),
                    ),
                  );
                },
              );
              if (selectedColor != null) {
                bannerProvider.updateColor(selectedColor);
              }
            },
            child: const Text('Chọn màu'),
          ),
          // Tốc độ chạy
          Slider(
            value: bannerProvider.speed,
            min: 10,
            max: 200,
            onChanged: (value) => bannerProvider.updateSpeed(value),
          ),
          // Chớp nháy
          SwitchListTile(
            title: const Text('Chớp nháy'),
            value: bannerProvider.isBlinking,
            onChanged: (value) => bannerProvider.toggleBlinking(value),
          ),
          // Hướng chạy
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => bannerProvider.updateDirection('left'),
                child: const Text('Trái'),
              ),
              TextButton(
                onPressed: () => bannerProvider.updateDirection('right'),
                child: const Text('Phải'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
