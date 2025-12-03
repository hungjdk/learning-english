import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/services/auth_service.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/data/models/word.dart';
import '../features/auth/services/vocab_service.dart';
import 'edit_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Service to fetch vocabulary data
  final VocabService _vocabService = VocabService();

  int _currentStreak = 0;
  int _totalXP = 0;
  int _currentLesson = 1;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  Future<void> _checkEmailVerification() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.reloadUser();
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: AppTheme.errorRed),
            const SizedBox(width: 12),
            Text('Sign Out?'),
          ],
        ),
        content: Text(
          'You will lose your current progress if you haven\'t saved it.',
          style: TextStyle(color: AppTheme.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paleBlue,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  // ==================== APP BAR ====================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Builder(
        builder: (context) => Consumer<AuthService>(
          builder: (context, authService, child) {
            final user = authService.currentUser;
            final userData = authService.currentUserData;
            final photoUrl = userData?.photoUrl ?? user?.photoURL;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryBlue, width: 2),
                    image: photoUrl != null && photoUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(photoUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (photoUrl == null || photoUrl.isEmpty)
                      ? Center(
                          child: Text(
                            user?.displayName?.substring(0, 1).toUpperCase() ??
                                'U',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            );
          },
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accentYellow.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: AppTheme.accentYellow,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_currentStreak',
                  style: TextStyle(
                    color: AppTheme.accentYellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.warningYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: AppTheme.warningYellow, size: 20),
                const SizedBox(width: 4),
                Text(
                  '$_totalXP',
                  style: TextStyle(
                    color: AppTheme.warningYellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryBlue),
          onPressed: () {
            // Shop action
          },
        ),
      ],
    );
  }

  // ==================== DRAWER ====================
  Widget _buildDrawer() {
    return Drawer(
      child: Consumer<AuthService>(
        builder: (context, authService, child) {
          final user = authService.currentUser;
          final userData = authService.currentUserData;
          // Use photoUrl from Firestore if available, fallback to Firebase Auth
          final photoUrl = userData?.photoUrl ?? user?.photoURL;

          debugPrint('🖼️ Drawer rendering - photoUrl: $photoUrl');
          debugPrint('   - userData?.photoUrl: ${userData?.photoUrl}');
          debugPrint('   - user?.photoURL: ${user?.photoURL}');

          return Column(
            children: [
              // Header with user info
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(24, 60, 24, 24),
                decoration: BoxDecoration(color: AppTheme.primaryBlue),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        image: photoUrl != null && photoUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(photoUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (photoUrl == null || photoUrl.isEmpty)
                          ? Center(
                              child: Text(
                                user?.displayName
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    'U',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Name
                    Text(
                      userData?.displayName ?? user?.displayName ?? 'User',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Email
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Menu items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      icon: Icons.person_outline,
                      title: 'Profile',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to settings
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.emoji_events_outlined,
                      title: 'Achievements',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to achievements
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.leaderboard_outlined,
                      title: 'Leaderboard',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to leaderboard
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Shop',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to shop
                      },
                    ),
                    Divider(height: 1),
                    _buildDrawerItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to help
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.info_outline,
                      title: 'About',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to about
                      },
                    ),
                  ],
                ),
              ),

              // Logout button at bottom
              Container(
                padding: EdgeInsets.all(16),
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleLogout();
                  },
                  icon: Icon(Icons.logout_rounded),
                  label: Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorRed,
                    side: BorderSide(color: AppTheme.errorRed, width: 2),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.textDark,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  // ==================== BODY ====================
  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Daily Goal Card
          _buildDailyGoalCard(),

          const SizedBox(height: 24),

          // Language Path Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'My Vocabulary', // Changed title
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // NEW: Display the list of words from Firestore
          _buildWordList(),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ==================== WORD LIST ====================
  Widget _buildWordList() {
    return StreamBuilder<List<Word>>(
      stream: _vocabService.getWords(),
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Handle error state
        if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return const Center(child: Text('Something went wrong!'));
        }
        // Handle empty state
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No words found yet. Try adding one!'),
            ),
          );
        }

        // Display the list of words
        final words = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true, // Important for nested scrolling
          physics:
              const NeverScrollableScrollPhysics(), // Let the parent scroll
          itemCount: words.length,
          itemBuilder: (context, index) {
            final word = words[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                title: Text(
                  word.word,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(word.meaning),
                trailing: Text(
                  '/${word.ipa}/',
                  style: TextStyle(color: AppTheme.textGrey),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==================== DAILY GOAL CARD ====================
  Widget _buildDailyGoalCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative emoji in corner
          Positioned(
            top: -5,
            right: -5,
            child: Text('🎯', style: TextStyle(fontSize: 35)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Daily Goal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('🌟', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '0/20 XP',
                      style: TextStyle(
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LinearProgressIndicator(
                  value: 0.0,
                  minHeight: 12,
                  backgroundColor: AppTheme.paleBlue,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.successGreen,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Complete lessons to reach your daily goal!',
                style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== (Old) LEARNING PATH WIDGETS ====================
  // I've kept these here in case you want to use them later.

  Widget _buildLearningPath() {
    return Column(
      children: [
        _buildLessonNode(
          lessonNumber: 1,
          title: 'Basics 1',
          subtitle: 'Learn basic greetings',
          icon: Icons.waving_hand,
          emoji: '👋',
          isCompleted: false,
          isActive: true,
          progress: 0.3,
        ),
        _buildPathConnector(),

        _buildLessonNode(
          lessonNumber: 2,
          title: 'Basics 2',
          subtitle: 'Common phrases',
          icon: Icons.chat_bubble_outline,
          emoji: '💬',
          isCompleted: false,
          isActive: false,
          isLocked: true,
        ),
        _buildPathConnector(),

        _buildLessonNode(
          lessonNumber: 3,
          title: 'Grammar 1',
          subtitle: 'Sentence structure',
          icon: Icons.school_outlined,
          emoji: '📝',
          isCompleted: false,
          isActive: false,
          isLocked: true,
        ),
        _buildPathConnector(),

        _buildLessonNode(
          lessonNumber: 4,
          title: 'Vocabulary',
          subtitle: 'Daily words',
          icon: Icons.menu_book_outlined,
          emoji: '📚',
          isCompleted: false,
          isActive: false,
          isLocked: true,
        ),
        _buildPathConnector(),

        _buildLessonNode(
          lessonNumber: 5,
          title: 'Practice',
          subtitle: 'Review & test',
          icon: Icons.quiz_outlined,
          emoji: '🎯',
          isCompleted: false,
          isActive: false,
          isLocked: true,
        ),
      ],
    );
  }

  Widget _buildLessonNode({
    required int lessonNumber,
    required String title,
    required String subtitle,
    required IconData icon,
    String? emoji,
    required bool isCompleted,
    required bool isActive,
    bool isLocked = false,
    double progress = 0.0,
  }) {
    Color getColor() {
      if (isCompleted) return AppTheme.successGreen;
      if (isActive) return AppTheme.primaryBlue;
      return Colors.grey.shade300;
    }

    return GestureDetector(
      onTap: isLocked
          ? null
          : () {
              _startLesson(lessonNumber);
            },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // Lesson Circle
            Stack(
              alignment: Alignment.center,
              children: [
                // Progress circle
                if (isActive && progress > 0)
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(getColor()),
                    ),
                  ),

                // Main circle
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isLocked ? Colors.grey.shade200 : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: getColor(), width: 4),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: getColor().withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                  child: isLocked
                      ? Icon(Icons.lock, color: Colors.grey, size: 32)
                      : isCompleted
                      ? Icon(
                          Icons.check,
                          color: AppTheme.successGreen,
                          size: 40,
                        )
                      : Icon(icon, color: getColor(), size: 36),
                ),
              ],
            ),

            const SizedBox(width: 20),

            // Lesson Info
            Expanded(
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Lesson $lessonNumber',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (isActive)
                              Container(
                                margin: EdgeInsets.only(left: 8),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Current',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isLocked ? Colors.grey : AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Emoji decoration
                  if (emoji != null && !isLocked)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Text(emoji, style: TextStyle(fontSize: 28)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPathConnector() {
    return Container(
      margin: EdgeInsets.only(left: 59),
      width: 4,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // ==================== ACTIONS ====================
  void _startLesson(int lessonNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.play_circle_outline, color: AppTheme.primaryBlue),
            const SizedBox(width: 12),
            Text('Start Lesson $lessonNumber?'),
          ],
        ),
        content: Text('You\'re about to start a new lesson. Are you ready?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Not Yet'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Start lesson logic here
            },
            child: Text('Let\'s Go!'),
          ),
        ],
      ),
    );
  }

  void _showUserProfile() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    final userData = authService.currentUserData;
    // Use photoUrl from Firestore if available, fallback to Firebase Auth
    final photoUrl = userData?.photoUrl ?? user?.photoURL;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.paleBlue,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryBlue,
                          width: 4,
                        ),
                        image: photoUrl != null && photoUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(photoUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (photoUrl == null || photoUrl.isEmpty)
                          ? Center(
                              child: Text(
                                user?.displayName
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    'U',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Name
                    Text(
                      user?.displayName ?? 'User',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Email
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.paleBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user?.email ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(
                          icon: Icons.local_fire_department,
                          value: '$_currentStreak',
                          label: 'Day Streak',
                          color: AppTheme.accentYellow,
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: Colors.grey.shade200,
                        ),
                        _buildStatItem(
                          icon: Icons.star,
                          value: '$_totalXP',
                          label: 'Total XP',
                          color: AppTheme.warningYellow,
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: Colors.grey.shade200,
                        ),
                        _buildStatItem(
                          icon: Icons.emoji_events,
                          value: '0',
                          label: 'Achievements',
                          color: AppTheme.successGreen,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Account info
                    _buildProfileInfoCard(
                      icon: Icons.verified_user_outlined,
                      title: 'Verification Status',
                      value: user?.emailVerified == true
                          ? 'Verified ✓'
                          : 'Not Verified',
                      valueColor: user?.emailVerified == true
                          ? AppTheme.successGreen
                          : AppTheme.warningYellow,
                    ),
                    _buildProfileInfoCard(
                      icon: Icons.calendar_today_outlined,
                      title: 'Member Since',
                      value: _formatDate(user?.metadata.creationTime),
                    ),
                    _buildProfileInfoCard(
                      icon: Icons.access_time_outlined,
                      title: 'Last Sign In',
                      value: _formatDate(user?.metadata.lastSignInTime),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
      ],
    );
  }

  Widget _buildProfileInfoCard({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.paleBlue.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
