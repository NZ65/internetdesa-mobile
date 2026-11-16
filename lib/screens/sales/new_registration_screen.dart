import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/registration_model.dart';
import '../../providers/sales_provider.dart';

class NewRegistrationScreen extends StatefulWidget {
  const NewRegistrationScreen({super.key});

  @override
  State<NewRegistrationScreen> createState() => _NewRegistrationScreenState();
}

class _NewRegistrationScreenState extends State<NewRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dropcoreController = TextEditingController(text: '150');

  int? _selectedPackageId;
  double? _latitude;
  double? _longitude;
  bool _isGettingGps = false;

  File? _ktpFile;
  File? _houseFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sales = Provider.of<SalesProvider>(context, listen: false);
      sales.fetchPackages();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dropcoreController.dispose();
    super.dispose();
  }

  void _getGpsLocation() async {
    setState(() => _isGettingGps = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Layanan GPS/Lokasi HP belum aktif.')),
          );
        }
        setState(() => _isGettingGps = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Izin akses lokasi ditolak.')),
            );
          }
          setState(() => _isGettingGps = false);
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isGettingGps = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('GPS Terkunci: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
    } catch (e) {
      setState(() => _isGettingGps = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membaca GPS: $e')),
        );
      }
    }
  }

  void _pickPhoto(bool isKtp, ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
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
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPackageId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih paket internet terlebih dahulu.')),
      );
      return;
    }

    final sales = Provider.of<SalesProvider>(context, listen: false);
    final success = await sales.registerCustomer(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      packageId: _selectedPackageId!,
      dropcoreLength: _dropcoreController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      ktpFile: _ktpFile,
      houseFile: _houseFile,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran berhasil dikirim ke antrean teknisi!'),
          backgroundColor: AppTheme.accentGreen,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(sales.errorMessage ?? 'Gagal menyimpan pendaftaran.'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sales = Provider.of<SalesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Pasang Baru'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Customer Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Data Calon Pelanggan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap Pelanggan',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Nomor WhatsApp Aktif',
                        hintText: '081234567890',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Nomor HP wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Alamat Pemasangan Lengkap',
                        hintText: 'RT/RW, Desa, Patokan Rumah',
                        prefixIcon: Icon(Icons.home_outlined),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Alamat wajib diisi' : null,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Package & Dropcore Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Paket & Teknis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedPackageId,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Paket Internet',
                        prefixIcon: Icon(Icons.speed),
                      ),
                      items: sales.packages.map((p) {
                        return DropdownMenuItem<int>(
                          value: p.id,
                          child: Text('${p.name} (Rp ${p.price ~/ 1000}rb)'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedPackageId = val),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dropcoreController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Estimasi Panjang Kabel Dropcore (Meter)',
                        suffixText: 'Meter',
                        prefixIcon: Icon(Icons.linear_scale),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // GPS Location Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Titik Koordinat GPS Rumah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        IconButton(
                          icon: _isGettingGps
                              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.my_location, color: AppTheme.primaryBlue),
                          onPressed: _isGettingGps ? null : _getGpsLocation,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_latitude != null && _longitude != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Lat: ${_latitude!.toStringAsFixed(6)}\nLng: ${_longitude!.toStringAsFixed(6)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: _isGettingGps ? null : _getGpsLocation,
                        icon: const Icon(Icons.location_searching),
                        label: const Text('Ambil Titik Lokasi Sekarang (GPS)'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(44),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Photos Card (KTP & House)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Foto Berkas Lapangan (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 16),

                    // KTP Photo
                    _buildPhotoUploader('Foto KTP Pelanggan', _ktpFile, true),
                    const SizedBox(height: 16),

                    // House Photo
                    _buildPhotoUploader('Foto Depan Rumah', _houseFile, false),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: sales.isLoading ? null : _submitRegistration,
              child: sales.isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Kirim Pendaftaran Pasang Baru'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoUploader(String label, File? file, bool isKtp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (file != null) ...[
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(file, height: 140, width: double.infinity, fit: BoxFit.cover),
              ),
              IconButton(
                icon: const CircleAvatar(backgroundColor: Colors.white, radius: 14, child: Icon(Icons.close, size: 16, color: Colors.black)),
                onPressed: () => setState(() {
                  if (isKtp) _ktpFile = null;
                  else _houseFile = null;
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickPhoto(isKtp, ImageSource.camera),
                  icon: const Icon(Icons.camera_alt, size: 16),
                  label: const Text('Kamera', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickPhoto(isKtp, ImageSource.gallery),
                  icon: const Icon(Icons.photo_library, size: 16),
                  label: const Text('Galeri', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
