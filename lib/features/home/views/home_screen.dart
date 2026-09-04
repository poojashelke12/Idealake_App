import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/ui_helpers.dart';

/// Modern Enterprise Digital Workplace & Corporate Portal HomeScreen for Idealake
class HomeScreen extends StatefulWidget {
  final void Function(int tabIndex)? onTabSwitch;

  const HomeScreen({super.key, this.onTabSwitch});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Sample data for Enterprise Dashboard
  final List<Map<String, dynamic>> _workplaceMetrics = [
    {
      'label': 'Company News',
      'count': '48+',
      'subtitle': 'Published articles',
      'icon': Icons.newspaper_rounded,
      'color': Color(0xFF00529B),
      'tabIndex': 1,
    },
    {
      'label': 'Open Positions',
      'count': '14',
      'subtitle': 'Tech & design roles',
      'icon': Icons.work_outline_rounded,
      'color': Color(0xFFF39200),
      'tabIndex': 2,
    },
    {
      'label': 'Document Library',
      'count': '180+',
      'subtitle': 'Files & guidelines',
      'icon': Icons.folder_open_rounded,
      'color': Color(0xFF00A3E0),
      'tabIndex': 3,
    },
    {
      'label': 'Client Engagements',
      'count': '25+',
      'subtitle': 'Active transformations',
      'icon': Icons.rocket_launch_rounded,
      'color': Color(0xFF10B981),
      'tabIndex': -1,
    },
  ];

  final List<Map<String, dynamic>> _trendingNews = [
    {
      'id': 'news-01',
      'title': 'Sitefinity Headless CMS v15 Released: Real-time Content APIs',
      'category': 'TECHNOLOGY',
      'readTime': '3 min read',
      'date': 'Today',
      'author': 'Pooja Shelke',
      'summary':
          'Sitefinity 15 introduces full GraphQL support, decoupled next-gen content delivery, and ultra-fast media caching for enterprise mobile applications.',
    },
    {
      'id': 'news-02',
      'title': 'Idealake Wins Enterprise Digital Experience Partner of the Year 2026',
      'category': 'CORPORATE',
      'readTime': '5 min read',
      'date': 'Yesterday',
      'author': 'Pooja Shelke',
      'summary':
          'Recognized for industry-leading omnichannel customer journey redesigns across major banking, financial services, and retail conglomerates.',
    },
    {
      'id': 'news-03',
      'title': 'Decoupled Mobile Architectures: Driving Performance in FinServ Apps',
      'category': 'INSIGHTS',
      'readTime': '4 min read',
      'date': '2 days ago',
      'author': 'Technology Team',
      'summary':
          'How modern Flutter frontends combined with Sitefinity headless microservices deliver sub-second screen loads and enterprise-grade security.',
    },
  ];

  final List<Map<String, dynamic>> _hotCareers = [
    {
      'title': 'Technical Architect - AEM',
      'department': 'TECHNOLOGY',
      'experience': 'Exp 6+ Years',
      'location': 'Mumbai • Hybrid',
      'type': 'Full Time',
      'skills': ['Adobe AEM', 'Java/J2EE', 'Architecture'],
      'linkedin': 'https://www.linkedin.com/company/idealake/mycompany/',
    },
    {
      'title': 'Senior Flutter Developer',
      'department': 'ENGINEERING',
      'experience': 'Exp 4+ Years',
      'location': 'Mumbai / Remote',
      'type': 'Full Time',
      'skills': ['Flutter', 'Dart', 'BLoC', 'Clean Architecture'],
      'linkedin': 'https://www.linkedin.com/company/idealake/mycompany/',
    },
    {
      'title': 'Senior Copywriter / Group Head',
      'department': 'CONTENT',
      'experience': 'Exp 5+ Years',
      'location': 'Mumbai • Full Time',
      'type': 'Full Time',
      'skills': ['Brand Voice', 'Ideation', 'Content Strategy'],
      'linkedin': 'https://www.linkedin.com/company/idealake/mycompany/',
    },
  ];

  final List<Map<String, dynamic>> _essentialDocs = [
    {
      'title': 'ResumeDocument Library',
      'filesCount': '45 documents',
      'category': 'Recruitment',
      'format': 'PDF / DOCX',
      'updated': '18 Sep 2023',
      'icon': Icons.description_rounded,
      'color': Color(0xFF00529B),
    },
    {
      'title': 'Brand Identity & Design Assets 2026',
      'filesCount': '24 files',
      'category': 'Design System',
      'format': 'Figma / SVG / PDF',
      'updated': '24 Jan 2026',
      'icon': Icons.palette_rounded,
      'color': Color(0xFFF39200),
    },
    {
      'title': 'Information Security & Compliance Policy',
      'filesCount': '12 documents',
      'category': 'IT Governance',
      'format': 'PDF Secured',
      'updated': '10 Feb 2026',
      'icon': Icons.security_rounded,
      'color': Color(0xFF10B981),
    },
  ];

  final List<Map<String, dynamic>> _capabilities = [
    {
      'title': 'Sitefinity Headless CMS',
      'category': 'Tech',
      'description': 'Decoupled content orchestration and omnichannel APIs.',
      'icon': Icons.cloud_done_rounded,
      'badge': 'Core CMS',
    },
    {
      'title': 'Mobile Engineering',
      'category': 'Tech',
      'description': 'Cross-platform Flutter apps with Clean Architecture.',
      'icon': Icons.phone_android_rounded,
      'badge': 'Flutter',
    },
    {
      'title': 'Experience Design',
      'category': 'Design',
      'description': 'User journeys, responsive design systems & wireframes.',
      'icon': Icons.brush_rounded,
      'badge': 'UI/UX',
    },
    {
      'title': 'Cloud & DevOps',
      'category': 'Infrastructure',
      'description': 'Automated CI/CD pipelines & zero-downtime deployments.',
      'icon': Icons.cloud_queue_rounded,
      'badge': 'DevOps',
    },
    {
      'title': 'AI & Intelligent Search',
      'category': 'Tech',
      'description': 'Contextual search and automated content workflows.',
      'icon': Icons.auto_awesome_rounded,
      'badge': 'AI',
    },
    {
      'title': 'Quality Engineering',
      'category': 'QA',
      'description': 'Automated regression testing and performance audits.',
      'icon': Icons.fact_check_rounded,
      'badge': 'QA',
    },
  ];

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 700));
          if (!mounted) return;
          UIHelpers.showSuccessSnackBar(this.context, 'Workplace dashboard synced with Sitefinity CMS.');
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 14, bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Enterprise Greeting & Search Hero
              _buildEnterpriseHero(),

              const SizedBox(height: 18),

              // 2. Workplace Metrics KPI Grid
              _buildWorkplaceMetricsGrid(),

              const SizedBox(height: 20),

              // 3. Quick Action Bar
              _buildWorkplaceQuickActions(),

              const SizedBox(height: 24),

              // 4. Featured Spotlight Banner (Innovation Spotlight)
              _buildSpotlightBanner(),

              const SizedBox(height: 24),

              // 5. Trending News & Corporate Insights
              _buildTrendingNewsSection(),

              const SizedBox(height: 24),

              // 6. Active Career Openings Spotlight
              _buildHotCareersSection(),

              const SizedBox(height: 24),

              // 7. Essential Document Repositories
              _buildEssentialDocumentsSection(),

              const SizedBox(height: 24),

              // 8. Enterprise Capabilities & Digital Services
              _buildCapabilitiesSection(),

              const SizedBox(height: 20),

              // 9. Footer Brand Info
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. Enterprise Greeting & Search Hero
  // ==========================================
  Widget _buildEnterpriseHero() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003D7A), Color(0xFF00529B), Color(0xFF0066C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00529B).withAlpha(45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withAlpha(50)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4ADE80), // emerald green
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Sitefinity CMS • Connected',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Help / Helpdesk quick action
              InkWell(
                onTap: _showHelpdeskModal,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.headset_mic_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Helpdesk',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            '${_getTimeGreeting()}, Team Idealake 👋',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Digital Workplace & Enterprise Content Hub',
            style: TextStyle(
              color: Colors.white.withAlpha(210),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 16),

          // Interactive Search Bar
          InkWell(
            onTap: _showGlobalSearchModal,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Search news, jobs, document guidelines...',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Icon(Icons.tune_rounded, color: Color(0xFF00529B), size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. Workplace Metrics KPI Grid (4 Cards)
  // ==========================================
  Widget _buildWorkplaceMetricsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workplace Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _workplaceMetrics.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
            ),
            itemBuilder: (context, index) {
              final m = _workplaceMetrics[index];
              final Color color = m['color'] as Color;
              final int tabIndex = m['tabIndex'] as int;

              return InkWell(
                onTap: () {
                  if (tabIndex >= 0 && widget.onTabSwitch != null) {
                    widget.onTabSwitch!(tabIndex);
                  } else {
                    UIHelpers.showSnackBar(context, '${m['label']}: ${m['count']} ${m['subtitle']}');
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(7),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withAlpha(25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(m['icon'] as IconData, color: color, size: 20),
                          ),
                          if (tabIndex >= 0)
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: Color(0xFF94A3B8),
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m['count'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            m['label'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            m['subtitle'] as String,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF94A3B8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. Quick Action Bar
  // ==========================================
  Widget _buildWorkplaceQuickActions() {
    final actions = [
      {
        'label': 'News & Media',
        'icon': Icons.newspaper_rounded,
        'color': const Color(0xFF00529B),
        'tab': 1,
      },
      {
        'label': 'Careers',
        'icon': Icons.work_outline_rounded,
        'color': const Color(0xFFF39200),
        'tab': 2,
      },
      {
        'label': 'Documents',
        'icon': Icons.folder_open_rounded,
        'color': const Color(0xFF00A3E0),
        'tab': 3,
      },
      {
        'label': 'IT Support',
        'icon': Icons.support_agent_rounded,
        'color': const Color(0xFF10B981),
        'tab': -1,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: actions.map((act) {
              final color = act['color'] as Color;
              final tab = act['tab'] as int;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () {
                      if (tab >= 0 && widget.onTabSwitch != null) {
                        widget.onTabSwitch!(tab);
                      } else if (tab == -1) {
                        _showHelpdeskModal();
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(5),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withAlpha(22),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(act['icon'] as IconData, color: color, size: 22),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            act['label'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. Featured Spotlight Banner (Innovation Spotlight)
  // ==========================================
  Widget _buildSpotlightBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Color(0xFF00529B), size: 12),
                    SizedBox(width: 4),
                    Text(
                      'INNOVATION SPOTLIGHT',
                      style: TextStyle(
                        color: Color(0xFF00529B),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'Digital Architecture',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Sitefinity Headless CMS + Flutter Enterprise Integration',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Decoupled content orchestration delivering high-performance cross-platform experiences for enterprise financial services and omnichannel brand portals.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.verified_rounded, size: 14, color: Color(0xFF10B981)),
                  SizedBox(width: 4),
                  Text(
                    'Production Ready',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _showCaseStudyModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00529B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Explore Architecture',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 5. Trending News & Corporate Insights
  // ==========================================
  Widget _buildTrendingNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'News & Press Releases',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              TextButton(
                onPressed: () {
                  if (widget.onTabSwitch != null) {
                    widget.onTabSwitch!(1); // Tab 1: News
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF00529B),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded, color: Color(0xFF00529B), size: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _trendingNews.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = _trendingNews[index];
            return InkWell(
              onTap: () => _showNewsPreviewModal(item),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00529B).withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.newspaper_rounded, color: Color(0xFF00529B), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item['category'] as String,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item['readTime'] as String,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                item['date'] as String,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['title'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['summary'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // 6. Active Career Openings Spotlight
  // ==========================================
  Widget _buildHotCareersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text(
                    'Featured Career Openings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(width: 6),
                  Badge(
                    label: Text('HIRING'),
                    backgroundColor: Color(0xFFF39200),
                    textColor: Colors.white,
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  if (widget.onTabSwitch != null) {
                    widget.onTabSwitch!(2); // Tab 2: Career
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  children: [
                    Text(
                      'All Roles',
                      style: TextStyle(
                        color: Color(0xFF00529B),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded, color: Color(0xFF00529B), size: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _hotCareers.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final job = _hotCareers[index];
            final skills = (job['skills'] as List<String>);

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFFEDD5)),
                        ),
                        child: Text(
                          job['department'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC2410C),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          job['experience'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job['title'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(
                        job['location'] as String,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.schedule_rounded, size: 13, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(
                        job['type'] as String,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: skills.map((s) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          s,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF475569)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          if (widget.onTabSwitch != null) {
                            widget.onTabSwitch!(2); // Navigate to Careers tab
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00529B),
                          side: const BorderSide(color: Color(0xFF00529B)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('View in Careers Tab', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 13),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // 7. Essential Document Repositories
  // ==========================================
  Widget _buildEssentialDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Essential Document Libraries',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              TextButton(
                onPressed: () {
                  if (widget.onTabSwitch != null) {
                    widget.onTabSwitch!(3); // Tab 3: Documents
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  children: [
                    Text(
                      'All Libraries',
                      style: TextStyle(
                        color: Color(0xFF00529B),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded, color: Color(0xFF00529B), size: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _essentialDocs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final doc = _essentialDocs[index];
            final color = doc['color'] as Color;

            return InkWell(
              onTap: () {
                if (widget.onTabSwitch != null) {
                  widget.onTabSwitch!(3); // Open Documents Tab
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color.withAlpha(22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(doc['icon'] as IconData, color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc['title'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                doc['filesCount'] as String,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFCBD5E1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                doc['format'] as String,
                                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: Color(0xFFCBD5E1),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // 8. Enterprise Capabilities & Digital Services
  // ==========================================
  Widget _buildCapabilitiesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enterprise Capabilities',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Explore core digital engineering and omnichannel solutions.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),

          // Capabilities Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _capabilities.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (context, index) {
              final cap = _capabilities[index];

              return InkWell(
                onTap: () => _showCapabilityDetailModal(cap),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(6),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00529B).withAlpha(18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(cap['icon'] as IconData, color: const Color(0xFF00529B), size: 18),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              cap['badge'] as String,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cap['title'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cap['description'] as String,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF64748B),
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 9. Footer
  // ==========================================
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      alignment: Alignment.center,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF00529B),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Idealake Digital Workplace • Sitefinity Headless CMS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Version 4.2.0 • Secure Enterprise Portal',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFFCBD5E1),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Interactive Modals & Bottom Sheets
  // ==========================================

  // Global Search Modal across all 3 modules
  void _showGlobalSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return _WorkplaceSearchSheet(
          onNavigateTab: (tabIndex) {
            Navigator.pop(modalCtx);
            if (widget.onTabSwitch != null) {
              widget.onTabSwitch!(tabIndex);
            }
          },
        );
      },
    );
  }

  // Employee Helpdesk & Support Modal
  void _showHelpdeskModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.headset_mic_rounded, color: Color(0xFF00529B), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Workplace Support & Helpdesk',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Reach out to internal IT, HR, or Sitefinity CMS technical administrators.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),

                // Support options
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00529B).withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.email_outlined, color: Color(0xFF00529B)),
                  ),
                  title: const Text('CMS & IT Support Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('support@idealake.com', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                  onTap: () {
                    Navigator.pop(modalCtx);
                    UIHelpers.showSnackBar(context, 'Support email copied: support@idealake.com');
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF39200).withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.badge_outlined, color: Color(0xFFF39200)),
                  ),
                  title: const Text('HR & Careers Query', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('careers@idealake.com', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                  onTap: () {
                    Navigator.pop(modalCtx);
                    if (widget.onTabSwitch != null) {
                      widget.onTabSwitch!(2); // Navigate to Careers
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.folder_shared_outlined, color: Color(0xFF10B981)),
                  ),
                  title: const Text('Document Library Access Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('Request access to restricted repositories', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                  onTap: () {
                    Navigator.pop(modalCtx);
                    if (widget.onTabSwitch != null) {
                      widget.onTabSwitch!(3); // Navigate to Documents
                    }
                  },
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(modalCtx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00529B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Close Helpdesk', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Case Study Architecture Modal
  void _showCaseStudyModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'ARCHITECTURE BREAKDOWN',
                      style: TextStyle(
                        color: Color(0xFF00529B),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sitefinity Headless CMS + Mobile Decoupled Model',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Idealake specializes in delivering high-speed digital architectures. By integrating Sitefinity Headless OData APIs with a reactive Flutter client (MVVM + BLoC), the application achieves instant cached offline experiences, sub-second responses, and unified multi-tenant authentication.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  _buildArchFeature(Icons.speed_rounded, 'Sub-second API latency with local cache fallbacks'),
                  _buildArchFeature(Icons.lock_outline_rounded, 'Sitefinity OpenAccess OAuth bearer session governance'),
                  _buildArchFeature(Icons.sync_rounded, 'Real-time synchronization across News, Careers, and Documents'),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(modalCtx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00529B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Understood', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArchFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF00529B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // News Preview Modal
  void _showNewsPreviewModal(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item['category'] as String,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00529B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item['date']} • ${item['readTime']}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item['summary'] as String,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 12,
                      backgroundColor: Color(0xFFE2E8F0),
                      child: Icon(Icons.person, size: 14, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Published by ${item['author']}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(modalCtx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(modalCtx);
                          if (widget.onTabSwitch != null) {
                            widget.onTabSwitch!(1); // Go to News Tab
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00529B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Read in News Tab', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Capability Detail Modal
  void _showCapabilityDetailModal(Map<String, dynamic> cap) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00529B).withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(cap['icon'] as IconData, color: const Color(0xFF00529B), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cap['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Category: ${cap['category']}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  cap['description'] as String,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Enterprise consulting, SLA support, and dedicated delivery teams available.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF475569)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(modalCtx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00529B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Unified Global Search Bottom Sheet (Searches across News, Careers, Documents)
class _WorkplaceSearchSheet extends StatefulWidget {
  final void Function(int tabIndex) onNavigateTab;

  const _WorkplaceSearchSheet({required this.onNavigateTab});

  @override
  State<_WorkplaceSearchSheet> createState() => _WorkplaceSearchSheetState();
}

class _WorkplaceSearchSheetState extends State<_WorkplaceSearchSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filter = 'All';

  final List<Map<String, dynamic>> _quickSuggestions = [
    {'title': 'Sitefinity 15 CMS Release', 'type': 'News', 'tab': 1},
    {'title': 'Technical Architect - AEM', 'type': 'Career', 'tab': 2},
    {'title': 'Senior Flutter Developer', 'type': 'Career', 'tab': 2},
    {'title': 'ResumeDocument Library', 'type': 'Document', 'tab': 3},
    {'title': 'Brand Assets & Guidelines', 'type': 'Document', 'tab': 3},
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _quickSuggestions.where((item) {
      final matchesFilter = _filter == 'All' || item['type'] == _filter;
      final query = _searchCtrl.text.trim().toLowerCase();
      final matchesQuery = query.isEmpty || (item['title'] as String).toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Search Enterprise Workplace',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),

            // Text Field
            TextField(
              controller: _searchCtrl,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Type to search news, careers, documents...',
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00529B)),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00529B), width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Filter Chips
            Row(
              children: ['All', 'News', 'Career', 'Document'].map((f) {
                final isSelected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(f),
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: const Color(0xFF00529B),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF00529B) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            const Text(
              'Quick Results',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),

            // Results List
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No matching records found.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final type = item['type'] as String;
                        final tab = item['tab'] as int;

                        IconData icon;
                        Color iconColor;
                        if (type == 'News') {
                          icon = Icons.newspaper_rounded;
                          iconColor = const Color(0xFF00529B);
                        } else if (type == 'Career') {
                          icon = Icons.work_outline_rounded;
                          iconColor = const Color(0xFFF39200);
                        } else {
                          icon = Icons.description_rounded;
                          iconColor = const Color(0xFF10B981);
                        }

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: iconColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(icon, color: iconColor, size: 18),
                          ),
                          title: Text(
                            item['title'] as String,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          subtitle: Text(
                            'Module: $type',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Open',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00529B),
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, size: 12, color: Color(0xFF00529B)),
                              ],
                            ),
                          ),
                          onTap: () => widget.onNavigateTab(tab),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
