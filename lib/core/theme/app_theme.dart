import 'package:flutter/material.dart';
import 'app_colors.dart';

ThemeData appTheme() {
	final colorScheme = ColorScheme.fromSeed(
		seedColor: AppColors.primary,
		primary: AppColors.primary,
		secondary: AppColors.secondary,
		background: AppColors.background,
		surface: AppColors.surface,
		brightness: Brightness.light,
	);

	return ThemeData(
		useMaterial3: true,
		colorScheme: colorScheme,
		scaffoldBackgroundColor: AppColors.background,
		appBarTheme: AppBarTheme(
			backgroundColor: AppColors.primary,
			foregroundColor: Colors.white,
			elevation: 2,
			centerTitle: true,
		),
		elevatedButtonTheme: ElevatedButtonThemeData(
			style: ElevatedButton.styleFrom(
				backgroundColor: AppColors.secondary,
				foregroundColor: Colors.white,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
				padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
			),
		),
		inputDecorationTheme: const InputDecorationTheme(
			filled: true,
			fillColor: Color(0xFFF7F9FB),
			border: OutlineInputBorder(
				borderRadius: BorderRadius.all(Radius.circular(10)),
				borderSide: BorderSide.none,
			),
		),
		textTheme: const TextTheme(
			titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
			bodyMedium: TextStyle(fontSize: 14),
		),
	);
}
