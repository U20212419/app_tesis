import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StructurationScreen extends StatelessWidget {
  const StructurationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estructuración'),
        centerTitle: true,
        backgroundColor: AppColors.neutralLightLightest,
      ),
      body: const Center(
        child: Text('Vista de estructuración'),
      ),
    );
  }
}
