import 'package:flutter/material.dart';

class CategoryData {
  final IconData icon;
  final Color color;
  final String label;

  const CategoryData(this.icon, this.color, this.label);
}

const categories = {
  'Salário': CategoryData(Icons.attach_money, Colors.green, 'Salário'),
  'Alimentação': CategoryData(Icons.restaurant, Colors.orange, 'Alimentação'),
  'Transporte': CategoryData(Icons.directions_car, Colors.blue, 'Transporte'),
  'Lazer': CategoryData(Icons.movie, Colors.purple, 'Lazer'),
  'Educação': CategoryData(Icons.school, Colors.teal, 'Educação'),
  'Saúde': CategoryData(Icons.local_hospital, Colors.redAccent, 'Saúde'),
  'Casa': CategoryData(Icons.home, Colors.brown, 'Casa'),
  'Investimentos': CategoryData(Icons.trending_up, Colors.lightGreen, 'Investimentos'),
  'Serviços': CategoryData(Icons.build, Colors.indigo, 'Serviços'),
  'Outros': CategoryData(Icons.category, Colors.grey, 'Outros'),
};


String normalizeCategory(String? raw) {
  if (raw == null || raw.trim().isEmpty) return 'Outros';
  final v = raw.trim();


  if (categories.containsKey(v)) return v;


  final lower = v.toLowerCase();

  if (lower == 'salario' || lower == 'salário') return 'Salário';
  if (lower == 'saude' || lower == 'saúde') return 'Saúde';
  if (lower == 'alimentacao' || lower == 'alimentação') return 'Alimentação';
  if (lower == 'transporte') return 'Transporte';
  if (lower == 'lazer') return 'Lazer';
  if (lower == 'educacao' || lower == 'educação') return 'Educação';
  if (lower == 'compras') return 'Compras';
  if (lower == 'casa') return 'Casa';
  if (lower == 'servicos' || lower == 'serviços') return 'Serviços';
  if (lower == 'viagem') return 'Viagem';
  if (lower == 'investimentos') return 'Investimentos';

  return 'Outros';
}
