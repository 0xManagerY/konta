import 'package:flutter/material.dart';

class LoadingShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LoadingShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                LoadingShimmer(width: 48, height: 48, borderRadius: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LoadingShimmer(width: 120, height: 16),
                      const SizedBox(height: 8),
                      LoadingShimmer(width: 80, height: 12),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LoadingShimmer(width: double.infinity, height: 12),
            const SizedBox(height: 8),
            LoadingShimmer(width: 200, height: 12),
          ],
        ),
      ),
    );
  }
}

class LoadingList extends StatelessWidget {
  final int itemCount;

  const LoadingList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: LoadingCard(),
      ),
    );
  }
}

class LoadingGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const LoadingGrid({super.key, this.itemCount = 4, this.crossAxisCount = 2});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingShimmer(width: 48, height: 48, borderRadius: 24),
              SizedBox(height: 16),
              LoadingShimmer(width: 80, height: 16),
              SizedBox(height: 8),
              LoadingShimmer(width: 60, height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
