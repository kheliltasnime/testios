import 'package:flutter/material.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/app_placeholder_state.dart';

class PetDetailsScreen extends StatelessWidget {
  final String petId;

  const PetDetailsScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Details de l\'animal',
      child: AppPlaceholderState(
        title: 'Fiche animal en preparation',
        message: 'Consultation de la fiche pour l\'animal ID: $petId.',
        icon: Icons.pets_outlined,
      ),
    );
  }
}
