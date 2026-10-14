import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/dashboard_controller.dart';
import '../../models/dashboard_summary.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import '../../widgets/state_views.dart';
import '../../widgets/summary_card.dart';

/// Dashboard penjualan: kartu ringkasan + BarChart, LineChart, PieChart (fl_chart).
class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  /// Palet kategorikal tervalidasi (urutan tetap, buta-warna aman).
  static const kategoriColors = [
    Color(0xFF2A78D6),
    Color(0xFFEB6834),
    Color(0xFF1BAF7A),
    Color(0xFFEDA100),
    Color(0xFFE87BA4),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Penjualan'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: controller.fetchSummary,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Obx(() {
        final s = controller.summary.value;
        if (controller.isLoading.value && s == null) return const LoadingView(message: 'Menghitung penjualan...');
        final err = controller.errorMessage.value;
        if (err != null && s == null) return ErrorState(message: err, onRetry: controller.fetchSummary);
        if (s == null) return const SizedBox.shrink();
        return RefreshIndicator(
          onRefresh: () => controller.fetchSummary(silent: true),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [
                  SummaryCard(
                    title: 'Total Pesanan',
                    value: '${s.totalPesanan}',
                    icon: Icons.receipt_long_rounded,
                    subtitle:
                        '${s.pesananDiproses} diproses, ${s.pesananSelesai} selesai, ${s.pesananDibatalkan} batal',
                  ),
                  SummaryCard(
                    title: 'Total Pendapatan',
                    value: Formatter.rupiah(s.totalPendapatan),
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColors.success,
                    subtitle: 'Hanya dari pesanan berstatus Selesai',
                  ),
                  SummaryCard(
                    title: 'Produk Terlaris',
                    value: s.terlaris == null ? '-' : '${s.terlaris!.totalTerjual} terjual',
                    icon: Icons.emoji_events_rounded,
                    color: AppColors.accent,
                    subtitle: s.terlaris?.namaProduk ?? 'Belum ada penjualan',
                  ),
                  SummaryCard(
                    title: 'Produk',
                    value: '${s.totalProduk}',
                    icon: Icons.inventory_2_rounded,
                    color: AppColors.secondary,
                    subtitle: '${s.produkHabis} produk habis / kuota penuh',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ChartCard(
                title: '5 Produk Terlaris',
                subtitle: 'Jumlah terjual (tidak termasuk pesanan dibatalkan)',
                child: s.produkTerlaris.isEmpty ? const _NoData() : _TerlarisChart(data: s.produkTerlaris),
              ),
              const SizedBox(height: 16),
              _ChartCard(
                title: 'Pendapatan 7 Hari Terakhir',
                subtitle: 'Pesanan Selesai per hari',
                child: _PendapatanChart(data: s.pendapatanHarian),
              ),
              const SizedBox(height: 16),
              _ChartCard(
                title: 'Penjualan per Kategori',
                subtitle: 'Nilai penjualan (tidak termasuk pesanan dibatalkan)',
                child: s.penjualanKategori.isEmpty ? const _NoData() : _KategoriPie(data: s.penjualanKategori),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _NoData extends StatelessWidget {
  const _NoData();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 120,
    child: Center(
      child: Text('Belum ada data penjualan.', style: TextStyle(color: AppColors.textSecondary)),
    ),
  );
}

const _axisStyle = TextStyle(fontSize: 10, color: AppColors.textSecondary);

class _TerlarisChart extends StatelessWidget {
  const _TerlarisChart({required this.data});

  final List<ProdukTerlaris> data;

  @override
  Widget build(BuildContext context) {
    final maxY = data.map((e) => e.totalTerjual).reduce((a, b) => a > b ? a : b).toDouble();
    final top = (maxY + 1).ceilToDouble();
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: top,
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: top <= 6 ? 1 : (top / 5).ceilToDouble(),
                getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.textPrimary,
                  getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                    '${data[group.x].namaProduk}\n${rod.toY.toInt()} terjual',
                    const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    interval: top <= 6 ? 1 : (top / 5).ceilToDouble(),
                    getTitlesWidget: (v, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text(v.toInt().toString(), style: _axisStyle),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (v, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text('#${v.toInt() + 1}', style: _axisStyle),
                    ),
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < data.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i].totalTerjual.toDouble(),
                        width: 22,
                        color: AppColors.primary,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < data.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                SizedBox(
                  width: 26,
                  child: Text('#${i + 1}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                ),
                Expanded(
                  child: Text(
                    data[i].namaProduk,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Text(
                  '${data[i].totalTerjual} terjual',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PendapatanChart extends StatelessWidget {
  const _PendapatanChart({required this.data});

  final List<PendapatanHarian> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const _NoData();
    final maxV = data.map((e) => e.pendapatan).fold<double>(0, (a, b) => a > b ? a : b);
    // Interval sumbu "rapi" (25rb/50rb/100rb/250rb/...) agar label mudah dibaca.
    final step = _niceStep(maxV <= 0 ? 100000 : maxV * 1.1 / 4);
    final top = step * 4;
    final total = data.fold<double>(0, (s, e) => s + e.pendapatan);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total 7 hari: ${Formatter.rupiah(total)}',
          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          padding: const EdgeInsets.only(right: 14),
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: top,
              minX: 0,
              maxX: (data.length - 1).toDouble(),
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: step,
                getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                getTouchedSpotIndicator: (bar, idx) => idx
                    .map(
                      (_) => const TouchedSpotIndicatorData(
                        FlLine(color: AppColors.textSecondary, strokeWidth: 1, dashArray: [4, 4]),
                        FlDotData(),
                      ),
                    )
                    .toList(),
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.textPrimary,
                  getTooltipItems: (spots) => spots.map((s) {
                    final d = data[s.x.toInt()];
                    return LineTooltipItem(
                      '${Formatter.tanggalPendek(d.tanggal)}\n${Formatter.rupiah(d.pendapatan)}\n${d.jumlahPesanan} pesanan',
                      const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    );
                  }).toList(),
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    interval: step,
                    getTitlesWidget: (v, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text(Formatter.ringkas(v), style: _axisStyle),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 32,
                    getTitlesWidget: (v, meta) {
                      final i = v.toInt();
                      if (i < 0 || i >= data.length || v != i.toDouble()) return const SizedBox.shrink();
                      final d = data[i].tanggal;
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          '${Formatter.hariSingkat(d)}\n${Formatter.tanggalPendek(d)}',
                          textAlign: TextAlign.center,
                          style: _axisStyle,
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [for (var i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i].pendapatan)],
                  color: AppColors.primary,
                  barWidth: 2,
                  dotData: FlDotData(
                    getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                      radius: 4,
                      color: AppColors.primary,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
                  ),
                  belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.08)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

double _niceStep(double raw) {
  const steps = [25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 1000000.0, 2500000.0, 5000000.0];
  for (final s in steps) {
    if (raw <= s) return s;
  }
  return (raw / 10000000).ceil() * 10000000.0;
}

class _KategoriPie extends StatefulWidget {
  const _KategoriPie({required this.data});

  final List<PenjualanKategori> data;

  @override
  State<_KategoriPie> createState() => _KategoriPieState();
}

class _KategoriPieState extends State<_KategoriPie> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final total = data.fold<double>(0, (s, e) => s + e.totalPenjualan);
    Color colorOf(int i) => DashboardView.kategoriColors[i % DashboardView.kategoriColors.length];
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 42,
              pieTouchData: PieTouchData(
                touchCallback: (event, resp) {
                  setState(() {
                    _touched = (!event.isInterestedForInteractions || resp?.touchedSection == null)
                        ? -1
                        : resp!.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: [
                for (var i = 0; i < data.length; i++)
                  PieChartSectionData(
                    value: data[i].totalPenjualan,
                    color: colorOf(i),
                    radius: _touched == i ? 58 : 50,
                    title: total == 0 ? '' : '${(data[i].totalPenjualan / total * 100).round()}%',
                    titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < data.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: colorOf(i), borderRadius: BorderRadius.circular(3)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${data[i].namaKategori} (${data[i].totalTerjual} item)',
                    style: TextStyle(fontSize: 12, fontWeight: _touched == i ? FontWeight.w800 : FontWeight.w500),
                  ),
                ),
                Text(
                  Formatter.rupiah(data[i].totalPenjualan),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
