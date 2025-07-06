import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnest_app/ui/log/nutritionIntake_viewmodel.dart';

class NutritionIntakePage extends StatefulWidget {
  const NutritionIntakePage({super.key});

  @override
  State<NutritionIntakePage> createState() => _NutritionIntakePageState();
}

class _NutritionIntakePageState extends State<NutritionIntakePage> {
  final _formKey = GlobalKey<FormState>();
  final _caloriesController = TextEditingController();
  final _viewModel = NutritionIntakeViewModel();

  String _mealType = 'Breakfast';
  final List<String> _mealTypes = [
    'Breakfast',
    'Brunch',
    'Lunch',
    'Tea',
    'Dinner',
    'Supper',
    'Snack',
    'Other',
  ];

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _viewModel.addFood(
          userId: user.uid,
          mealType: _mealType,
          calories: double.tryParse(_caloriesController.text.trim()) ?? 0,
          mealTime: DateTime.now(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nutrition intake logged')),
        );

        _caloriesController.clear();
        setState(() => _mealType = 'Breakfast');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Nutrition Intake')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _mealType,
                decoration: const InputDecoration(labelText: 'Meal Type'),
                items: _mealTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _mealType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(labelText: 'Calories (kcal)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || double.tryParse(value) == null
                        ? 'Enter valid calories'
                        : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Intake'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
