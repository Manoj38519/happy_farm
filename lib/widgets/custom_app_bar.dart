import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuTap;
  final bool showCloseButton;
  const CustomAppBar({
    Key? key,
    required this.onMenuTap,
    this.showCloseButton = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final appBarHeight = screenHeight * 0.18;

    return Container(
      height: appBarHeight,
      decoration: const BoxDecoration(
        color: Color(0xFF007B4F),
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
              // Logo Image
              ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
              ),

              // App Title
              Row(
                children: const [
                  Icon(Icons.eco, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'SafeFarm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Icons
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Menu + Search Bar
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
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
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
