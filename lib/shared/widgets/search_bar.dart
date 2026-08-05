import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSearch;
  final VoidCallback? onAiTap;
  final TextEditingController? controller;
  final bool isLoading;
  final bool showAiButton;

  const CustomSearchBar({
    Key? key,
    this.hintText = 'Search artisans...',
    this.onChanged,
    this.onSearch,
    this.onAiTap,
    this.controller,
    this.isLoading = false,
    this.showAiButton = false,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_handleTextChanged);
  }

  void _handleTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.inputHeight,
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        onSubmitted: (_) {
          if (!widget.isLoading) widget.onSearch?.call();
        },
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.outlineVariant,
          ),
          prefixIcon: Icon(
            PhosphorIcons.magnifyingGlass,
            color: AppColors.outlineVariant,
            size: AppSpacing.iconMedium,
          ),
          suffixIcon: widget.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (_controller.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _controller.clear();
                          widget.onChanged?.call('');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            PhosphorIcons.x,
                            color: AppColors.outlineVariant,
                            size: AppSpacing.iconSmall,
                          ),
                        ),
                      ),
                    if (widget.showAiButton || widget.onAiTap != null)
                      IconButton(
                        tooltip: 'Smart AI Search',
                        icon: const Icon(
                          PhosphorIcons.sparkle,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        onPressed: widget.onAiTap ?? widget.onSearch,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                    const SizedBox(width: 8),
                  ],
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            borderSide: BorderSide(color: AppColors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            borderSide:
                BorderSide(color: AppColors.outline.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        style: AppTypography.bodyMedium,
      ),
    );
  }
}
