import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/sales_provider.dart';
import '../../widgets/zzz_button.dart';
import '../../widgets/zzz_card.dart';

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
        const SnackBar(
          backgroundColor: AppTheme.accentOrange,
          content: Text('Nama, nomor WhatsApp, dan pilihan paket wajib diisi!'),
        ),
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
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.person_add_alt_1_rounded, color: AppTheme.primaryCyan, size: 20),
            SizedBox(width: 8),
            Text(
              'REGISTRASI CALON PELANGGAN',
              style: TextStyle(
                color: AppTheme.textMain,
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: AppTheme.textMain),
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rule 1 Notice Banner (ZZZ Hazard style)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentYellow.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentYellow.withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline_rounded, color: AppTheme.accentYellow, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Data otomatis disimpan ke database & diteruskan ke grup Telegram teknisi tanpa pesan WA otomatis ke pelanggan.',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMain, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Form Fields Card
            ZzzCard(
              tag: 'DATA IDENTITAS',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameCtrl,
                    style: const TextStyle(color: AppTheme.textMain),
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap *',
                      labelStyle: const TextStyle(color: AppTheme.textMuted),
                      filled: true,
                      fillColor: AppTheme.bgDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryCyan)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: AppTheme.textMain),
                    decoration: InputDecoration(
                      labelText: 'Nomor WhatsApp *',
                      hintText: '081234567890',
                      hintStyle: const TextStyle(color: AppTheme.textLight),
                      labelStyle: const TextStyle(color: AppTheme.textMuted),
                      filled: true,
                      fillColor: AppTheme.bgDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryCyan)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _addressCtrl,
                    maxLines: 2,
                    style: const TextStyle(color: AppTheme.textMain),
                    decoration: InputDecoration(
                      labelText: 'Alamat Lengkap / Dusun / RT RW *',
                      labelStyle: const TextStyle(color: AppTheme.textMuted),
                      filled: true,
                      fillColor: AppTheme.bgDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryCyan)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Paket Dropdown
                  DropdownButtonFormField<int>(
                    value: _selectedPackageId,
                    dropdownColor: AppTheme.bgCardElevated,
                    style: const TextStyle(color: AppTheme.textMain),
                    decoration: InputDecoration(
                      labelText: 'Pilih Paket Internet *',
                      labelStyle: const TextStyle(color: AppTheme.textMuted),
                      filled: true,
                      fillColor: AppTheme.bgDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryCyan)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: salesProv.packages.map((pkg) {
                      final price = Formatters.formatRupiah(pkg['price'] ?? 0);
                      return DropdownMenuItem<int>(
                        value: pkg['id'],
                        child: Text('${pkg['name']} ($price/bln)', style: const TextStyle(fontSize: 13, color: AppTheme.textMain)),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedPackageId = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // GPS Coordinates Card
            ZzzCard(
              tag: 'GEOLOKASI RUMAH',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Koordinat GPS Lokasi Pemasangan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                      IconButton(
                        icon: _isGettingGps
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryCyan))
                            : const Icon(Icons.my_location_rounded, color: AppTheme.primaryCyan, size: 20),
                        onPressed: _getCurrentLocation,
                      ),
                    ],
                  ),
                  Text(
                    _latitude != null && _longitude != null
                        ? '$_latitude, $_longitude'
                        : 'Menunggu sinyal GPS lokasi...',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      color: _latitude != null ? AppTheme.accentGreen : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Photo Uploads
            ZzzCard(
              tag: 'DOKUMENTASI FOTO',
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickPhoto(true, ImageSource.camera),
                      icon: const Icon(Icons.badge_rounded, size: 16),
                      label: Text(_ktpFile != null ? 'KTP Terlampir ✓' : 'Foto KTP', style: const TextStyle(fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _ktpFile != null ? AppTheme.accentGreen : AppTheme.primaryCyan,
                        side: BorderSide(color: _ktpFile != null ? AppTheme.accentGreen : AppTheme.borderSubtle),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                        foregroundColor: _houseFile != null ? AppTheme.accentGreen : AppTheme.primaryCyan,
                        side: BorderSide(color: _houseFile != null ? AppTheme.accentGreen : AppTheme.borderSubtle),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ZzzButton(
              label: 'KIRIM PENGAJUAN PASANG BARU',
              icon: Icons.send_rounded,
              type: ZzzButtonType.cyan,
              isLoading: salesProv.isLoading,
              onPressed: salesProv.isLoading ? null : _submitRegistration,
            ),
          ],
        ),
      ),
    );
  }
}
