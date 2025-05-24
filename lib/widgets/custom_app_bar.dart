import 'package:flutter/material.dart';
import 'package:happy_farm/utils/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuTap;
  final bool showCloseButton;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const CustomAppBar({
    Key? key,
    required this.onMenuTap,
    this.showCloseButton = false,
    required this.searchController,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final appBarHeight = screenHeight * 0.19;

    return Container(
      height: appBarHeight,
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: mediaQuery.padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
              ),

              // Title
              Row(
                children: const [
                  Text(
                    'SabbaFarm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Notifications
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 5),

          // Menu + Search
          Row(
            children: [
              IconButton(
                icon: Icon(
                  showCloseButton ? Icons.close : Icons.filter_list,
                  color: Colors.white,
                ),
                onPressed: onMenuTap,
              ),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: onSearchChanged,
                          decoration: const InputDecoration(
                            hintText: 'Search Product',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const Icon(Icons.mic_none, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2.5);
}
