import 'package:flutter/material.dart';

import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/custom_search_bar.dart';

/// Screen displaying Career Opportunities, Open Positions & Application Flow
class CareerScreen extends StatefulWidget {
  const CareerScreen({super.key});

  @override
  State<CareerScreen> createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Engineering',
    'Design',
    'QA & Cloud',
    'Product',
  ];

  final List<_JobOpening> _allJobs = const [
    _JobOpening(
      id: 'job_01',
      title: 'Senior Flutter Developer',
      department: 'Engineering',
      location: 'Mumbai, India (Hybrid)',
      employmentType: 'Full-Time',
      experience: '4-7 Years',
      isUrgent: true,
      salaryRange: '₹18 LPA - ₹28 LPA',
      description:
          'Lead cross-platform mobile engineering for enterprise client portals with offline-first caching, BLoC state architecture, and Sitefinity CMS REST/OData integrations.',
      responsibilities: [
        'Architect and implement scalable Flutter mobile solutions with MVVM & BLoC pattern.',
        'Integrate headless CMS endpoints with secure token caching and offline synchronization.',
        'Conduct code reviews, mentor junior developers, and establish unit/widget testing standards.',
        'Collaborate with UI/UX designers and backend teams to deliver high-performance user journeys.',
      ],
      requirements: [
        'Strong expertise in Flutter & Dart with at least 4+ years of mobile development experience.',
        'Demonstrated mastery of BLoC, Dio networking, interceptors, and local caching.',
        'Experience integrating RESTful APIs and headless CMS systems (Sitefinity, Strapi, or similar).',
        'Proficiency with CI/CD deployment pipelines (Google Play Console & Apple App Store).',
      ],
    ),
    _JobOpening(
      id: 'job_02',
      title: 'Sitefinity CMS Tech Lead / Architect',
      department: 'Engineering',
      location: 'Pune / Remote',
      employmentType: 'Full-Time',
      experience: '7-11 Years',
      isUrgent: true,
      salaryRange: '₹26 LPA - ₹38 LPA',
      description:
          'Drive enterprise headless CMS architectures using Progress Sitefinity 14.x/15.x, .NET Core render engines, and decoupled frontends.',
      responsibilities: [
        'Define system architecture and technical blueprints for enterprise Sitefinity multi-site deployments.',
        'Develop custom Sitefinity widgets, OData endpoints, and dynamic layout modules.',
        'Optimize CMS performance, cache invalidation strategies, and cloud infrastructure.',
        'Lead technical customer workshops and guide development sprint deliveries.',
      ],
      requirements: [
        '7+ years experience with C#, ASP.NET MVC / .NET Core and relational databases (SQL Server).',
        'Proven hands-on expertise building and customizing Sitefinity CMS architectures.',
        'Understanding of headless content delivery, OpenID Connect/OAuth2 auth flows, and CDN caching.',
      ],
    ),
    _JobOpening(
      id: 'job_03',
      title: 'Senior UI/UX Product Designer',
      department: 'Design',
      location: 'Mumbai / Hybrid',
      employmentType: 'Full-Time',
      experience: '3-6 Years',
      isUrgent: false,
      salaryRange: '₹14 LPA - ₹22 LPA',
      description:
          'Craft intuitive, accessible digital experiences and enterprise design systems for leading financial services and enterprise clients.',
      responsibilities: [
        'Design responsive design systems, component libraries, and cross-platform UI mockups.',
        'Conduct user research, usability testing, and translate business workflows into simple user journeys.',
        'Work closely with Flutter and web developers to ensure pixel-perfect design implementation.',
      ],
      requirements: [
        '3+ years of digital product design experience with an outstanding portfolio.',
        'Advanced proficiency with Figma, auto-layout, design tokens, and interactive prototyping.',
        'Deep understanding of Material Design 3 guidelines and iOS Human Interface Guidelines.',
      ],
    ),
    _JobOpening(
      id: 'job_04',
      title: 'DevOps & Cloud Security Specialist',
      department: 'QA & Cloud',
      location: 'Remote, India',
      employmentType: 'Full-Time',
      experience: '4-8 Years',
      isUrgent: false,
      salaryRange: '₹20 LPA - ₹30 LPA',
      description:
          'Manage cloud infrastructure, automated CI/CD deployment pipelines, container orchestration, and security compliance for enterprise applications.',
      responsibilities: [
        'Automate build, testing, and release pipelines using GitHub Actions, Docker, and Kubernetes.',
        'Maintain high availability, zero-downtime deployments, and cloud monitoring across AWS and Azure.',
        'Implement enterprise security best practices, vulnerability scans, and SSL/certificate management.',
      ],
      requirements: [
        'Experience with AWS / Azure cloud environments, Docker, and Kubernetes.',
        'Proficiency with Infrastructure as Code (Terraform), scripting (Bash, Python, PowerShell).',
        'Strong understanding of networking, load balancers, CDN setups, and enterprise security standards.',
      ],
    ),
    _JobOpening(
      id: 'job_05',
      title: 'Lead QA Automation Engineer',
      department: 'QA & Cloud',
      location: 'Mumbai, India',
      employmentType: 'Full-Time',
      experience: '5-8 Years',
      isUrgent: false,
      salaryRange: '₹16 LPA - ₹24 LPA',
      description:
          'Lead test automation frameworks across mobile apps, web portals, and headless API endpoints to guarantee high stability and release quality.',
      responsibilities: [
        'Design and execute automated test suites for Flutter mobile apps and web platforms.',
        'Perform performance testing, regression testing, and API integration testing with Postman/RestAssured.',
        'Collaborate with developers in sprint cycles to maintain high defect detection and fast resolution.',
      ],
      requirements: [
        '5+ years in software QA with at least 3+ years in automated mobile testing (Appium, Flutter Driver, or Maestro).',
        'Strong scripting and API validation skills.',
        'Experience in Agile/Scrum environments and test management tools (Jira, Zephyr).',
      ],
    ),
    _JobOpening(
      id: 'job_06',
      title: 'Technical Product Manager',
      department: 'Product',
      location: 'Mumbai / Hybrid',
      employmentType: 'Full-Time',
      experience: '5-9 Years',
      isUrgent: false,
      salaryRange: '₹22 LPA - ₹34 LPA',
      description:
          'Own the product roadmap for enterprise CMS solutions and digital transformation products, bridging client business needs with technical execution.',
      responsibilities: [
        'Define product scope, user stories, and acceptance criteria for software engineering teams.',
        'Analyze product analytics, client feedback, and prioritize sprint backlogs effectively.',
        'Act as the primary bridge between enterprise stakeholders, clients, and engineering squads.',
      ],
      requirements: [
        '5+ years product management experience in enterprise software or digital consultancies.',
        'Strong technical background with ability to evaluate architectural trade-offs.',
        'Exceptional communication, stakeholder alignment, and data-driven prioritization skills.',
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_JobOpening> get _filteredJobs {
    final query = _searchController.text.trim().toLowerCase();
    return _allJobs.where((job) {
      final matchesCategory = _selectedCategory == 'All' ||
          job.department.toLowerCase().contains(_selectedCategory.toLowerCase());
      final matchesQuery = query.isEmpty ||
          job.title.toLowerCase().contains(query) ||
          job.department.toLowerCase().contains(query) ||
          job.location.toLowerCase().contains(query) ||
          job.description.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final jobs = _filteredJobs;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Banner Card
            _buildHeroBanner(),

            const SizedBox(height: 16),

            // 2. Search & Category Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomSearchBar(
                controller: _searchController,
                hintText: 'Search roles, skills, or locations...',
                onChanged: (_) => setState(() {}),
                onClear: () => setState(() {}),
              ),
            ),

            const SizedBox(height: 12),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: const Color(0xFF003D99),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF4B5563),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF003D99) : const Color(0xFFE5E7EB),
                        ),
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // 3. Culture & Perks Highlights Strip
            _buildPerksStrip(),

            const SizedBox(height: 20),

            // 4. Open Positions Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Open Positions (${jobs.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    'Updated Today',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 5. Job Cards List
            if (jobs.isEmpty)
              _buildEmptyState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: jobs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildJobCard(jobs[index]);
                },
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003D99), Color(0xFF002266)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF003D99).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CAREERS AT IDEALAKE',
                      style: TextStyle(
                        color: Color(0xFF93C5FD),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Text(
                      'Build the Future with Us',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Join an agile, innovative team shaping enterprise digital portals, Sitefinity CMS platforms, and modern mobile solutions for Fortune 500 leaders.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerksStrip() {
    final perks = [
      {'icon': Icons.home_work_outlined, 'title': 'Hybrid & Remote'},
      {'icon': Icons.trending_up_rounded, 'title': 'Fast Growth'},
      {'icon': Icons.health_and_safety_outlined, 'title': 'Health Coverage'},
      {'icon': Icons.school_outlined, 'title': 'Learning Budget'},
    ];

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: perks.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final perk = perks[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFEFF6FF),
                  child: Icon(perk['icon'] as IconData, size: 18, color: const Color(0xFF003D99)),
                ),
                const SizedBox(width: 10),
                Text(
                  perk['title'] as String,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobCard(_JobOpening job) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title + Urgent tag
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                if (job.isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 6),

            // Department & Location
            Row(
              children: [
                const Icon(Icons.business_rounded, size: 14, color: Color(0xFF6B7280)),
                const SizedBox(width: 4),
                Text(
                  job.department,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563), fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF6B7280)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.location,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Badges row: Experience, Type, Salary
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildBadge(Icons.work_outline, job.employmentType),
                _buildBadge(Icons.timer_outlined, job.experience),
                _buildBadge(Icons.payments_outlined, job.salaryRange, isHighlighted: true),
              ],
            ),

            const SizedBox(height: 12),

            // Summary
            Text(
              job.description,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF4B5563),
                height: 1.35,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 12),

            // Actions Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF003D99),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _showJobDetailsModal(job),
                    child: const Text(
                      'View Details',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003D99),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _showApplyModal(job),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Apply Now',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, {bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFEFF6FF) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isHighlighted ? const Color(0xFFBFDBFE) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isHighlighted ? const Color(0xFF003D99) : const Color(0xFF6B7280),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
              color: isHighlighted ? const Color(0xFF003D99) : const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 12),
            const Text(
              'No Positions Found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try adjusting your search keywords or filter category.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _selectedCategory = 'All';
                });
              },
              child: const Text('Reset Filters'),
            ),
          ],
        ),
      ),
    );
  }

  void _showJobDetailsModal(_JobOpening job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Job Title & Department
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${job.department} • ${job.location}',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBadge(Icons.work_outline, job.employmentType),
                        _buildBadge(Icons.timer_outlined, job.experience),
                        _buildBadge(Icons.payments_outlined, job.salaryRange, isHighlighted: true),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // Role Overview
                    const Text(
                      'Role Overview',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      job.description,
                      style: const TextStyle(fontSize: 13.5, color: Color(0xFF374151), height: 1.45),
                    ),

                    const SizedBox(height: 20),

                    // Key Responsibilities
                    const Text(
                      'Key Responsibilities',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 8),
                    ...job.responsibilities.map(
                      (resp) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: Color(0xFF003D99), fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                resp,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Requirements
                    const Text(
                      'Requirements & Qualifications',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 8),
                    ...job.requirements.map(
                      (req) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('✓ ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                req,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Apply Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003D99),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showApplyModal(job);
                        },
                        child: const Text(
                          'Apply for this Position',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showApplyModal(_JobOpening job) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final urlController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Apply for Role',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              job.title,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF003D99), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: urlController,
                    decoration: InputDecoration(
                      labelText: 'Portfolio / LinkedIn / GitHub URL',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Resume Upload Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.upload_file_rounded, color: Color(0xFF003D99), size: 24),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Resume / CV Attached',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Resume_Candidate.pdf (1.2 MB)',
                                style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            UIHelpers.showSnackBar(context, 'Document selector opened.');
                          },
                          child: const Text('Replace'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003D99),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (nameController.text.trim().isEmpty || emailController.text.trim().isEmpty) {
                                UIHelpers.showSnackBar(context, 'Please enter your name and email address.');
                                return;
                              }

                              setModalState(() {
                                isSubmitting = true;
                              });

                              await Future.delayed(const Duration(milliseconds: 900));

                              if (context.mounted) {
                                Navigator.pop(context);
                                UIHelpers.showSuccessSnackBar(
                                  context,
                                  'Application submitted successfully for ${job.title}!',
                                );
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Submit Application',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JobOpening {
  final String id;
  final String title;
  final String department;
  final String location;
  final String employmentType;
  final String experience;
  final bool isUrgent;
  final String salaryRange;
  final String description;
  final List<String> responsibilities;
  final List<String> requirements;

  const _JobOpening({
    required this.id,
    required this.title,
    required this.department,
    required this.location,
    required this.employmentType,
    required this.experience,
    required this.isUrgent,
    required this.salaryRange,
    required this.description,
    required this.responsibilities,
    required this.requirements,
  });
}
