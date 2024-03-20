import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SearchField extends HookWidget {
  final FocusNode focusNode;
  final GlobalKey<FormState> formKey;
  final ValueNotifier<String> searchText;

  const SearchField({
    required this.focusNode,
    required this.formKey,
    required this.searchText,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(
          left: Grid.side,
          right: Grid.side,
          bottom: Grid.xs,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: Grid.xs),
              TextFormField(
                focusNode: focusNode,
                onTapOutside: (_) => focusNode.unfocus(),
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: Loc.of(context).search,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Grid.side,
                  ),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Grid.xs),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => searchText.value = value,
              ),
            ],
          ),
        ),
      );
}
