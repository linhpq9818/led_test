import 'package:flutter/material.dart';
import 'package:ledbanner_test/control_panel.dart';
import 'package:provider/provider.dart';
import 'banner_provider.dart';

class BannerScreen extends StatelessWidget {
  const BannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bannerProvider = Provider.of<BannerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LED Banner'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: bannerProvider,
                builder: (context, _) {
                  return Text(
                    'LED BANNER',
                    style: TextStyle(
                      fontSize: bannerProvider.fontSize,
                      color: bannerProvider.textColor,
                      fontFamily: bannerProvider.fontFamily,
                    ),
                  );
                },
              ),
            ),
          ),
          ControlsPanel(),
        ],
      ),
    );
  }
}
