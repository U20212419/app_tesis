import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        centerTitle: true,
        backgroundColor: AppColors.neutralLightLightest,
      ),
      body: const Center(
        child: Text('Vista de estadísticas'),
      ),
    );
  }
}
