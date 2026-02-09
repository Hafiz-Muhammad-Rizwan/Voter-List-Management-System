import 'package:flutter/material.dart';

class AppColors {
	AppColors._();

	static const Color primary = Color(0xFF0A2540); // deep navy
	static const Color secondary = Color(0xFF1F7A8C); // teal-ish
	static const Color accent = Color(0xFFF6A609); // warm amber
	static const Color surface = Color(0xFFF7F9FB);
	static const Color background = Color(0xFFFFFFFF);
	static const Color textPrimary = Color(0xFF0B2540);
}

class AppGradients {
	static const LinearGradient premium = LinearGradient(
		begin: Alignment.topLeft,
		end: Alignment.bottomRight,
		colors: [AppColors.primary, AppColors.secondary],
	);
}
