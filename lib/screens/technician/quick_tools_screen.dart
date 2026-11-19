import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/customer_model.dart';
import '../../providers/customer_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/empty_state.dart';

class QuickToolsScreen extends StatefulWidget {
  final int initialIndex;

  const QuickToolsScreen({super.key, this.initialIndex = 0});

  @override
  State<QuickToolsScreen> createState() => _QuickToolsScreenState();
}

class _QuickToolsScreenState extends State<QuickToolsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Search Customer Tab
  final _searchController = TextEditingController();
  CustomerModel? _selectedCustomer;
  bool _isRebooting = false;
  bool _isKicking = false;
  bool _isTogglingIsolate = false;

  // Ping Tool Tab
  final _pingTargetController = TextEditingController(text: '8.8.8.8');
  bool _isPinging = false;
  Map<String, dynamic>? _pingResult;

  // OLT Scan Tab
  bool _isScanningOlt = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: (widget.initialIndex >= 0 && widget.initialIndex < 3) ? widget.initialIndex : 0,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TicketProvider>(context, listen: false).fetchToolsOverview();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _pingTargetController.dispose();
    super.dispose();
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showInternalAccessDialog(String title, String url, String description) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.router_rounded, color: AppTheme.primaryBlue),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded, size: 16, color: AppTheme.primaryBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      url,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 13),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 16, color: AppTheme.primaryBlue),
                    tooltip: 'Salin URL',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: url));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Alamat URL berhasil disalin.')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(fontSize: 12.5, height: 1.4, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.accentOrange.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.wifi_rounded, size: 16, color: AppTheme.accentOrange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Halaman ini berada di jaringan internal (LAN). Pastikan HP terhubung ke Wi-Fi NOC / MikroTik Sukorejo atau menggunakan VPN WireGuard.',
                      style: TextStyle(fontSize: 11, color: AppTheme.accentOrange, fontWeight: FontWeight.w600, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _openUrl(url);
            },
            icon: const Icon(Icons.open_in_browser_rounded, size: 16),
            label: const Text('Buka di Browser'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _searchCustomer() async {
    final term = _searchController.text.trim();
    if (term.isEmpty) return;

    final custProvider = Provider.of<CustomerProvider>(context, listen: false);
    await custProvider.fetchCustomers(search: term);

    if (custProvider.customers.isNotEmpty) {
      setState(() {
        _selectedCustomer = custProvider.customers.first;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pelanggan tidak ditemukan.')),
        );
      }
    }
  }

  void _rebootModem() async {
    if (_selectedCustomer == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Reboot Modem'),
        content: Text('Apakah Anda yakin ingin mengirim sinyal reboot ke ONT milik ${_selectedCustomer!.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            child: const Text('Reboot'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isRebooting = true);
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final res = await ticketProvider.quickReboot(_selectedCustomer!.id);
    setState(() => _isRebooting = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['message']),
        backgroundColor: res['success'] ? AppTheme.accentGreen : AppTheme.accentRed,
      ),
    );
  }

  void _kickPppoeSession() async {
    if (_selectedCustomer == null) return;
    final username = _selectedCustomer!.mikrotikUsername;
    if (username == null || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username PPPoE pelanggan belum diset.')),
      );
      return;
    }

    setState(() => _isKicking = true);
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final res = await ticketProvider.kickPppoe(username, _selectedCustomer!.id);
    setState(() => _isKicking = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['message']),
        backgroundColor: res['success'] ? AppTheme.accentGreen : AppTheme.accentRed,
      ),
    );
  }

  void _toggleIsolateCustomer() async {
    if (_selectedCustomer == null) return;
    final isCurrentlyIsolated = _selectedCustomer!.status.toLowerCase() == 'suspended' || _selectedCustomer!.status.toLowerCase() == 'isolated';
    final action = isCurrentlyIsolated ? 'restore' : 'isolate';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isCurrentlyIsolated ? 'Buka Isolir Pelanggan?' : 'Isolir Pelanggan?'),
        content: Text(isCurrentlyIsolated
            ? 'Layanan internet ${_selectedCustomer!.name} akan diaktifkan kembali di MikroTik.'
            : 'Layanan internet ${_selectedCustomer!.name} akan diputus / diarahkan ke halaman isolir.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: isCurrentlyIsolated ? AppTheme.accentGreen : AppTheme.accentRed),
            child: Text(isCurrentlyIsolated ? 'Buka Isolir' : 'Isolir Sekarang'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isTogglingIsolate = true);
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final res = await ticketProvider.toggleIsolate(_selectedCustomer!.id, action);
    setState(() => _isTogglingIsolate = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['message']),
        backgroundColor: res['success'] ? AppTheme.accentGreen : AppTheme.accentRed,
      ),
    );
    _searchCustomer();
  }

  void _openChangeWifiDialog() {
    if (_selectedCustomer == null) return;

    final ssidController = TextEditingController(text: _selectedCustomer!.wifiSsid ?? '');
    final passController = TextEditingController(text: _selectedCustomer!.wifiPassword ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ganti Nama & Sandi Wi-Fi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pelanggan: ${_selectedCustomer!.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: ssidController,
              decoration: const InputDecoration(labelText: 'Nama Wi-Fi (SSID)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passController,
              decoration: const InputDecoration(labelText: 'Password Wi-Fi Baru'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final newSsid = ssidController.text.trim();
              final newPass = passController.text.trim();
              if (newSsid.isEmpty || newPass.isEmpty) return;

              Navigator.pop(ctx);
              final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
              final res = await ticketProvider.quickWifi(
                customerId: _selectedCustomer!.id,
                ssid: newSsid,
                password: newPass,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res['message']),
                    backgroundColor: res['success'] ? AppTheme.accentGreen : AppTheme.accentRed,
                  ),
                );
              }
            },
            child: const Text('Terapkan ke Modem'),
          ),
        ],
      ),
    );
  }

  void _runPingTest() async {
    final target = _pingTargetController.text.trim();
    if (target.isEmpty) return;

    setState(() {
      _isPinging = true;
      _pingResult = null;
    });

    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final res = await ticketProvider.pingTest(target);

    setState(() {
      _isPinging = false;
      _pingResult = res;
    });
  }

  void _runOltScan() async {
    setState(() => _isScanningOlt = true);
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    await ticketProvider.scanOltLos();
    setState(() => _isScanningOlt = false);
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overview = ticketProvider.toolsOverview ?? {};
    final mt = overview['mikrotik'] ?? {};
    final olt = overview['olt'] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tools Troubleshooting Network'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.router), text: 'MikroTik'),
            Tab(icon: Icon(Icons.settings_input_antenna), text: 'OLT Optik'),
            Tab(icon: Icon(Icons.wifi_find), text: 'ONT Pelanggan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ==========================================
          // TAB 1: MIKROTIK TOOLS
          // ==========================================
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.router, color: AppTheme.primaryBlue, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                mt['name']?.toString() ?? 'MikroTik Core Router',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: mt['connected'] == true ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              mt['connected'] == true ? 'CONNECTED' : 'OFFLINE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: mt['connected'] == true ? AppTheme.accentGreen : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Host IP: ${mt['host'] ?? "10.10.10.4"} • Model: ${mt['model'] ?? "x86 Router"}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const Divider(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('CPU LOAD', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              Text('${mt['cpu_load'] ?? 0}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('ACTIVE PPPOE', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              Text('${mt['active_pppoe'] ?? 0} Sesi', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.accentGreen)),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('UPTIME', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              Text('${mt['uptime'] ?? "-"}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showInternalAccessDialog(
                                'WebFig MikroTik Router Core',
                                mt['webfig_url'] ?? 'http://10.10.10.4',
                                'Antarmuka manajemen MikroTik Core Router Sukorejo.',
                              ),
                              icon: const Icon(Icons.open_in_browser, size: 16),
                              label: const Text('Buka WebFig'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => ticketProvider.fetchToolsOverview(),
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Card(
                color: const Color(0xFF141526),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFF00E5FF), width: 1.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.speed_rounded, color: Color(0xFF00E5FF), size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'SPEEDTEST RESMI (OOKLA STYLE)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF00E5FF), letterSpacing: 0.8),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Uji Download, Upload & Ping riil ke Core Router',
                              style: TextStyle(fontSize: 11, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _openUrl('${AppConfig.defaultBaseUrl}/speedtest'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF),
                          foregroundColor: const Color(0xFF0B0C17),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('MULAI'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text('Diagnostik Ping & Latensi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // Tool Ping Box
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _pingTargetController,
                              decoration: const InputDecoration(
                                labelText: 'Target IP / Hostname',
                                hintText: 'Contoh: 10.10.10.4 / 8.8.8.8',
                                prefixIcon: Icon(Icons.network_ping),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _isPinging ? null : _runPingTest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(80, 48),
                            ),
                            child: _isPinging
                                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Ping'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Quick preset targets
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          ActionChip(
                            avatar: const Icon(Icons.dns_rounded, size: 13, color: AppTheme.primaryBlue),
                            label: const Text('Google (8.8.8.8)', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              _pingTargetController.text = '8.8.8.8';
                              _runPingTest();
                            },
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.bolt_rounded, size: 13, color: AppTheme.accentCyan),
                            label: const Text('Cloudflare (1.1.1.1)', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              _pingTargetController.text = '1.1.1.1';
                              _runPingTest();
                            },
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.router_rounded, size: 13, color: AppTheme.accentOrange),
                            label: const Text('Core (10.10.10.4)', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              _pingTargetController.text = '10.10.10.4';
                              _runPingTest();
                            },
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.settings_input_antenna, size: 13, color: AppTheme.accentGreen),
                            label: const Text('OLT (192.168.3.100)', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              _pingTargetController.text = '192.168.3.100';
                              _runPingTest();
                            },
                          ),
                        ],
                      ),

                      if (_pingResult != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Target: ${_pingResult!['target']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _pingResult!['success'] == true ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _pingResult!['success'] == true ? 'REACHABLE' : 'TIMEOUT',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: _pingResult!['success'] == true ? AppTheme.accentGreen : Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Packet Loss: ${_pingResult!['packet_loss'] ?? "0%"}', style: const TextStyle(fontSize: 12)),
                                  Text('Avg Latency: ${_pingResult!['avg_latency'] ?? "0 ms"}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text('Uji Notifikasi Suara', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // Test notification sound card
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.accentRed.withOpacity(0.15),
                    child: const Icon(Icons.notifications_active_rounded, color: AppTheme.accentRed, size: 22),
                  ),
                  title: const Text('Tes Nada Dering & Getar Alarm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  subtitle: const Text('Bunyikan alarm darurat LOS untuk menguji speaker HP', style: TextStyle(fontSize: 11.5)),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await NotificationService.testNotificationSound();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notifikasi alarm darurat bersuara dikirim ke HP.')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentRed,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(80, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Bunyikan'),
                  ),
                ),
              ),
            ],
          ),

          // ==========================================
          // TAB 2: OLT OPTIK TOOLS
          // ==========================================
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.settings_input_antenna, color: AppTheme.primaryBlue, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                olt['name']?.toString() ?? 'OLT C-Data FD1602S',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: olt['connected'] == true ? Colors.blue.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              olt['connected'] == true ? 'CONNECTED' : 'OFFLINE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: olt['connected'] == true ? AppTheme.primaryBlue : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Host IP: ${olt['host'] ?? "192.168.3.100"} • Rata-rata Sinyal: ${olt['avg_rx_power'] ?? "-18.5 dBm"}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const Divider(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('TOTAL ONUS', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              Text('${olt['total_onus'] ?? 110}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('ONLINE', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              Text('${olt['online_count'] ?? 96}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.accentGreen)),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('LOS / OFF', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              Text('${olt['offline_count'] ?? 14}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.accentRed)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showInternalAccessDialog(
                                'WebGUI OLT C-Data FD1602S',
                                olt['webgui_url'] ?? 'http://192.168.3.100',
                                'Antarmuka konfigurasi OLT Optik C-Data FD1602S Sukorejo.',
                              ),
                              icon: const Icon(Icons.open_in_browser, size: 16),
                              label: const Text('Buka WebGUI OLT'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _isScanningOlt ? null : _runOltScan,
                            icon: _isScanningOlt
                                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.radar, size: 16),
                            label: const Text('Scan LOS'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentOrange, foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Daftar Gangguan LOS / Power Off', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text('${ticketProvider.losOnus.length} Terdeteksi', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
              const SizedBox(height: 8),

              if (ticketProvider.losOnus.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle_outline, color: AppTheme.accentGreen, size: 36),
                          const SizedBox(height: 8),
                          const Text('Sinyal Optik Normal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Klik tombol "Scan LOS" di atas untuk mendeteksi kabel putus.',
                              style: TextStyle(fontSize: 11.5, color: Colors.grey[600]), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...ticketProvider.losOnus.map((item) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.accentRed.withOpacity(0.12),
                        child: const Icon(Icons.warning_amber, color: AppTheme.accentRed, size: 20),
                      ),
                      title: Text(item['name'] ?? item['serial_number'] ?? 'ONU', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      subtitle: Text('Port ${item['port'] ?? 1} • ID: ${item['onu_id'] ?? "-"} • ${item['down_reason'] ?? "LOS / Putus"}', style: const TextStyle(fontSize: 11.5)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                        child: Text(item['status']?.toString().toUpperCase() ?? 'OFFLINE', style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                }),
            ],
          ),

          // ==========================================
          // TAB 3: ONT PELANGGAN REMOTE TOOLS
          // ==========================================
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pilih Pelanggan Target', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Ketik nama / ID / PPPoE...',
                                prefixIcon: Icon(Icons.search),
                              ),
                              onSubmitted: (_) => _searchCustomer(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: _searchCustomer,
                            icon: const Icon(Icons.arrow_forward),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              if (_selectedCustomer != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedCustomer!.custId,
                              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _selectedCustomer!.status == 'active' ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _selectedCustomer!.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedCustomer!.status == 'active' ? AppTheme.accentGreen : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedCustomer!.name,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _selectedCustomer!.address,
                          style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
                        ),
                        const Divider(height: 18),
                        Row(
                          children: [
                            Expanded(child: Text('PPPoE: ${_selectedCustomer!.mikrotikUsername ?? "-"}', style: const TextStyle(fontSize: 12))),
                            Expanded(child: Text('SN ONT: ${_selectedCustomer!.onuSn ?? "-"}', style: const TextStyle(fontSize: 12, fontFamily: 'monospace'))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(child: Text('Box ODP: ${_selectedCustomer!.odpName ?? "-"}', style: const TextStyle(fontSize: 12))),
                            Expanded(child: Text('Dropcore: ${_selectedCustomer!.dropcoreLength ?? "-"}', style: const TextStyle(fontSize: 12))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.wifi, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'SSID: ${_selectedCustomer!.wifiSsid ?? "Belum Diset"} • Pass: ${_selectedCustomer!.wifiPassword ?? "Default"}',
                                  style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Text('Aksi Troubleshooting Pelanggan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                const SizedBox(height: 10),

                // Tombol Reboot Modem
                ElevatedButton.icon(
                  onPressed: _isRebooting ? null : _rebootModem,
                  icon: _isRebooting
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.restart_alt, size: 18),
                  label: Text(_isRebooting ? 'Mengirim Sinyal Reboot...' : 'Reboot Modem ONT (TR-069 & OMCI)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
                const SizedBox(height: 10),

                // Tombol Ganti Wi-Fi
                ElevatedButton.icon(
                  onPressed: _openChangeWifiDialog,
                  icon: const Icon(Icons.wifi_password, size: 18),
                  label: const Text('Ganti Nama & Sandi Wi-Fi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
                const SizedBox(height: 10),

                // Tombol Kick PPPoE
                OutlinedButton.icon(
                  onPressed: _isKicking ? null : _kickPppoeSession,
                  icon: _isKicking
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.refresh, size: 18),
                  label: const Text('Kick / Reset Sesi PPPoE di MikroTik'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
                const SizedBox(height: 10),

                // Tombol Isolir / Buka Isolir
                ElevatedButton.icon(
                  onPressed: _isTogglingIsolate ? null : _toggleIsolateCustomer,
                  icon: _isTogglingIsolate
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Icon(_selectedCustomer!.status == 'active' ? Icons.block : Icons.lock_open, size: 18),
                  label: Text(_selectedCustomer!.status == 'active' ? 'Isolir Pelanggan Ini' : 'Buka Isolir Pelanggan Ini'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedCustomer!.status == 'active' ? AppTheme.accentRed : AppTheme.accentGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 24),
                const EmptyState(
                  icon: Icons.router_outlined,
                  title: 'Pilih Pelanggan Terlebih Dahulu',
                  message: 'Gunakan kotak pencarian di atas untuk memilih pelanggan yang ingin di-reboot ONT-nya, diganti WiFi-nya, atau di-reset sesi PPPoE-nya.',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
