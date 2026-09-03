import 'package:flutter/material.dart';

import '../../../core/utils/ui_helpers.dart';

/// Sitefinity CMS Dashboard / Home Screen
/// Replaces the old home screen with the Sitefinity CMS Dashboard UI
/// Fully driven by dummy data with zero API dependencies
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDomainErrorExpanded = false;

  // Dummy Content Data
  final List<_ContentItemData> _everyoneContent = const [
    _ContentItemData(
      title: 'Testpage1',
      status: 'Published',
      author: 'Gauri Desai',
      date: '02 April 2025',
    ),
  ];

  final List<_ContentItemData> _myContent = const [
    _ContentItemData(
      title: 'Testpage1',
      status: 'Published',
      author: 'Gauri Desai',
      date: '02 April 2025',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16, bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. System status alert card (Red vertical bar accent)
            _buildSystemStatusCard(),

            const SizedBox(height: 12),

            // 2. Subscription Expired alert card (Red vertical bar accent)
            _buildSubscriptionExpiredCard(),

            const SizedBox(height: 12),

            // 3. Analytics timeline card (Line chart placeholder & "No stats enabled")
            _buildAnalyticsTimelineCard(),

            const SizedBox(height: 12),

            // 4. Everyone's content card
            _buildContentSectionCard(
              title: "Everyone's content",
              items: _everyoneContent,
            ),

            const SizedBox(height: 12),

            // 5. My content card
            _buildContentSectionCard(title: 'My content', items: _myContent),
          ],
        ),
      ),
    );
  }

  /// 1. System Status Card with Red Top Accent Bar
  Widget _buildSystemStatusCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Red accent bar at the TOP
            Container(
              height: 3.5,
              width: double.infinity,
              color: const Color(0xFFDC2626),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon badge + Title
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFDE8E8),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.error_outline_rounded,
                            color: Color(0xFFDC2626),
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'System status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Error message with "More" link
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF374151),
                        height: 1.45,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Domain license error: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text:
                              'There are errors with the licensed domain(s). This may result in getting a Trial message on the frontend of your site. The following domain(s) are not registered in your license... ',
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isDomainErrorExpanded =
                                    !_isDomainErrorExpanded;
                              });
                            },
                            child: Text(
                              _isDomainErrorExpanded ? 'Less' : 'More',
                              style: const TextStyle(
                                color: Color(0xFF003D99),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_isDomainErrorExpanded) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Text(
                        'Unregistered domain: localhost:8080, cms.idealake.internal.\nPlease update your license file or add your domain to the licensed domains list.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Timestamp metadata with icons
                  Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    children: const [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: Color(0xFF6B7280),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Detected on 02 Sep, 2026 10:21',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 13,
                            color: Color(0xFF6B7280),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Next check in 1 min',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 16),

                  // Full-width solid blue "Find a solution ->" button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003D99),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        UIHelpers.showSnackBar(
                          context,
                          'Redirecting to Sitefinity License Troubleshooting guide.',
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Find a solution',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 2. Subscription Expired Card with Red Top Accent Bar
  Widget _buildSubscriptionExpiredCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Red accent bar at the TOP
            Container(
              height: 3.5,
              width: double.infinity,
              color: const Color(0xFFDC2626),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon badge + Title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFDE8E8),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFDC2626),
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Your subscription for Sitefinity 14.1 has expired',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Subtext
                  const Text(
                    'Renew your license to maintain access to critical product updates and technical support.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Expiration and License Holder Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'EXPIRATION',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '31 Jan 2024',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'LICENSE HOLDER',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Ketan Sahasrabudhe',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 1),
                            Text(
                              'webmaster@idealake.com',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 16),

                  // 1. Purchase a renewal (full width, shopping cart icon)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003D99),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        UIHelpers.showSuccessSnackBar(
                          context,
                          'Initiating Sitefinity license renewal workflow.',
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Purchase a renewal',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. Update license file (full width, light grey/blue tinted)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        foregroundColor: const Color(0xFF003D99),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        UIHelpers.showSnackBar(
                          context,
                          'License file update dialog opened.',
                        );
                      },
                      child: const Text(
                        'Update license file',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF003D99),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. Why renew? -> link centered
                  Center(
                    child: InkWell(
                      onTap: () {
                        UIHelpers.showSnackBar(
                          context,
                          'Sitefinity 14.1 renewal benefits overview.',
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Why renew?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF003D99),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 15,
                              color: Color(0xFF003D99),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 3. Analytics Timeline Card with Chart Placeholder and "No stats enabled"
  Widget _buildAnalyticsTimelineCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analytics timeline',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'You need to have Analytics module installed and configured in order to use statistics.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),

          // Chart illustration container with "No stats enabled" badge
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Stack(
              children: [
                // Faint wavy line chart curves painted in background
                Positioned.fill(
                  child: CustomPaint(painter: _ChartBackgroundPainter()),
                ),

                // Center white badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.insert_chart_outlined_rounded,
                          color: Color(0xFF4B5563),
                          size: 26,
                        ),
                        SizedBox(height: 6),
                        Text(
                          'No stats enabled',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // "Go to Analytics" Link with circle icon
          InkWell(
            onTap: () {
              UIHelpers.showSnackBar(
                context,
                'Navigating to Sitefinity Analytics Module configuration.',
              );
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_circle_right_outlined,
                  color: Color(0xFF003D99),
                  size: 18,
                ),
                SizedBox(width: 6),
                Text(
                  'Go to Analytics',
                  style: TextStyle(
                    color: Color(0xFF003D99),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 4 & 5. Content Section Cards (Everyone's content & My content)
  Widget _buildContentSectionCard({
    required String title,
    required List<_ContentItemData> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const Text(
                'LAST MODIFIED',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 12),

          // Content Items List
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  // Document Icon Container with Check badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 36,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: Color(0xFF4B5563),
                          size: 20,
                        ),
                      ),
                      const Positioned(
                        top: -3,
                        right: -3,
                        child: Icon(
                          Icons.check_circle,
                          color: Color(0xFF003D99),
                          size: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Title and Published status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.status,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // View Link ↗
                  InkWell(
                    onTap: () {
                      UIHelpers.showSnackBar(
                        context,
                        'Viewing ${item.title} preview.',
                      );
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF003D99),
                          ),
                        ),
                        SizedBox(width: 3),
                        Icon(
                          Icons.open_in_new_rounded,
                          size: 12,
                          color: Color(0xFF003D99),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Author & Date on the right
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item.author,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.date,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper model for dummy content items
class _ContentItemData {
  final String title;
  final String status;
  final String author;
  final String date;

  const _ContentItemData({
    required this.title,
    required this.status,
    required this.author,
    required this.date,
  });
}

/// Custom painter to draw faint wavy line chart curves for the Analytics timeline placeholder
class _ChartBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final paint2 = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.75);
    path1.cubicTo(
      size.width * 0.25,
      size.height * 0.65,
      size.width * 0.4,
      size.height * 0.85,
      size.width * 0.65,
      size.height * 0.7,
    );
    path1.cubicTo(
      size.width * 0.8,
      size.height * 0.6,
      size.width * 0.9,
      size.height * 0.8,
      size.width,
      size.height * 0.7,
    );
    canvas.drawPath(path1, paint1);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.5);
    path2.cubicTo(
      size.width * 0.2,
      size.height * 0.6,
      size.width * 0.35,
      size.height * 0.4,
      size.width * 0.55,
      size.height * 0.55,
    );
    path2.cubicTo(
      size.width * 0.75,
      size.height * 0.7,
      size.width * 0.85,
      size.height * 0.35,
      size.width,
      size.height * 0.45,
    );
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
