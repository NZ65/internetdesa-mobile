import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/sales_provider.dart';
import '../../widgets/cyber_card.dart';

class RegisterProspectScreen extends StatefulWidget {
  const RegisterProspectScreen({super.key});

  @override
  State<RegisterProspectScreen> createState() => _RegisterProspectScreenState();
}

class _RegisterProspectScreenState extends State<RegisterProspectScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  int? _selectedPackageId;
  double? _latitude;
  double? _longitude;
  bool _isGettingGps = false;

  File? _ktpFile;
  File? _houseFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesProvider>().fetchPackages();
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _getCurrentLocation() async {
    setState(() => _isGettingGps = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _latitude = pos.latitude;
          _longitude = pos.longitude;
        });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _isGettingGps = false);
    }
  }

  void _pickPhoto(bool isKtp, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 75);
    if (picked != null) {
      setState(() {
        if (isKtp) {
          _ktpFile = File(picked.path);
        } else {
          _houseFile = File(picked.path);
        }
      });
    }
  }

  void _submitRegistration() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final address = _addressCtrl.text.trim();

    if (name.isEmpty || phone.isEmpty || _selectedPackageId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama, nomor WhatsApp, dan pilihan paket wajib diisi!')),
      );
      return;
    }

    SoundEffects.playTap();
    final salesProv = context.read<SalesProvider>();
    final ok = await salesProv.registerProspect(
      name: name,
      phone: phone,
      address: address,
      packageId: _selectedPackageId!,
      latitude: _latitude,
      longitude: _longitude,
      ktpPhoto: _ktpFile,
      housePhoto: _houseFile,
    );

    if (mounted) {
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pendaftaran berhasil dikirim ke antrean teknisi & grup Telegram!'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(salesProv.errorMessage ?? 'Gagal mengirim pendaftaran.'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final salesProv = context.watch<SalesProvider>();

    return Scaffold(
      backgroundColor: AppTheme.iceBackground,
      appBar: AppBar(
        title: const Text('Pendaftaran Pasang Baru', style: TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppTheme.textMain),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rule 1 Notice Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.verified_user_rounded, color: AppTheme.primaryBlue, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Data otomatis tersimpan ke server dan dilaporkan ke grup Telegram teknisi.',
                      style: TextStyle(fontSize: 11, color: AppTheme.primaryNavy, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Form Fields Card
            CyberCard(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Identitas Calon Pelanggan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor WhatsApp *',
                      hintText: '081234567890',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _addressCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Alamat Lengkap / Dusun / RT RW *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Paket Dropdown
                  DropdownButtonFormField<int>(
                    value: _selectedPackageId,
                    decoration: InputDecoration(
                      labelText: 'Pilih Paket Internet *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: salesProv.packages.map((pkg) {
                      final price = Formatters.formatRupiah(pkg['price'] ?? 0);
                      return DropdownMenuItem<int>(
                        value: pkg['id'],
                        child: Text('${pkg['name']} ($price/bln)', style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedPackageId = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // GPS Coordinates Card
            CyberCard(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Koordinat GPS Lokasi Rumah', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                      IconButton(
                        icon: _isGettingGps
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.my_location_rounded, color: AppTheme.primaryBlue, size: 20),
                        onPressed: _getCurrentLocation,
                      ),
                    ],
                  ),
                  Text(
                    _latitude != null && _longitude != null
                        ? '$_latitude, $_longitude'
                        : 'Menunggu sinyal GPS lokasi pemasangan...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _latitude != null ? AppTheme.accentGreen : AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Photo Uploads (KTP & House)
            CyberCard(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lampiran Foto (Opsional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickPhoto(true, ImageSource.camera),
                          icon: const Icon(Icons.badge_rounded, size: 16),
                          label: Text(_ktpFile != null ? 'KTP Terlampir ✓' : 'Foto KTP', style: const TextStyle(fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _ktpFile != null ? AppTheme.accentGreen : AppTheme.primaryBlue,
                            side: BorderSide(color: _ktpFile != null ? AppTheme.accentGreen : const Color(0xFFCBD5E1)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickPhoto(false, ImageSource.camera),
                          icon: const Icon(Icons.home_work_rounded, size: 16),
                          label: Text(_houseFile != null ? 'Rumah Terlampir ✓' : 'Foto Rumah', style: const TextStyle(fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _houseFile != null ? AppTheme.accentGreen : AppTheme.primaryBlue,
                            side: BorderSide(color: _houseFile != null ? AppTheme.accentGreen : const Color(0xFFCBD5E1)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: salesProv.isLoading ? null : _submitRegistration,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: salesProv.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Kirim Pengajuan Pasang Baru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
