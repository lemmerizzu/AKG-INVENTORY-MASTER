# Progress Project AKG Master (ERP System)

File ini melacak status pengerjaan fitur-fitur dan modul pada project AKG Inventory Master.

## ✅ Selesai & Telah Disetujui (Approved / Done)

- **Setup & Infrastruktur**
  - Inisialisasi project Flutter (Windows Desktop - Web App).
  - Setup skema database relasional menggunakan Supabase (`supabase_schema.sql`).
  - Setup pipelining CI/CD via GitHub Actions untuk automasi `build-windows` release.

- **UI & Arsitektur Utama (Core)**
  - Implementasi warna tema, tipografi, dan komponen dasar UI (Theme).
  - Implementasi tata letak antarmuka utama (Dashboard Shell) dengan Navigation Sidebar.

- **Modul Transaksi (Transaction)**
  - **Input Transaksi**: Pengembangan antarmuka input split-pane layout (History & Input Form) dengan mode Bulk/Reserve dan sistem precision timestamp.
  - **Log Transaksi**: Halaman pelacakan histori semua transaksi dengan fitur filtering berdasarkan tipe mutasi (IN, OUT, OTHER).

---

## ⏳ Belum Terselesaikan / Akan Dijalankan (Pending / To-Do)

Berdasarkan navigasi dan kerangka arsitektur yang sudah ada, berikut adalah modul-modul yang masih menggunakan `PlaceholderPage` dan harus dikembangkan pada sprint / tahap selanjutnya:

- **1. Dashboard Indikator & Metrik**
  - Visualisasi Overview: Menampilkan ringkasan bisnis umum.
  - Grafik Transaksi: Grafik persebaran input dan output aset.
  - Notifikasi/Peringatan: Ringkasan tagihan yang jatuh tempo atau stok tipis.

- **2. Modul Customer Master**
  - CRUD Data Pelanggan.
  - Pengelolaan daftar harga khusus per pelanggan (`customer_pricelists`).
  - Pengelolaan termin pembayaran dan limit hutang (jika ada).

- **3. Modul Inventory & Aset**
  - **Tracking Aset**: Pemantauan tabung/silinder per titik/customer (`cylinder_assets`).
  - **Ledger & Stok**: Kalkulasi buku besar stok di gudang (`inventory_ledger`).
  - Integrasi fitur _Cycle Count_ untuk audit tabung.

- **4. Modul Faktur & Penagihan (Invoicing)**
  - Mengubah Surat Jalan/Transaksi menjadi dokumen Tagihan (`invoices` dan `invoice_lines`).
  - Pemantauan status piutang (Lunas, Belum Lunas).
  - Pencatatan penerimaan dana/pembayaran (`payment_records`).

- **5. Modul Sistem Cetak Dokumen**
  - Sistem pembuatan PDF dari template (`document_templates`).
  - Integrasi print/cetak Surat Jalan (Delivery Order).
  - Integrasi print/cetak Faktur dan Kwitansi Pembayaran.

- **6. Pengaturan (Settings)**
  - Konfigurasi profil utilitas sistem dan info perusahaan.
  - Manajemen Template dokumen cetak.
  - Konfigurasi akun bank.

- **7. Integrasi Backend (Supabase) secara Menyeluruh**
  - Menyambungkan state-state dari Riverpod provider di masing-masing area modul ke client Supabase.
  - Modul Autentikasi (`user_profiles`) untuk login/logout pengguna.
  - Perencanaan fitur konektivitas parsial offline/online melalui tabel `sync_queue` (opsional bergantung pada prioritas operasional).
