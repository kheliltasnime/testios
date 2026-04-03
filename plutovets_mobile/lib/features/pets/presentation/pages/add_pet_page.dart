import 'package:flutter/material.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/app_placeholder_state.dart';

class AddPetScreen extends StatelessWidget {
  final String? petId;

  const AddPetScreen({super.key, this.petId});

  @override
  Widget build(BuildContext context) {
    final isEdit = petId != null;
    return AppPageScaffold(
      title: isEdit ? 'Modifier l\'animal' : 'Ajouter un animal',
      child: AppPlaceholderState(
        title: isEdit ? 'Edition en preparation' : 'Creation en preparation',
        message: isEdit
            ? 'Edition de l\'animal ID: $petId.'
            : 'Le formulaire de creation sera disponible bientot.',
        icon: Icons.edit_note_rounded,
      ),
    );
  }
}
