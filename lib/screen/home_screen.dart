// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import '../core/thema/index.dart';
import '../core/widgets/back_button_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackButtonHeader(title: 'HistoryBox'),
              _buildWelcomeCard(),
              const SizedBox(height: AppDimensions.paddingL),
              _buildCategorySection(),
              const SizedBox(height: AppDimensions.paddingL),
              _buildRecentStoriesSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
        },
        icon: const Icon(Icons.add),
        label: const Text('Yeni Hikaye'),
        backgroundColor: AppColors.accentOrange,
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryRed,
            AppColors.primaryRed.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hoş Geldin!',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            'Hayal gücünü keşfet ve kendi hikayeni yarat!',
            style: TextStyle(
              color: AppColors.textLight.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    final categories = [
      {'icon': Icons.auto_stories, 'title': 'Masallar', 'color': Colors.blue},
      {'icon': Icons.history_edu, 'title': 'Hikayeler', 'color': Colors.green},
      {'icon': Icons.music_note, 'title': 'Şiirler', 'color': Colors.purple},
      {'icon': Icons.science, 'title': 'Bilim', 'color': Colors.orange},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategoriler',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppDimensions.paddingM,
            mainAxisSpacing: AppDimensions.paddingM,
            childAspectRatio: 1.5,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCard(
              icon: category['icon'] as IconData,
              title: category['title'] as String,
              color: category['color'] as Color,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: InkWell(
        onTap: () {
          // Kategori sayfasına yönlendirme
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentStoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Son Oluşturulan Hikayeler',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return _buildStoryCard(
              title: 'Örnek Hikaye ${index + 1}',
              description: 'Bu hikayenin kısa açıklaması...',
              date: 'Bugün',
            );
          },
        ),
      ],
    );
  }

  Widget _buildStoryCard({
    required String title,
    required String description,
    required String date,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppDimensions.paddingM),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.paddingS),
            Text(description),
            const SizedBox(height: AppDimensions.paddingS),
            Text(
              date,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () {
          // Hikaye detay sayfasına yönlendirme
        },
      ),
    );
  }
}